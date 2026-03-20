import 'dart:async';
import 'dart:ui' as ui;

import 'package:auth_foundation/auth_foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:settings_feature/src/cubit/auth_cubit.dart'
    show
        AuthCubit,
        AuthState,
        kDeleteAccountFailed,
        kDeleteAccountRequiresRecentLogin,
        kProfilePhotoNeedSignIn,
        kProfilePhotoTokenFailed,
        kProfilePhotoUploadFailed,
        kProfilePhotoWrongAccount;
import 'package:settings_feature/src/data/notification_push_preferences_repository.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

Future<void> _restoreSubscriptionPurchases(BuildContext context) async {
  final cubit = context.read<SubscriptionEntitlementCubit>();
  final l10n = context.l10n;
  final outcome = await cubit.restorePurchases();
  if (!context.mounted) return;
  final message = switch (outcome) {
    SubscriptionRestoreOutcome.success => l10n.purchasesRestoreSuccess,
    SubscriptionRestoreOutcome.nothingFound => l10n.purchasesRestoreEmpty,
    SubscriptionRestoreOutcome.notConfigured => l10n.purchasesNotConfigured,
    SubscriptionRestoreOutcome.failed => l10n.purchasesRestoreFailed,
  };
  final type = outcome == SubscriptionRestoreOutcome.success
      ? UiSnackbarType.success
      : outcome == SubscriptionRestoreOutcome.failed
          ? UiSnackbarType.error
          : UiSnackbarType.normal;
  uiSnackBar(context: context, message: message, type: type);
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.profilePhotoSheet,
    super.key,
  });

  final ProfilePhotoSheet profilePhotoSheet;

  static const String _supportId = 'GsV6wVJe89UQajUpAZJELaEYn733';
  static const String _appVersion = '1.0.0';

  /// Dev/staging apenas ([AppBuildFlavorConfig] no GetIt).
  static bool _showPushTokenDebug() {
    final g = GetIt.instance;
    return g.isRegistered<AppBuildFlavorConfig>() &&
        g<AppBuildFlavorConfig>().showPushTokenDebug;
  }

  static String _resolveErrorMessage(BuildContext context, String code) {
    final l10n = context.l10n;
    return switch (code) {
      kProfilePhotoNeedSignIn => l10n.profilePhotoNeedSignIn,
      kProfilePhotoWrongAccount => l10n.profilePhotoWrongAccount,
      kProfilePhotoTokenFailed => l10n.profilePhotoTokenFailed,
      kProfilePhotoUploadFailed => l10n.profilePhotoUploadFailed,
      kDeleteAccountRequiresRecentLogin =>
        l10n.deleteAccountRequiresRecentLogin,
      kDeleteAccountFailed => l10n.deleteAccountFailed,
      _ => code,
    };
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final authCubit = context.read<AuthCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.deleteAccountCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAccountConfirmCta),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await authCubit.deleteAccount();
    }
  }

  void _showSetDisplayNameDialog(BuildContext context) {
    final l10n = context.l10n;
    final authCubit = context.read<AuthCubit>();
    final controller = TextEditingController();
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.displayNameLabel),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.displayNameHint,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              unawaited(authCubit.updateDisplayName(value));
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                MaterialLocalizations.of(dialogContext).cancelButtonLabel,
              ),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                unawaited(authCubit.updateDisplayName(text));
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _SettingsHeader(
              title: l10n.settingsTitle,
              subtitle: l10n.settingsSubtitle,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- ASSINATURA ---
                BlocBuilder<SubscriptionEntitlementCubit,
                    SubscriptionEntitlementState>(
                  builder: (context, subState) {
                    return _SubscriptionSection(
                      maxFreePatients: SubscriptionLimits.maxFreePatients,
                      isPro: subState.isPro,
                      onUpgrade: () => context.push('/plans'),
                      onRestorePurchases: () =>
                          unawaited(_restoreSubscriptionPurchases(context)),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // --- CONTA ---
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      final msg = _resolveErrorMessage(
                        context,
                        state.errorMessage!,
                      );
                      uiSnackBar(
                        context: context,
                        message: msg,
                        type: UiSnackbarType.error,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.isLoggedIn) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LoggedInSection(
                            userId: state.user!.uid,
                            email: state.user!.email ?? state.user!.uid,
                            photoUrl: state.user!.photoUrl,
                            displayName: state.user!.displayName,
                            profilePhotoUploading: state.profilePhotoUploading,
                            onLogout: () => unawaited(
                              context.read<AuthCubit>().signOut(),
                            ),
                            onDeleteAccount: () => unawaited(
                              _confirmDeleteAccount(context),
                            ),
                            onSetDisplayName: _showSetDisplayNameDialog,
                            onProfilePhotoTap: () =>
                                profilePhotoSheet(context),
                          ),
                          const SizedBox(height: 32),
                          _NotificationPushPreferencesSection(
                            userId: state.user!.uid,
                          ),
                          if (_showPushTokenDebug()) ...[
                            if (defaultTargetPlatform ==
                                TargetPlatform.iOS) ...[
                              const SizedBox(height: 32),
                              _SectionTitle(
                                title: l10n.settingsDebugApnsTitle,
                                icon: Icons.bug_report_outlined,
                              ),
                              const SizedBox(height: 8),
                              UiCard(
                                padding: EdgeInsets.zero,
                                child: _SettingsTile(
                                  icon: Icons.vpn_key_outlined,
                                  label: l10n.settingsDebugApnsShow,
                                  subtitle: l10n.settingsDebugApnsSubtitle,
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: appColors.gray,
                                  ),
                                  onTap: () => unawaited(
                                    _showApnsDebugDialog(context, l10n),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            _SectionTitle(
                              title: l10n.settingsDebugFcmTitle,
                              icon: Icons.cloud_outlined,
                            ),
                            const SizedBox(height: 8),
                            UiCard(
                              padding: EdgeInsets.zero,
                              child: _SettingsTile(
                                icon: Icons.token_outlined,
                                label: l10n.settingsDebugFcmShow,
                                subtitle: l10n.settingsDebugFcmSubtitle,
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: appColors.gray,
                                ),
                                onTap: () => unawaited(
                                  _showFcmDebugDialog(context, l10n),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    }
                    return _LoggedOutSection(
                      onGoogleSignIn: () => unawaited(
                        context.read<AuthCubit>().signInWithGoogle(),
                      ),
                      onAppleSignIn: () => unawaited(
                        context.read<AuthCubit>().signInWithApple(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // --- IDIOMA ---
                _SectionTitle(
                  title: l10n.sectionLanguage,
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 8),
                const _LanguageSection(),
                const SizedBox(height: 32),

                // --- APARÊNCIA ---
                _SectionTitle(
                  title: l10n.sectionAppearance,
                  icon: Icons.palette_outlined,
                ),
                const SizedBox(height: 8),
                _AppearanceSection(theme: theme),
                const SizedBox(height: 32),

                // --- SOBRE ---
                _SectionTitle(
                  title: l10n.sectionAbout,
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 8),
                UiCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.verified_outlined,
                        iconColor: appColors.primary,
                        label: l10n.versionLabel,
                        trailing: Text(
                          _appVersion,
                          style: AppTextStyles.body2.copyWith(
                            color: appColors.gray,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: appColors.grayLight,
                      ),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        iconColor: appColors.error,
                        label: l10n.requestAccountDeletion,
                        subtitle: l10n.privacyPolicyLink,
                        trailing: Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: appColors.gray,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- SUPORTE ---
                _SectionTitle(
                  title: l10n.sectionSupport,
                  icon: Icons.support_agent_rounded,
                ),
                const SizedBox(height: 8),
                _SupportCard(
                  supportId: _supportId,
                  supportIdHint: l10n.supportIdHint,
                  copyLabel: l10n.copySupportId,
                  onCopy: () => _copySupportId(context),
                ),
                const SizedBox(height: 12),
                _RateAppCard(
                  title: l10n.rateApp,
                  subtitle: l10n.rateAppSubtitle,
                  onTap: () {
                    uiSnackBar(
                      context: context,
                      message: l10n.rateAppStoreSoon,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static void _copySupportId(BuildContext context) {
    unawaited(
      Clipboard.setData(const ClipboardData(text: _supportId)),
    );
    uiSnackBar(
      context: context,
      message: context.l10n.copySupportId,
    );
  }

  /// Debug iOS — remover no futuro.
  static Future<void> _showApnsDebugDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final snackContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _ApnsTokenDebugDialog(
        l10n: l10n,
        snackbarContext: snackContext,
      ),
    );
  }

  static Future<void> _showFcmDebugDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final snackContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FcmTokenDebugDialog(
        l10n: l10n,
        snackbarContext: snackContext,
      ),
    );
  }
}

class _ApnsTokenDebugDialog extends StatefulWidget {
  const _ApnsTokenDebugDialog({
    required this.l10n,
    required this.snackbarContext,
  });

  final AppLocalizations l10n;
  final BuildContext snackbarContext;

  @override
  State<_ApnsTokenDebugDialog> createState() => _ApnsTokenDebugDialogState();
}

class _ApnsTokenDebugDialogState extends State<_ApnsTokenDebugDialog> {
  String? _token;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final t = await FirebaseMessaging.instance.getAPNSToken();
    if (!mounted) return;
    setState(() {
      _token = t;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.settingsDebugApnsTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _token == null || _token!.isEmpty
                ? Text(l10n.settingsDebugApnsUnavailable)
                : SelectableText(
                    _token!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () {
                  setState(() => _loading = true);
                  unawaited(_load());
                },
          child: Text(l10n.settingsDebugApnsRefresh),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
        FilledButton(
          onPressed: _loading || _token == null || _token!.isEmpty
              ? null
              : () {
                  unawaited(
                    Clipboard.setData(ClipboardData(text: _token!)),
                  );
                  Navigator.of(context).pop();
                  final ctx = widget.snackbarContext;
                  if (ctx.mounted) {
                    uiSnackBar(
                      context: ctx,
                      message: l10n.settingsDebugApnsCopied,
                    );
                  }
                },
          child: Text(l10n.settingsDebugApnsCopy),
        ),
      ],
    );
  }
}

class _FcmTokenDebugDialog extends StatefulWidget {
  const _FcmTokenDebugDialog({
    required this.l10n,
    required this.snackbarContext,
  });

  final AppLocalizations l10n;
  final BuildContext snackbarContext;

  @override
  State<_FcmTokenDebugDialog> createState() => _FcmTokenDebugDialogState();
}

class _FcmTokenDebugDialogState extends State<_FcmTokenDebugDialog> {
  String? _token;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
    });
    try {
      final t = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      setState(() {
        _token = t;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _token = null;
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.settingsDebugFcmTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _token != null && _token!.isNotEmpty
                ? SelectableText(
                    _token!,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Text(
                    _error != null
                        ? '${l10n.settingsDebugFcmUnavailable}\n($_error)'
                        : l10n.settingsDebugFcmUnavailable,
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () {
                  setState(() => _loading = true);
                  unawaited(_load());
                },
          child: Text(l10n.settingsDebugApnsRefresh),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
        FilledButton(
          onPressed: _loading || _token == null || _token!.isEmpty
              ? null
              : () {
                  unawaited(
                    Clipboard.setData(ClipboardData(text: _token!)),
                  );
                  Navigator.of(context).pop();
                  final ctx = widget.snackbarContext;
                  if (ctx.mounted) {
                    uiSnackBar(
                      context: ctx,
                      message: l10n.settingsDebugFcmCopied,
                    );
                  }
                },
          child: Text(l10n.settingsDebugFcmCopy),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ALERTAS PUSH (estilo lembretes: switch mestre + opções)
// ---------------------------------------------------------------------------

class _NotificationPushPreferencesSection extends StatelessWidget {
  const _NotificationPushPreferencesSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final repo = GetIt.instance<NotificationPushPreferencesRepository>();
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: l10n.sectionNotificationsPush,
          icon: Icons.notifications_outlined,
        ),
        const SizedBox(height: 8),
        StreamBuilder<NotificationPushPrefs>(
          stream: repo.watchPrefs(userId),
          builder: (context, snapshot) {
            final prefs = snapshot.data ??
                const NotificationPushPrefs(
                  pushEnabled: true,
                  mode: NotificationPushMode.all,
                );
            return DecoratedBox(
              decoration: BoxDecoration(
                color: appColors.grayLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appColors.grayLight.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 6, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.notificationPushMasterTitle,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: appColors.neutralBlack,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.notificationPushMasterSubtitle,
                                style: AppTextStyles.body3.copyWith(
                                  color: appColors.gray,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: prefs.pushEnabled,
                          onChanged: (v) =>
                              unawaited(
                                repo.setPushEnabled(
                                  userId,
                                  enabled: v,
                                ),
                              ),
                          activeTrackColor:
                              appColors.primary.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ),
                  if (prefs.pushEnabled) ...[
                    Divider(height: 1, color: appColors.grayLight),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        l10n.notificationPushCustomizeHint,
                        style: AppTextStyles.body3.copyWith(
                          color: appColors.gray,
                        ),
                      ),
                    ),
                    _NotificationPushSubRow(
                      title: l10n.notificationPushAllEntries,
                      subtitle: l10n.notificationPushAllEntriesRowSubtitle,
                      value: prefs.mode == NotificationPushMode.all,
                      onChanged: (on) {
                        if (on) {
                          unawaited(
                            repo.setPushMode(
                              userId,
                              NotificationPushMode.all,
                            ),
                          );
                        } else {
                          unawaited(
                            repo.setPushMode(
                              userId,
                              NotificationPushMode.criticalOnly,
                            ),
                          );
                        }
                      },
                      appColors: appColors,
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: appColors.grayLight,
                    ),
                    _NotificationPushSubRow(
                      title: l10n.notificationPushCriticalOnly,
                      subtitle: l10n.notificationPushCriticalOnlyRowSubtitle,
                      value:
                          prefs.mode == NotificationPushMode.criticalOnly,
                      onChanged: (on) {
                        if (on) {
                          unawaited(
                            repo.setPushMode(
                              userId,
                              NotificationPushMode.criticalOnly,
                            ),
                          );
                        } else {
                          unawaited(
                            repo.setPushMode(
                              userId,
                              NotificationPushMode.all,
                            ),
                          );
                        }
                      },
                      appColors: appColors,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NotificationPushSubRow extends StatelessWidget {
  const _NotificationPushSubRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.appColors,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                      color: appColors.neutralBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.body3.copyWith(
                      color: appColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: appColors.primary.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: UiIcon(
                UiIcons.settings,
                size: 22,
                color: appColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.body3.copyWith(color: appColors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION TITLE
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: appColors.gray),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.body3.copyWith(
              color: appColors.gray,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGGED OUT SECTION
// ---------------------------------------------------------------------------

class _LoggedOutSection extends StatelessWidget {
  const _LoggedOutSection({
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: l10n.sectionAccount,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 8),
        UiCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.primaryLight.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: appColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.accountSignInIntro,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.grayDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SignInButton(
                label: l10n.loginWithGoogle,
                icon: Icons.g_mobiledata,
                backgroundColor: const Color(0xFFFFFFFF),
                borderColor: appColors.grayLight,
                textColor: const Color(0xFF1F1F1F),
                onTap: onGoogleSignIn,
              ),
              const SizedBox(height: 10),
              _SignInButton(
                label: l10n.loginWithApple,
                icon: Icons.apple,
                backgroundColor: const Color(0xFF1F1F1F),
                textColor: const Color(0xFFFFFFFF),
                onTap: onAppleSignIn,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AVATAR TOCÁVEL COM OVERLAY DE LOADING (foto de perfil)
// ---------------------------------------------------------------------------

class _ProfileAvatarTile extends StatelessWidget {
  const _ProfileAvatarTile({
    required this.userId,
    required this.email,
    this.authPhotoUrl,
    this.displayName,
    this.isUploading = false,
    this.onTap,
  });

  final String userId;
  final String email;
  final String? authPhotoUrl;
  final String? displayName;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final child = _AccountAvatar(
      userId: userId,
      email: email,
      authPhotoUrl: authPhotoUrl,
      displayName: displayName,
    );
    final wrapped = onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: child,
            ),
          )
        : child;
    if (!isUploading) return wrapped;
    return Stack(
      alignment: Alignment.center,
      children: [
        wrapped,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: appColors.neutralBlack.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: appColors.neutralWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AVATAR COM FALLBACK FIRESTORE (Auth às vezes não persiste photoURL)
// ---------------------------------------------------------------------------

class _AccountAvatar extends StatefulWidget {
  const _AccountAvatar({
    required this.userId,
    required this.email,
    this.authPhotoUrl,
    this.displayName,
  });

  final String userId;
  final String email;
  final String? authPhotoUrl;
  final String? displayName;

  @override
  State<_AccountAvatar> createState() => _AccountAvatarState();
}

class _AccountAvatarState extends State<_AccountAvatar> {
  String? _photoUrlFromFirestore;

  @override
  void initState() {
    super.initState();
    if (_needsFirestoreFallback) {
      unawaited(_fetchPhotoFromFirestore());
    }
  }

  bool get _needsFirestoreFallback =>
      widget.authPhotoUrl == null || widget.authPhotoUrl!.isEmpty;

  Future<void> _fetchPhotoFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      final url = doc.data()?['photoUrl'] as String?;
      if (url != null && url.isNotEmpty && mounted) {
        setState(() => _photoUrlFromFirestore = url);
      }
    } on Object catch (_) {
      // Ignora; avatar fica com placeholder
    }
  }

  @override
  void didUpdateWidget(covariant _AccountAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.authPhotoUrl != widget.authPhotoUrl) {
      _photoUrlFromFirestore = null;
      if (_needsFirestoreFallback) {
        unawaited(_fetchPhotoFromFirestore());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.authPhotoUrl ?? _photoUrlFromFirestore;
    final user = AuthUser(
      uid: widget.userId,
      email: widget.email,
      displayName: widget.displayName,
      photoUrl: url,
    );
    return UserAvatar(user: user, size: 48);
  }
}

// ---------------------------------------------------------------------------
// LOGGED IN SECTION
// ---------------------------------------------------------------------------

class _LoggedInSection extends StatelessWidget {
  const _LoggedInSection({
    required this.userId,
    required this.email,
    required this.onLogout,
    required this.onDeleteAccount,
    this.photoUrl,
    this.displayName,
    this.profilePhotoUploading = false,
    this.onSetDisplayName,
    this.onProfilePhotoTap,
  });

  final String userId;
  final String email;
  final String? photoUrl;
  final String? displayName;
  final bool profilePhotoUploading;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final void Function(BuildContext context)? onSetDisplayName;
  final VoidCallback? onProfilePhotoTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: l10n.sectionAccount,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 8),
        UiCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _ProfileAvatarTile(
                userId: userId,
                email: email,
                authPhotoUrl: photoUrl,
                displayName: displayName,
                isUploading: profilePhotoUploading,
                onTap: onProfilePhotoTap,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayName != null && displayName!.isNotEmpty)
                      Text(
                        displayName!,
                        style: AppTextStyles.h4.copyWith(
                          color: appColors.neutralBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      email,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.gray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              UiAutoWidthButton(
                text: l10n.logout,
                type: UiAutoWidthType.outline,
                size: UiAutoWidthSize.small,
                icon: UiIcons.logout,
                iconAlignment: UiButtonIconAlignment.before,
                onPressed: onLogout,
              ),
            ],
          ),
        ),
        if (displayName == null || displayName!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => onSetDisplayName?.call(context),
              icon: const Icon(Icons.person_add_outlined, size: 20),
              label: Text(l10n.setDisplayName),
            ),
          ),
        Center(
          child: TextButton(
            onPressed: onDeleteAccount,
            child: Text(
              l10n.deleteAccount,
              style: AppTextStyles.body2.copyWith(color: appColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SIGN IN BUTTON (custom styled)
// ---------------------------------------------------------------------------

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: textColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.buttonMedium.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SETTINGS TILE (generic row inside a card)
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final effectiveIconColor = iconColor ?? appColors.gray;

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: effectiveIconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                    color: appColors.neutralBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.body3.copyWith(
                      color: appColors.gray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: child,
      );
    }
    return child;
  }
}

// ---------------------------------------------------------------------------
// SUPPORT CARD
// ---------------------------------------------------------------------------

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.supportId,
    required this.supportIdHint,
    required this.copyLabel,
    required this.onCopy,
  });

  final String supportId;
  final String supportIdHint;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Icon(
                    Icons.headset_mic_outlined,
                    size: 18,
                    color: appColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.supportIdLabel,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                    color: appColors.neutralBlack,
                  ),
                ),
              ),
              UiAutoWidthButton(
                text: copyLabel,
                icon: UiIcons.copy,
                iconAlignment: UiButtonIconAlignment.before,
                type: UiAutoWidthType.outline,
                size: UiAutoWidthSize.small,
                onPressed: onCopy,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            supportIdHint,
            style: AppTextStyles.body3.copyWith(color: appColors.gray),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: appColors.grayLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              supportId,
              style: AppTextStyles.body3.copyWith(
                fontFamily: 'monospace',
                color: appColors.grayDark,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RATE APP CARD
// ---------------------------------------------------------------------------

class _RateAppCard extends StatelessWidget {
  const _RateAppCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return UiCard(
      onTap: onTap,
      borderColor: appColors.primaryLight.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appColors.primary.withValues(alpha: 0.15),
                  appColors.primaryLight.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star_rounded,
              color: appColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.gray,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: appColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// APPEARANCE SECTION
// ---------------------------------------------------------------------------

class _AppearanceSection extends StatefulWidget {
  const _AppearanceSection({required this.theme});

  final ThemeData theme;

  @override
  State<_AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<_AppearanceSection> {
  late ThemeModeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = GetIt.instance<ThemeModeService>();
  }

  Future<void> _setTheme(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final isLight = widget.theme.brightness == Brightness.light;

    return UiCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: UiRadioButton<int>(
              value: 0,
              groupValue: isLight ? 0 : 1,
              onChanged: (_) => unawaited(_setTheme(ThemeMode.light)),
              label: '☀️  ${l10n.appearanceLight}',
            ),
          ),
          Divider(
            height: 1,
            indent: 40,
            color: appColors.grayLight,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: UiRadioButton<int>(
              value: 1,
              groupValue: isLight ? 0 : 1,
              onChanged: (_) => unawaited(_setTheme(ThemeMode.dark)),
              label: '🌙  ${l10n.appearanceDark}',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LANGUAGE SECTION
// ---------------------------------------------------------------------------

class _LanguageSection extends StatefulWidget {
  const _LanguageSection();

  @override
  State<_LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<_LanguageSection> {
  late LocaleService _localeService;

  static const _locales = [
    ui.Locale('pt'),
    ui.Locale('en'),
    ui.Locale('es'),
  ];

  @override
  void initState() {
    super.initState();
    _localeService = GetIt.instance<LocaleService>();
  }

  Future<void> _setLocale(ui.Locale locale) async {
    await _localeService.setLocale(locale);
    if (mounted) setState(() {});
  }

  int _currentIndex() {
    final current = _localeService.getLocale();
    return _locales.indexWhere((l) => l.languageCode == current.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final labels = [
      '🇧🇷  ${l10n.languagePt}',
      '🇺🇸  ${l10n.languageEn}',
      '🇪🇸  ${l10n.languageEs}',
    ];

    return UiCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        children: [
          for (var i = 0; i < _locales.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 40,
                color: appColors.grayLight,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: UiRadioButton<int>(
                value: i,
                groupValue: _currentIndex(),
                onChanged: (_) => unawaited(_setLocale(_locales[i])),
                label: labels[i],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBSCRIPTION SECTION
// ---------------------------------------------------------------------------

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({
    required this.maxFreePatients,
    required this.isPro,
    required this.onUpgrade,
    required this.onRestorePurchases,
  });

  final int maxFreePatients;
  final bool isPro;
  final VoidCallback onUpgrade;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: context.l10n.sectionSubscription,
          icon: Icons.workspace_premium_rounded,
        ),
        const SizedBox(height: 8),
        _SubscriptionCard(
          maxFreePatients: maxFreePatients,
          isPro: isPro,
          onUpgrade: onUpgrade,
          appColors: appColors,
        ),
        if (!isPro) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onRestorePurchases,
              icon: Icon(
                Icons.history_rounded,
                size: 18,
                color: appColors.primary,
              ),
              label: Text(
                context.l10n.restorePurchases,
                style: AppTextStyles.body2.copyWith(
                  color: appColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SubscriptionCard extends StatefulWidget {
  const _SubscriptionCard({
    required this.maxFreePatients,
    required this.isPro,
    required this.onUpgrade,
    required this.appColors,
  });

  final int maxFreePatients;
  final bool isPro;
  final VoidCallback onUpgrade;
  final AppColors appColors;

  @override
  State<_SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<_SubscriptionCard> {
  int _patientCount = 0;
  bool _loading = true;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPatientCount());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _loadPatientCount() async {
    try {
      final authCubit = context.read<AuthCubit>();
      final user = authCubit.state.user;
      if (user == null) {
        setState(() {
          _patientCount = 0;
          _loading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      _subscription = firestore
          .collection('clinicians')
          .doc(user.uid)
          .collection('patients')
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _patientCount = snapshot.docs.length;
            _loading = false;
          });
        }
      });
    } on Object catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = widget.appColors;

    return UiCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isPro
                      ? appColors.primary.withValues(alpha: 0.1)
                      : appColors.grayLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.isPro
                      ? Icons.star_rounded
                      : Icons.inventory_2_outlined,
                  color: widget.isPro ? appColors.primary : appColors.gray,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isPro
                          ? context.l10n.planPro
                          : context.l10n.planFree,
                      style: AppTextStyles.h4.copyWith(
                        color: appColors.neutralBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (_loading)
                      Text(
                        context.l10n.loading,
                        style: AppTextStyles.body3.copyWith(
                          color: appColors.gray,
                        ),
                      )
                    else
                      Text(
                        widget.isPro
                            ? context.l10n.unlimitedPatients
                            : context.l10n.patientsCountOfMax(
                                _patientCount,
                                widget.maxFreePatients,
                              ),
                        style: AppTextStyles.body3.copyWith(
                          color: appColors.gray,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isPro && !_loading) ...[
            const SizedBox(height: 16),
            _ProgressBar(
              value: _patientCount / widget.maxFreePatients,
              appColors: appColors,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onUpgrade,
                style: FilledButton.styleFrom(
                  backgroundColor: appColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.upgradeToPro,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.appColors,
  });

  final double value;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final isOverLimit = value > 1.0;
    final barColor = isOverLimit ? appColors.error : appColors.alert;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: appColors.grayLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: isOverLimit ? 1.0 : clampedValue,
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
