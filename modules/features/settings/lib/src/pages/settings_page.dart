import 'dart:async';
import 'dart:ui' as ui;

import 'package:auth_foundation/auth_foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:settings_feature/src/cubit/auth_cubit.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _supportId = 'GsV6wVJe89UQajUpAZJELaEYn733';
  static const String _appVersion = '1.0.0';

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
                _SubscriptionSection(
                  maxFreePatients: 2,
                  isPro: false,
                  onUpgrade: () => context.push('/plans'),
                ),
                const SizedBox(height: 32),

                // --- CONTA ---
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      uiSnackBar(
                        context: context,
                        message: state.errorMessage!,
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
                      return _LoggedInSection(
                        userId: state.user!.uid,
                        email: state.user!.email ?? state.user!.uid,
                        photoUrl: state.user!.photoUrl,
                        displayName: state.user!.displayName,
                        onLogout: () => unawaited(
                          context.read<AuthCubit>().signOut(),
                        ),
                        onSetDisplayName: _showSetDisplayNameDialog,
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
    this.photoUrl,
    this.displayName,
    this.onSetDisplayName,
  });

  final String userId;
  final String email;
  final String? photoUrl;
  final String? displayName;
  final VoidCallback onLogout;
  final void Function(BuildContext context)? onSetDisplayName;

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
              _AccountAvatar(
                userId: userId,
                email: email,
                authPhotoUrl: photoUrl,
                displayName: displayName,
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
  });

  final int maxFreePatients;
  final bool isPro;
  final VoidCallback onUpgrade;

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
              onPressed: () {
                uiSnackBar(
                  context: context,
                  message: context.l10n.restorePurchasesSoon,
                );
              },
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
