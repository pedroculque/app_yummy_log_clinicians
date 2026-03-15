import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patients_feature/src/cubit/patients_cubit.dart';
import 'package:patients_feature/src/cubit/patients_state.dart';
import 'package:patients_feature/src/data/patient.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui_kit/ui_kit.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  @override
  void initState() {
    super.initState();
    _loadIfLoggedIn();
  }

  void _loadIfLoggedIn() {
    final authRepo = context.read<AuthRepository>();
    if (authRepo.currentUser != null) {
      unawaited(context.read<PatientsCubit>().load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data != null;

        return Scaffold(
          body: SafeArea(
            child: isLoggedIn
                ? _buildLoggedInContent()
                : _buildLoggedOutContent(),
          ),
        );
      },
    );
  }

  Widget _buildLoggedOutContent() {
    return Column(
      children: [
        const Expanded(
          child: _EmptyStateNotLoggedIn(),
        ),
        _InviteButton(onPressed: () => _requestLogin(context)),
      ],
    );
  }

  Widget _buildLoggedInContent() {
    return BlocBuilder<PatientsCubit, PatientsState>(
      builder: (context, state) {
        if (state.status == PatientsStatus.initial) {
          unawaited(context.read<PatientsCubit>().load());
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PatientsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PatientsStatus.error) {
          return Center(
            child: Text(
              state.error ?? 'Erro ao carregar pacientes',
              style: AppTextStyles.body1,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: state.isEmpty
                  ? _EmptyState(onInvite: () => _showInviteSheet(context))
                  : _PatientsList(
                      patients: state.patients,
                      onPatientTap: _onPatientTap,
                    ),
            ),
            _InviteButton(onPressed: () => _showInviteSheet(context)),
          ],
        );
      },
    );
  }

  void _onPatientTap(Patient patient) {
    // TODO(clinicians): Navigate to patient diary
  }

  void _requestLogin(BuildContext context) {
    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final appColors = AppColors.fromContext(dialogContext);
        return AlertDialog(
          title: const Text('Login necessário'),
          content: const Text(
            'Para convidar pacientes, você precisa fazer login primeiro.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: appColors.gray),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _goToSettings(context);
              },
              child: const Text('Ir para Configurações'),
            ),
          ],
        );
      },
    ));
  }

  void _goToSettings(BuildContext context) {
    context.go('/settings');
  }

  void _showInviteSheet(BuildContext context) {
    final cubit = context.read<PatientsCubit>();
    final state = cubit.state;

    if (state.inviteCode == null) {
      unawaited(cubit.generateInviteCode());
    }

    unawaited(showModalBottomSheet<void>(
      context: context,
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

class _EmptyStateNotLoggedIn extends StatelessWidget {
  const _EmptyStateNotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return const _EmptyStateContent(
      showLoginHint: true,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onInvite});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return const _EmptyStateContent();
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent({
    this.showLoginHint = false,
  });

  final bool showLoginHint;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: appColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline_rounded,
                    size: 40,
                    color: appColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum paciente ainda',
              style: AppTextStyles.h3.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              showLoginHint
                  ? 'Convide seus pacientes para acompanhar o diário '
                    'alimentar deles em tempo real.'
                  : 'Convide seus pacientes usando o botão abaixo e '
                    'acompanhe o diário alimentar deles.',
              style: AppTextStyles.body1.copyWith(
                color: appColors.gray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeatureChip(
                  icon: Icons.visibility_outlined,
                  label: 'Visualize refeições',
                  color: appColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeatureChip(
                  icon: Icons.emoji_emotions_outlined,
                  label: 'Acompanhe sentimentos',
                  color: appColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeatureChip(
                  icon: Icons.sync_outlined,
                  label: 'Sincronizado em tempo real',
                  color: appColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              color: appColors.neutralBlack,
              fontWeight: FontWeight.w500,
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
  });

  final List<Patient> patients;
  final void Function(Patient) onPatientTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final patient = patients[index];
        return _PatientCard(
          patient: patient,
          onTap: () => onPatientTap(patient),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return UiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: appColors.primary.withValues(alpha: 0.1),
              backgroundImage: patient.photoUrl != null
                  ? NetworkImage(patient.photoUrl!)
                  : null,
              child: patient.photoUrl == null
                  ? Icon(Icons.person, color: appColors.primary, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (patient.age != null || patient.linkedAt != null)
                    Text(
                      _buildSubtitle(),
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.gray,
                      ),
                    ),
                  if (patient.condition != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      patient.condition!,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.gray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            UiAutoWidthButton(
              text: 'ACOMPANHAR',
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (patient.age != null) {
      parts.add('${patient.age} anos');
    }
    if (patient.linkedAt != null) {
      final date = patient.linkedAt!;
      parts.add(
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}',
      );
    }
    return parts.join(' • ');
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: UiFixedButton(
        text: 'CONVIDAR PACIENTE',
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
              const SizedBox(height: 24),
              Text(
                'Para convidar o paciente, envie o link abaixo ou '
                'crie um convite pelos serviços de mensagens ou e-mail.',
                style: AppTextStyles.body1.copyWith(color: appColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _CodeField(
                code: code,
                onCopy: () => _copyCode(code),
              ),
              const SizedBox(height: 16),
              if (_copied)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Copiado com sucesso!',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                _ShareButton(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  onPressed: () => _shareVia('sms', code),
                ),
                const SizedBox(height: 12),
                _ShareButton(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  onPressed: () => _shareVia('whatsapp', code),
                ),
                const SizedBox(height: 12),
                _ShareButton(
                  icon: Icons.email_outlined,
                  label: 'E-mail',
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
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  Future<void> _shareVia(String method, String code) async {
    final message = 'Use o código $code para se conectar comigo no YummyLog!';

    await Share.share(message);
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.code,
    required this.onCopy,
  });

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.gray.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: AppTextStyles.h4.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: appColors.gray),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: appColors.gray.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: appColors.neutralBlack),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.body1.copyWith(color: appColors.neutralBlack),
          ),
        ],
      ),
    );
  }
}
