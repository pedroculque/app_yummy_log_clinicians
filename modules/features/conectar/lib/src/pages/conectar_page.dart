import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:conectar_feature/src/cubit/conectar_cubit.dart';
import 'package:conectar_feature/src/data/connected_clinician.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_foundation/sync_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

/// Tela Conectar: lista de clínicos, adicionar por código,
/// ver perfil e remover.
class ConectarPage extends StatelessWidget {
  const ConectarPage({required this.authRepository, super.key});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;
        if (!isLoggedIn) {
          return _LoginRequiredView(
            onGoToSettings: () => context.go('/settings'),
          );
        }
        return _ConnectForm(user: user);
      },
    );
  }
}

class _ConectarHeader extends StatelessWidget {
  const _ConectarHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: appColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.people_outline_rounded,
                size: 26,
                color: appColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myProfessionals,
                  style: AppTextStyles.h2.copyWith(
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.headerSubtitle,
                  style: AppTextStyles.body3.copyWith(color: appColors.gray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: appColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors.secondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: appColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.link_off_rounded,
              size: 36,
              color: appColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.emptyStateTitle,
            style: AppTextStyles.h3.copyWith(
              color: appColors.neutralBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyStateSubtitle,
            style: AppTextStyles.body2.copyWith(
              color: appColors.gray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView({required this.onGoToSettings});

  final VoidCallback onGoToSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _ConectarHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: UiCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: appColors.gray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.connectLoginRequired,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(
                            color: appColors.grayDark,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        UiFixedButton(
                          text: l10n.goToSettings,
                          onPressed: onGoToSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectForm extends StatelessWidget {
  const _ConnectForm({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ConectarCubit, ConectarState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null ||
              (prev.isLoading && !curr.isLoading && curr.errorMessage == null),
          listener: (context, state) {
            if (state.errorMessage != null) {
              uiSnackBar(
                context: context,
                message: state.errorMessage!,
                type: UiSnackbarType.error,
              );
              return;
            }
            uiSnackBar(
              context: context,
              message: l10n.connectSuccess,
              type: UiSnackbarType.success,
            );
          },
          builder: (context, state) {
            final hasConnections = state.connections.isNotEmpty;
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _ConectarHeader()),
                if (!hasConnections)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: _EmptyState(),
                    ),
                  ),
                if (hasConnections) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final clinician = state.connections[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ClinicianCard(
                              clinician: clinician,
                              onViewProfile: () => _showClinicianProfile(
                                context,
                                clinician,
                              ),
                            ),
                          );
                        },
                        childCount: state.connections.length,
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      l10n.addProfessional,
                      style: AppTextStyles.body3.copyWith(
                        color: appColors.gray,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverToBoxAdapter(
                    child: UiCard(
                      padding: const EdgeInsets.all(24),
                      child: _CodeField(
                        key: ValueKey(state.connections.length),
                        onConnect: (code) =>
                            context.read<ConectarCubit>().linkWithCode(code),
                        isLoading: state.isLoading,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showClinicianProfile(
    BuildContext context,
    ConnectedClinician clinician,
  ) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClinicianProfileSheet(
        clinician: clinician,
        onRemove: () {
          Navigator.of(ctx).pop();
          _showRemoveConfirmation(context, clinician.id);
        },
      ),
    ));
  }

  void _showRemoveConfirmation(BuildContext context, String clinicianId) {
    final l10n = context.l10n;
    final cubit = context.read<ConectarCubit>();
    unawaited(showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmRemoveClinician),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              unawaited(cubit.removeConnection(clinicianId));
            },
            child: Text(
              l10n.yes,
              style: TextStyle(
                color: AppColors.fromContext(ctx).error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _ClinicianCard extends StatelessWidget {
  const _ClinicianCard({
    required this.clinician,
    required this.onViewProfile,
  });

  final ConnectedClinician clinician;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    return UiCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: appColors.secondaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_rounded,
              color: appColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  clinician.displayName,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.neutralBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.professionHealthProfessional,
                  style: AppTextStyles.body3.copyWith(color: appColors.gray),
                ),
              ],
            ),
          ),
          UiAutoWidthButton(
            text: l10n.viewProfile,
            type: UiAutoWidthType.outline,
            size: UiAutoWidthSize.small,
            onPressed: onViewProfile,
          ),
        ],
      ),
    );
  }
}

class _ClinicianProfileSheet extends StatelessWidget {
  const _ClinicianProfileSheet({
    required this.clinician,
    required this.onRemove,
  });

  final ConnectedClinician clinician;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    final dateStr = DateFormat('dd/MM/yyyy').format(clinician.linkedAt);
    return Container(
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: appColors.gray),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Center(
              child: UiAvatar(
                imageUrl: clinician.photoUrl,
                size: UiAvatarSize.large,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              clinician.displayName,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.professionHealthProfessional,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
            ),
            if (clinician.crn != null) ...[
              const SizedBox(height: 4),
              Text(
                'CRN ${clinician.crn}',
                textAlign: TextAlign.center,
                style: AppTextStyles.body3.copyWith(color: appColors.gray),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.connectedSince(dateStr),
              textAlign: TextAlign.center,
              style: AppTextStyles.body3.copyWith(color: appColors.gray),
            ),
            if (clinician.bio != null && clinician.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                clinician.bio!,
                style: AppTextStyles.body2.copyWith(
                  color: appColors.grayDark,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (clinician.whatsapp != null || clinician.email != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (clinician.whatsapp != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: UiAutoWidthButton(
                        text: 'WhatsApp',
                        type: UiAutoWidthType.outline,
                        size: UiAutoWidthSize.small,
                        onPressed: () {},
                      ),
                    ),
                  if (clinician.email != null)
                    UiAutoWidthButton(
                      text: 'E-mail',
                      type: UiAutoWidthType.outline,
                      size: UiAutoWidthSize.small,
                      onPressed: () {},
                    ),
                ],
              ),
            const SizedBox(height: 24),
            UiFixedButton(
              text: l10n.removeClinician.toUpperCase(),
              onPressed: onRemove,
              type: UiFixedButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeField extends StatefulWidget {
  const _CodeField({
    required this.onConnect,
    required this.isLoading,
    super.key,
  });

  final void Function(String code) onConnect;
  final bool isLoading;

  @override
  State<_CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<_CodeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitCode(BuildContext context) {
    final raw = _controller.text;
    if (!ClinicianInviteCode.isValid(raw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.clinicianCodeInvalidLength)),
      );
      return;
    }
    widget.onConnect(ClinicianInviteCode.toStored(raw));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: l10n.healthProfessionalCode,
            hintText: l10n.healthProfessionalCodeHint,
            helperText: l10n.clinicianCodeHelper,
            filled: true,
            fillColor: appColors.grayLight.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appColors.grayLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appColors.grayLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          enabled: !widget.isLoading,
          textCapitalization: TextCapitalization.characters,
          maxLength: ClinicianInviteCode.length,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(ClinicianInviteCode.length),
          ],
        ),
        const SizedBox(height: 20),
        UiFixedButton(
          text: l10n.buttonConnect.toUpperCase(),
          onPressed: widget.isLoading
              ? null
              : () => _submitCode(context),
          isLoading: widget.isLoading,
        ),
      ],
    );
  }
}
