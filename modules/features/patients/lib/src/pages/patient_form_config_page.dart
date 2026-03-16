import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:patients_feature/src/cubit/form_config_cubit.dart';
import 'package:patients_feature/src/cubit/form_config_state.dart';
import 'package:patients_feature/src/data/behavior_form_config.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PatientFormConfigPage extends StatefulWidget {
  const PatientFormConfigPage({
    required this.patientId,
    this.patientName,
    super.key,
  });

  final String patientId;
  final String? patientName;

  @override
  State<PatientFormConfigPage> createState() => _PatientFormConfigPageState();
}

class _PatientFormConfigPageState extends State<PatientFormConfigPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<FormConfigCubit>().load(
        patientId: widget.patientId,
        patientName: widget.patientName ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final displayName = (widget.patientName?.isEmpty ?? true)
        ? l10n.patientDefaultName
        : widget.patientName!;

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: appColors.backgroundDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: appColors.neutralBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.formConfigTitle,
              style: AppTextStyles.h4.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.formConfigPatientSubtitle(displayName),
              style: AppTextStyles.body3.copyWith(color: appColors.gray),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: BlocListener<FormConfigCubit, FormConfigState>(
        listenWhen: (previous, current) =>
            previous.status == FormConfigStatus.saving &&
            current.status == FormConfigStatus.loaded,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.formConfigSaved),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: BlocBuilder<FormConfigCubit, FormConfigState>(
          builder: (context, state) {
          if (state.status == FormConfigStatus.loading ||
              state.status == FormConfigStatus.initial) {
            return Center(
              child: CircularProgressIndicator(color: appColors.primary),
            );
          }

          if (state.status == FormConfigStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.error ?? l10n.somethingWentWrong,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.read<FormConfigCubit>().load(
                            patientId: widget.patientId,
                            patientName: widget.patientName ?? '',
                          ),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          final config = state.config;
          final isSaving = state.status == FormConfigStatus.saving;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle global: habilitar seção de comportamento
                UiCard(
                  child: SwitchListTile(
                    value: config.sectionEnabled,
                    onChanged: (v) {
                      context
                          .read<FormConfigCubit>()
                          .setSectionEnabled(value: v);
                    },
                    title: Text(
                      l10n.formConfigSectionEnabled,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.neutralBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    activeThumbColor: appColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de comportamentos (MVP: 5)
                UiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          l10n.mealDetailBehaviors,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: appColors.neutralBlack,
                          ),
                        ),
                      ),
                      for (final behaviorId in kFormConfigBehaviorIds) ...[
                        Divider(
                          height: 1,
                          color: appColors.grayLight,
                        ),
                        SwitchListTile(
                          value: config.isBehaviorEnabled(behaviorId),
                          onChanged: (v) => context
                              .read<FormConfigCubit>()
                              .setBehaviorEnabled(behaviorId, value: v),
                          title: Text(
                            _behaviorLabel(behaviorId, l10n),
                            style: AppTextStyles.body2.copyWith(
                              color: appColors.neutralBlack,
                            ),
                          ),
                          activeThumbColor: appColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Log: última alteração
                _LastUpdatedSection(
                  config: config,
                  l10n: l10n,
                  appColors: appColors,
                ),
                const SizedBox(height: 16),

                // Histórico de alterações (expandível)
                _ChangeLogSection(
                  changeLog: config.changeLog,
                  l10n: l10n,
                  appColors: appColors,
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () => context.read<FormConfigCubit>().save(),
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? Text(
                          l10n.formConfigSaving,
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          l10n.formConfigSave,
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  static String _behaviorLabel(String behaviorId, AppLocalizations l10n) {
    return switch (behaviorId) {
      'hiddenFood' => l10n.behaviorHiddenFood,
      'regurgitated' => l10n.behaviorRegurgitated,
      'forcedVomit' => l10n.behaviorForcedVomit,
      'ateInSecret' => l10n.behaviorAteInSecret,
      'usedLaxatives' => l10n.behaviorUsedLaxatives,
      _ => behaviorId,
    };
  }
}

class _LastUpdatedSection extends StatelessWidget {
  const _LastUpdatedSection({
    required this.config,
    required this.l10n,
    required this.appColors,
  });

  final BehaviorFormConfig config;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final name = config.updatedByDisplayName ?? l10n.patientDefaultName;
    final date = config.updatedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(config.updatedAt!.toLocal())
        : '';

    if (config.updatedAt == null) {
      return UiCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.formConfigNoChangesYet,
            style: AppTextStyles.body3.copyWith(color: appColors.gray),
          ),
        ),
      );
    }

    return UiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.formConfigLastUpdated(name, date),
              style: AppTextStyles.body2.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeLogSection extends StatefulWidget {
  const _ChangeLogSection({
    required this.changeLog,
    required this.l10n,
    required this.appColors,
  });

  final List<FormConfigChangeLogEntry> changeLog;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  State<_ChangeLogSection> createState() => _ChangeLogSectionState();
}

class _ChangeLogSectionState extends State<_ChangeLogSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.changeLog.isEmpty) return const SizedBox.shrink();

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.l10n.formConfigChangeLogTitle,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.appColors.neutralBlack,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.appColors.gray,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: widget.appColors.grayLight),
            ...widget.changeLog.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.displayName ?? widget.l10n.patientDefaultName,
                          style: AppTextStyles.body2.copyWith(
                            color: widget.appColors.neutralBlack,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(e.at.toLocal()),
                        style: AppTextStyles.body3.copyWith(
                          color: widget.appColors.gray,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
