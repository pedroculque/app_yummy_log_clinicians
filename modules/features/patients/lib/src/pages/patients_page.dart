import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patients_feature/patients_feature.dart'
    show trackActionAndRequestAppRatingIfEligible;
import 'package:patients_feature/src/cubit/patients_cubit.dart';
import 'package:patients_feature/src/cubit/patients_state.dart';
import 'package:patients_feature/src/data/patient.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({
    required this.profilePhotoSheet,
    super.key,
  });

  final ProfilePhotoSheet profilePhotoSheet;

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  /// UID do último usuário para o qual carregamos pacientes.
  /// Ao fazer login ou trocar conta, forçamos reload e zeramos estado antigo.
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    _loadIfLoggedIn();
  }

  void _loadIfLoggedIn() {
    final authRepo = context.read<AuthRepository>();
    final current = authRepo.currentUser;
    if (current != null) {
      _lastLoadedUserId = current.uid;
      unawaited(context.read<PatientsCubit>().load());
    }
  }

  void _onAuthUserChanged(AuthUser? user) {
    if (user == null) {
      _lastLoadedUserId = null;
      return;
    }
    if (user.uid == _lastLoadedUserId) return;
    _lastLoadedUserId = user.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<PatientsCubit>().load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return StreamBuilder<AuthUser?>(
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;

        _onAuthUserChanged(user);

        return Scaffold(
          backgroundColor: appColors.backgroundDefault,
          body: SafeArea(
            child: user != null
                ? _buildLoggedInContent(user)
                : _buildLoggedOutContent(),
          ),
        );
      },
    );
  }

  Widget _buildLoggedOutContent() {
    return Column(
      children: [
        _PageHeader(
          patientCount: 0,
          l10n: context.l10n,
          showSyncIndicator: true,
        ),
        Expanded(
          child: _EmptyStateNotLoggedIn(l10n: context.l10n),
        ),
        _InviteButton(onPressed: () => _requestLogin(context)),
      ],
    );
  }

  Widget _buildLoggedInContent(AuthUser user) {
    return BlocConsumer<PatientsCubit, PatientsState>(
      listenWhen: (previous, current) =>
          current.status == PatientsStatus.loaded &&
          current.hasPatients &&
          previous.patients.isEmpty,
      listener: (context, state) {
        unawaited(
          trackActionAndRequestAppRatingIfEligible(
            context,
            origin: 'first_patient_linked',
          ),
        );
      },
      builder: (context, state) {
        if (state.status == PatientsStatus.initial) {
          unawaited(context.read<PatientsCubit>().load());
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PatientsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PatientsStatus.error) {
          final l10n = context.l10n;
          final errorMessage = state.error == 'not_logged_in'
              ? l10n.errorNotLoggedIn
              : (state.error ?? l10n.patientsLoadError);
          return _ErrorState(
            error: errorMessage,
            onRetry: () => context.read<PatientsCubit>().load(),
          );
        }

        return Column(
          children: [
            _PageHeader(
              patientCount: state.patients.length,
              clinicianName: user.displayName,
              l10n: context.l10n,
              user: user,
              showSyncIndicator: true,
              isSynced: state.status == PatientsStatus.loaded
                  && !state.isRefreshing,
              isSyncing: state.isRefreshing,
              onSyncTap: () => context.read<PatientsCubit>().load(),
              onProfilePhotoTap: () => widget.profilePhotoSheet(context),
            ),
            Expanded(
              child: state.isEmpty
                  ? _EmptyState(
                      onInvite: () => _showInviteSheet(context),
                      l10n: context.l10n,
                    )
                  : _PatientsList(
                      patients: state.patients,
                      onPatientTap: _onPatientTap,
                      onConfigFormTap: _onConfigFormTap,
                      onRemovePatient: _confirmRemovePatient,
                    ),
            ),
            _InviteButton(onPressed: () => _showInviteSheet(context)),
          ],
        );
      },
    );
  }

  void _onPatientTap(Patient patient) {
    final displayName = patient.name.isEmpty
        ? context.l10n.patientDefaultName
        : patient.name;
    final encodedName = Uri.encodeComponent(displayName);
    unawaited(
      context.push('/patients/${patient.id}/diary?name=$encodedName'),
    );
  }

  void _onConfigFormTap(Patient patient) {
    final displayName = patient.name.isEmpty
        ? context.l10n.patientDefaultName
        : patient.name;
    final encodedName = Uri.encodeComponent(displayName);
    unawaited(
      context.push(
        '/patients/${patient.id}/form-config?name=$encodedName',
      ),
    );
  }

  Future<void> _confirmRemovePatient(Patient patient) async {
    final appColors = AppColors.fromContext(context);
    final cubit = context.read<PatientsCubit>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = ctx.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appColors.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: appColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_remove_outlined,
                    color: appColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.removePatientTitle,
                  style: AppTextStyles.h3.copyWith(
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.removePatientMessage(
                    patient.name.isEmpty
                        ? l10n.patientDefaultName
                        : patient.name,
                  ),
                  style: AppTextStyles.body2.copyWith(color: appColors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.error,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.removePatientButton,
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                UiFixedButton(
                  text: l10n.cancelButton,
                  type: UiFixedButtonType.outline,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await cubit.removePatient(patient.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                context.l10n.patientRemoved(
                  patient.name.isEmpty
                      ? context.l10n.patientDefaultName
                      : patient.name,
                ),
              ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _requestLogin(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = context.l10n;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.login_rounded,
                  color: appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.loginRequiredTitle),
            ],
          ),
          content: Text(l10n.loginRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n.cancelButton,
                style: TextStyle(color: appColors.gray),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _goToSettings(context);
              },
              child: Text(l10n.goToSettings),
            ),
          ],
        );
      },
    ));
  }

  void _goToSettings(BuildContext context) {
    context.go('/settings');
  }

  void _showUpgradeDialog(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    context.read<PatientsCubit>().logPaywallInviteLimitSheet();

    unawaited(showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appColors.primary,
                      appColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final l10n = context.l10n;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.limitReachedTitle,
                        style: AppTextStyles.h3.copyWith(
                          color: appColors.neutralBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.limitReachedMessage,
                        style: AppTextStyles.body2.copyWith(
                          color: appColors.gray,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            unawaited(
                              context.push('/plans?source=invite_limit'),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: appColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.viewPlansButton,
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          l10n.notNow,
                          style: AppTextStyles.body2.copyWith(
                            color: appColors.gray,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _showInviteSheet(BuildContext context) {
    final cubit = context.read<PatientsCubit>();
    final state = cubit.state;

    final isPro = context.read<SubscriptionEntitlementCubit>().state.isPro;
    if (!isPro &&
        state.patients.length >= SubscriptionLimits.maxFreePatients) {
      _showUpgradeDialog(context);
      return;
    }

    if (state.inviteCode == null) {
      unawaited(cubit.generateInviteCode());
    }

    cubit.logInviteFlowOpen();

    unawaited(showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const _InviteBottomSheet(),
        );
      },
    ));
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.patientCount,
    required this.l10n,
    this.clinicianName,
    this.user,
    this.showSyncIndicator = false,
    this.isSynced = false,
    this.isSyncing = false,
    this.onSyncTap,
    this.onProfilePhotoTap,
  });

  final int patientCount;
  final AppLocalizations l10n;
  final String? clinicianName;
  final AuthUser? user;
  final bool showSyncIndicator;
  final bool isSynced;
  final bool isSyncing;
  final VoidCallback? onSyncTap;
  final VoidCallback? onProfilePhotoTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = _getGreeting(hour);
    final emoji = _getGreetingEmoji(hour);
    final firstName = _getFirstName(clinicianName);
    final title = firstName != null
        ? '$greeting $emoji, $firstName'
        : '$greeting $emoji';
    final subtitle = patientCount == 0
        ? l10n.noPatientsConnected
        : patientCount == 1
            ? l10n.onePatientConnected
            : l10n.patientsConnectedCount(patientCount);

    final avatar = user != null
        ? UserAvatar(user: user!, size: 48)
        : null;
    final leading = avatar != null && onProfilePhotoTap != null
        ? GestureDetector(
            onTap: onProfilePhotoTap,
            child: avatar,
          )
        : avatar ??
            Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appColors.primary,
                  appColors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 24,
            ),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.gray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.patientsHeaderYummyLogHint,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.gray.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (showSyncIndicator) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSyncing ? null : onSyncTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: isSyncing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: appColors.primary,
                          ),
                        )
                      : Icon(
                          isSynced
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          size: 20,
                          color: isSynced ? appColors.success : appColors.gray,
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  String _getGreetingEmoji(int hour) {
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌙';
  }

  String? _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    return fullName.trim().split(' ').first;
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: appColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: appColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.somethingWentWrong,
              style: AppTextStyles.h4.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            UiAutoWidthButton(
              text: l10n.tryAgain,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateNotLoggedIn extends StatelessWidget {
  const _EmptyStateNotLoggedIn({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _EmptyStateContent(showLoginHint: true, l10n: l10n);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onInvite, required this.l10n});

  final VoidCallback onInvite;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _EmptyStateContent(l10n: l10n);
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent({required this.l10n, this.showLoginHint = false});

  final bool showLoginHint;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    appColors.primary.withValues(alpha: 0.15),
                    appColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 44,
                    color: appColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.startFollowingTitle,
              style: AppTextStyles.h2.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              showLoginHint
                  ? l10n.startFollowingSubtitleLoggedOut
                  : l10n.startFollowingSubtitleLoggedIn,
              style: AppTextStyles.body1.copyWith(
                color: appColors.gray,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _FeatureCard(
              icon: Icons.restaurant_menu_rounded,
              title: l10n.featureViewMealsTitle,
              subtitle: l10n.featureViewMealsSubtitle,
              color: appColors.primary,
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.emoji_emotions_rounded,
              title: l10n.featureFollowFeelingsTitle,
              subtitle: l10n.featureFollowFeelingsSubtitle,
              color: appColors.secondary,
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.sync_rounded,
              title: l10n.featureRealtimeTitle,
              subtitle: l10n.featureRealtimeSubtitle,
              color: appColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.neutralSilver,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors.grayLight.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

class _PatientsList extends StatelessWidget {
  const _PatientsList({
    required this.patients,
    required this.onPatientTap,
    required this.onConfigFormTap,
    required this.onRemovePatient,
  });

  final List<Patient> patients;
  final void Function(Patient) onPatientTap;
  final void Function(Patient) onConfigFormTap;
  final void Function(Patient) onRemovePatient;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final patient = patients[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Dismissible(
            key: ValueKey(patient.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: appColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.actionRemove,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.person_remove_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              unawaited(HapticFeedback.mediumImpact());
              onRemovePatient(patient);
              return false;
            },
            child: _PatientCard(
              patient: patient,
              onTap: () => onPatientTap(patient),
              onConfigFormTap: () => onConfigFormTap(patient),
            ),
          ),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.onTap,
    required this.onConfigFormTap,
  });

  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onConfigFormTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      decoration: BoxDecoration(
        color: appColors.neutralSilver,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: appColors.grayLight.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _PatientAvatar(
                  photoUrl: patient.photoUrl,
                  appColors: appColors,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name.isEmpty
                            ? context.l10n.patientDefaultName
                            : patient.name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: appColors.neutralBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (patient.linkedAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: appColors.gray,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (ctx) {
                                final dateStr = DateFormat('dd/MM/yyyy')
                                    .format(patient.linkedAt!);
                                return Text(
                                  ctx.l10n.linkedSinceDate(dateStr),
                                  style: AppTextStyles.body3.copyWith(
                                    color: appColors.gray,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onConfigFormTap,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: appColors.grayDark,
                    size: 22,
                  ),
                  tooltip: context.l10n.formConfigButton,
                  style: IconButton.styleFrom(
                    backgroundColor: appColors.grayLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: appColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({
    required this.photoUrl,
    required this.appColors,
  });

  final String? photoUrl;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: appColors.grayLight.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: appColors.grayDark,
        size: 22,
      ),
    );

    if (photoUrl == null || photoUrl!.isEmpty) {
      return placeholder;
    }

    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        boxShadow: [
          BoxShadow(
            color: appColors.neutralBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: UiFixedButton(
        text: context.l10n.invitePatientButton,
        onPressed: onPressed,
      ),
    );
  }
}

class _InviteBottomSheet extends StatefulWidget {
  const _InviteBottomSheet();

  @override
  State<_InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<_InviteBottomSheet> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return BlocBuilder<PatientsCubit, PatientsState>(
      builder: (context, state) {
        final code = state.inviteCode ?? '------';
        final l10n = context.l10n;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: appColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.inviteCodeTitle,
                style: AppTextStyles.h3.copyWith(
                  color: appColors.neutralBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.inviteCodeSubtitle,
                style: AppTextStyles.body2.copyWith(color: appColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.inviteRequiresYummyLogApp,
                style: AppTextStyles.body3.copyWith(
                  color: appColors.gray.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _CodeField(
                code: code,
                onCopy: () => _copyCode(code),
                copied: _copied,
              ),
              const SizedBox(height: 20),
              if (_copied)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: appColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.codeCopied,
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _ShareOption(
                  icon: Icons.chat_bubble_rounded,
                  label: l10n.shareWhatsApp,
                  color: const Color(0xFF25D366),
                  onPressed: () => _shareVia('whatsapp', code),
                ),
                const SizedBox(height: 10),
                _ShareOption(
                  icon: Icons.sms_rounded,
                  label: l10n.shareSms,
                  color: appColors.primary,
                  onPressed: () => _shareVia('sms', code),
                ),
                const SizedBox(height: 10),
                _ShareOption(
                  icon: Icons.email_rounded,
                  label: l10n.shareEmail,
                  color: appColors.secondary,
                  onPressed: () => _shareVia('email', code),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    context.read<PatientsCubit>().logInviteShare(channel: 'copy');
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  Future<void> _shareVia(String method, String code) async {
    final l10n = context.l10n;
    final normalized = code
        .trim()
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '');
    if (normalized.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.inviteShareNeedValidCode),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final message = l10n.shareInviteMessage(normalized);
    final subject = l10n.shareInviteEmailSubject;

    final uri = switch (method) {
      'whatsapp' => Uri.parse(
          'https://wa.me/?text=${Uri.encodeComponent(message)}',
        ),
      'sms' => Uri.parse('sms:?body=${Uri.encodeComponent(message)}'),
      'email' => Uri(
          scheme: 'mailto',
          queryParameters: <String, String>{
            'subject': subject,
            'body': message,
          },
        ),
      _ => null,
    };

    if (uri == null) {
      await Share.share(message);
      if (!mounted) return;
      context.read<PatientsCubit>().logInviteShare(channel: method);
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        await Share.share(message);
      }
    } on Object {
      if (mounted) {
        await Share.share(message);
      }
    }
    if (!mounted) return;
    context.read<PatientsCubit>().logInviteShare(channel: method);
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.code,
    required this.onCopy,
    required this.copied,
  });

  final String code;
  final VoidCallback onCopy;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return GestureDetector(
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: appColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: AppTextStyles.h2.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 6,
                color: appColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                copied ? Icons.check_rounded : Icons.copy_rounded,
                color: appColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: appColors.grayLight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: appColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
