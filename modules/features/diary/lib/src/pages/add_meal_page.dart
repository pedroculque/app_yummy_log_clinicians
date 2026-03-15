import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:auth_foundation/auth_foundation.dart';
import 'package:diary_feature/src/cubit/diary_cubit.dart';
import 'package:diary_feature/src/domain/meal_entry.dart';
import 'package:diary_feature/src/l10n/meal_entry_labels.dart';
import 'package:diary_feature/src/util/meal_photo_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({
    required this.onSaved,
    this.initialEntry,
    this.forDate,
    super.key,
  });

  final VoidCallback onSaved;
  final MealEntry? initialEntry;
  /// Data do dia em que a refeição deve ser registrada
  /// (ex.: dia selecionado na timeline).
  /// Se null, usa a data/hora atual ao criar nova entrada.
  final DateTime? forDate;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

final List<FeelingLabel> _feelingOrder = [
  FeelingLabel.angry,
  FeelingLabel.sad,
  FeelingLabel.nothing,
  FeelingLabel.happy,
  FeelingLabel.proud,
];

class _AddMealPageState extends State<AddMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  MealType? _mealType;
  String? _whereAte;
  bool? _ateWithOthers;
  AmountEaten? _amountEaten;
  FeelingLabel? _feelingLabel;
  final _feelingTextController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _photoPath;
  bool _saving = false;
  late TimeOfDay _mealTime;
  bool? _hiddenFood;
  bool? _regurgitated;
  bool? _forcedVomit;
  bool? _ateInSecret;
  bool? _usedLaxatives;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEntry;
    if (e != null) {
      _mealType = e.mealType;
      _mealTime = TimeOfDay.fromDateTime(e.dateTime);
      _whereAte = _normalizeWhereAteKey(e.whereAte);
      _ateWithOthers = e.ateWithOthers;
      _amountEaten = e.amountEaten;
      _feelingLabel = e.feelingLabel;
      _feelingTextController.text = e.feelingText ?? '';
      _descriptionController.text = e.description ?? '';
      _hiddenFood = e.hiddenFood;
      _regurgitated = e.regurgitated;
      _forcedVomit = e.forcedVomit;
      _ateInSecret = e.ateInSecret;
      _usedLaxatives = e.usedLaxatives;
      if (e.photoPath != null && e.photoPath!.isNotEmpty) {
        unawaited(_resolveExistingPhoto(e.photoPath!));
      }
    } else {
      _mealType = null;
      _mealTime = TimeOfDay.now();
    }
  }

  Future<void> _resolveExistingPhoto(String photoPath) async {
    final resolved = await resolvePhotoPath(photoPath);
    if (mounted) setState(() => _photoPath = resolved);
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() => _photoPath = xFile.path);
    }
  }

  static const _whereAteKeys = ['home', 'work', 'restaurant', 'other'];
  static String? _normalizeWhereAteKey(String? s) {
    if (s == null || s.isEmpty) return null;
    return _whereAteKeys.contains(s) ? s : null;
  }

  void _showPhotoSourceSheet(BuildContext context, AppLocalizations l10n) {
    final appColors = AppColors.fromContext(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
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
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: appColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.takePhoto,
                    style: AppTextStyles.body1.copyWith(
                      color: appColors.neutralBlack,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    unawaited(_pickImage(ImageSource.camera));
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: appColors.secondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.chooseFromGallery,
                    style: AppTextStyles.body1.copyWith(
                      color: appColors.neutralBlack,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    unawaited(_pickImage(ImageSource.gallery));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feelingTextController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Data/hora para a entrada usando o horário selecionado pelo usuário.
  DateTime _effectiveEntryDate() {
    final existing = widget.initialEntry;
    final forDate = widget.forDate;
    
    // Se editando, usa a data original mas com o horário selecionado
    if (existing != null) {
      return DateTime(
        existing.dateTime.year,
        existing.dateTime.month,
        existing.dateTime.day,
        _mealTime.hour,
        _mealTime.minute,
      );
    }
    
    // Se criando nova entrada com data específica
    if (forDate != null) {
      return DateTime(
        forDate.year,
        forDate.month,
        forDate.day,
        _mealTime.hour,
        _mealTime.minute,
      );
    }
    
    // Caso padrão: hoje com horário selecionado
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _mealTime.hour,
      _mealTime.minute,
    );
  }

  Future<void> _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _mealTime,
    );
    if (picked != null && mounted) {
      setState(() => _mealTime = picked);
    }
  }

  /// Valida apenas os campos obrigatórios: tipo de refeição, onde comeu,
  /// acompanhado. Foto, hora, descrição e comportamento são opcionais.
  String? _validateRequiredFields(AppLocalizations l10n) {
    if (_mealType == null) return l10n.validationMealTypeRequired;
    if (_whereAte == null || _whereAte!.isEmpty) {
      return l10n.validationWhereAteRequired;
    }
    if (_ateWithOthers == null) return l10n.validationAteWithOthersRequired;
    return null;
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = context.l10n;
    final validationError = _validateRequiredFields(l10n);
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = widget.initialEntry;
      final entryId =
          existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      String? resolvedPhotoPath;
      if (_photoPath != null && _photoPath!.isNotEmpty) {
        resolvedPhotoPath =
            await copyToPersistentStorage(_photoPath!, entryId);
      }
      if (!mounted) return;
      final dateTime = _effectiveEntryDate();
      final currentUserId = GetIt.I<AuthRepository>().currentUser?.uid;
      final entry = MealEntry(
        id: entryId,
        mealType: _mealType!,
        dateTime: dateTime,
        userId: currentUserId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        feelingLabel: _feelingLabel,
        feelingText: _feelingTextController.text.trim().isEmpty
            ? null
            : _feelingTextController.text.trim(),
        whereAte: _whereAte?.isEmpty ?? true ? null : _whereAte,
        ateWithOthers: _ateWithOthers,
        amountEaten: _amountEaten,
        photoPath: resolvedPhotoPath,
        hiddenFood: _hiddenFood,
        regurgitated: _regurgitated,
        forcedVomit: _forcedVomit,
        ateInSecret: _ateInSecret,
        usedLaxatives: _usedLaxatives,
      );
      await context.read<DiaryCubit>().save(entry);
      if (!mounted) return;
      widget.onSaved();
      if (!mounted) return;
      context.pop(entryId);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final isEditing = widget.initialEntry != null;

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // --- APP BAR ---
            SliverAppBar(
              pinned: true,
              backgroundColor: appColors.backgroundDefault,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: const SizedBox.shrink(),
              leadingWidth: 0,
              title: Text(
                isEditing ? l10n.editMeal : l10n.addMeal,
                style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.grayLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      color: appColors.grayDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // --- CONTENT ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // FOTO
                  _buildPhotoSection(context, appColors, l10n),

                  // DESCRIÇÃO (só se não tem foto)
                  if (_photoPath == null || _photoPath!.isEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionHeader(
                      icon: Icons.edit_note_rounded,
                      title: l10n.sectionDescribeWhatAte,
                    ),
                    const SizedBox(height: 10),
                    UiMultiLineTextInput(
                      hintText: l10n.describeWhatAteHint,
                      controller: _descriptionController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  // HORÁRIO DA REFEIÇÃO
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.access_time_rounded,
                    title: l10n.sectionMealTime,
                  ),
                  const SizedBox(height: 10),
                  _buildTimeSelector(appColors),

                  // TIPO DE REFEIÇÃO
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.restaurant_rounded,
                    title: l10n.sectionWhichMeal,
                  ),
                  const SizedBox(height: 10),
                  _buildMealTypeGrid(l10n, appColors),

                  // ONDE COMEU
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.place_outlined,
                    title: l10n.sectionWhereAte,
                  ),
                  const SizedBox(height: 10),
                  _buildWhereAteChips(appColors, l10n),

                  // ACOMPANHADO
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.people_outline_rounded,
                    title: l10n.sectionAteWithOthers,
                  ),
                  const SizedBox(height: 10),
                  _buildYesNoRow(
                    appColors: appColors,
                    l10n: l10n,
                    value: _ateWithOthers,
                    onChanged: ({required value}) =>
                        setState(() => _ateWithOthers = value),
                  ),

                  // QUANTO COMEU
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.pie_chart_outline_rounded,
                    title: l10n.sectionHowMuch,
                  ),
                  const SizedBox(height: 10),
                  _buildAmountSelector(appColors, l10n),

                  // SENTIMENTO
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.emoji_emotions_outlined,
                    title: l10n.sectionHowFelt,
                  ),
                  const SizedBox(height: 14),
                  _buildFeelingSelector(appColors, l10n),

                  // TEXTO SOBRE SENTIMENTO
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.sectionFeelingText,
                  ),
                  const SizedBox(height: 10),
                  UiMultiLineTextInput(
                    hintText: l10n.feelingTextHint,
                    controller: _feelingTextController,
                    onChanged: (_) => setState(() {}),
                  ),

                  // PERGUNTAS COMPORTAMENTAIS
                  const SizedBox(height: 32),
                  _buildBehaviorSection(appColors, l10n),

                  // BOTÃO SALVAR
                  const SizedBox(height: 36),
                  UiFixedButton(
                    text: _saving
                        ? l10n.saving
                        : (isEditing
                            ? l10n.buttonSaveChanges
                            : l10n.buttonAddMeal),
                    onPressed: _saving ? null : () => unawaited(_submit()),
                    isLoading: _saving,
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOTO
  // ---------------------------------------------------------------------------

  Widget _buildPhotoSection(
    BuildContext context,
    AppColors appColors,
    AppLocalizations l10n,
  ) {
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_photoPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Material(
                  color: appColors.neutralBlack.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _showPhotoSourceSheet(context, l10n),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: appColors.neutralWhite,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.changePhoto,
                            style: AppTextStyles.body3.copyWith(
                              color: appColors.neutralWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPhotoSourceSheet(context, l10n),
        borderRadius: BorderRadius.circular(16),
        splashColor: appColors.primary.withValues(alpha: 0.08),
        highlightColor: appColors.primary.withValues(alpha: 0.04),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: appColors.primary.withValues(alpha: 0.35),
            borderRadius: 16,
          ),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: appColors.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appColors.primary.withValues(alpha: 0.15),
                        appColors.secondary.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: appColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.sendPhoto,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.sendPhotoHint,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TIME SELECTOR
  // ---------------------------------------------------------------------------

  Widget _buildTimeSelector(AppColors appColors) {
    final formattedTime = _mealTime.format(context);
    return GestureDetector(
      onTap: _showTimePicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: appColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 22,
              color: appColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              formattedTime,
              style: AppTextStyles.body1.copyWith(
                color: appColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_rounded,
              size: 16,
              color: appColors.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MEAL TYPE GRID
  // ---------------------------------------------------------------------------

  Widget _buildMealTypeGrid(AppLocalizations l10n, AppColors appColors) {
    const types = MealType.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((t) {
        final isSelected = _mealType == t;
        return GestureDetector(
          onTap: () => setState(() => _mealType = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? appColors.primary.withValues(alpha: 0.1)
                  : appColors.grayLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? appColors.primary
                    : appColors.grayLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              mealTypeLabel(t, l10n),
              style: AppTextStyles.body2.copyWith(
                color: isSelected ? appColors.primary : appColors.grayDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // WHERE ATE (chips instead of dropdown)
  // ---------------------------------------------------------------------------

  Widget _buildWhereAteChips(AppColors appColors, AppLocalizations l10n) {
    final options = <(String key, String label, IconData icon)>[
      ('home', l10n.whereAteHome, Icons.home_outlined),
      ('work', l10n.whereAteWork, Icons.work_outline_rounded),
      ('restaurant', l10n.whereAteRestaurant, Icons.restaurant_outlined),
      ('other', l10n.whereAteOther, Icons.more_horiz_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = _whereAte == o.$1;
        return GestureDetector(
          onTap: () => setState(() => _whereAte = o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? appColors.secondary.withValues(alpha: 0.1)
                  : appColors.grayLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? appColors.secondary
                    : appColors.grayLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  o.$3,
                  size: 18,
                  color:
                      isSelected ? appColors.secondary : appColors.gray,
                ),
                const SizedBox(width: 6),
                Text(
                  o.$2,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected
                        ? appColors.secondary
                        : appColors.grayDark,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // AMOUNT SELECTOR (chips instead of slider)
  // ---------------------------------------------------------------------------

  Widget _buildAmountSelector(AppColors appColors, AppLocalizations l10n) {
    const values = AmountEaten.values;
    return Row(
      children: values.map((a) {
        final isSelected = _amountEaten == a;
        final isFirst = a == values.first;
        final isLast = a == values.last;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _amountEaten = a),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? appColors.primary.withValues(alpha: 0.12)
                    : appColors.grayLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.horizontal(
                  left: isFirst
                      ? const Radius.circular(10)
                      : Radius.zero,
                  right: isLast
                      ? const Radius.circular(10)
                      : Radius.zero,
                ),
                border: Border.all(
                  color: isSelected
                      ? appColors.primary
                      : appColors.grayLight,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  amountEatenLabel(a, l10n),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body3.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? appColors.primary
                        : appColors.grayDark,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // FEELING SELECTOR
  // ---------------------------------------------------------------------------

  Color _feelingColor(FeelingLabel f, AppColors appColors) {
    return switch (f) {
      FeelingLabel.angry => appColors.error,
      FeelingLabel.sad => appColors.error,
      FeelingLabel.nothing => appColors.alert,
      FeelingLabel.happy => appColors.success,
      FeelingLabel.proud => appColors.success,
    };
  }

  UiIcons _feelingIcon(FeelingLabel f) {
    return switch (f) {
      FeelingLabel.angry => UiIcons.feelingAngry,
      FeelingLabel.sad => UiIcons.feelingSad,
      FeelingLabel.nothing => UiIcons.feelingNothing,
      FeelingLabel.happy => UiIcons.feelingHappy,
      FeelingLabel.proud => UiIcons.feelingPride,
    };
  }

  Widget _buildFeelingSelector(AppColors appColors, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _feelingOrder.map((f) {
        final isSelected = _feelingLabel == f;
        final color = _feelingColor(f, appColors);
        return GestureDetector(
          onTap: () => setState(() => _feelingLabel = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : appColors.grayLight.withValues(alpha: 0.6),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: UiIcon(
                      _feelingIcon(f),
                      size: 28,
                      color: isSelected ? color : appColors.gray,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  feelingLabel(f, l10n),
                  style: AppTextStyles.body3.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : appColors.gray,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // BEHAVIOR QUESTIONS (grouped in a card)
  // ---------------------------------------------------------------------------

  Widget _buildBehaviorSection(AppColors appColors, AppLocalizations l10n) {
    final questions = <(
      String label,
      bool? value,
      void Function({bool? value}) onChanged,
    )>[
      (
        l10n.questionHiddenFood,
        _hiddenFood,
        ({bool? value}) => setState(() => _hiddenFood = value),
      ),
      (
        l10n.questionRegurgitated,
        _regurgitated,
        ({bool? value}) => setState(() => _regurgitated = value),
      ),
      (
        l10n.questionForcedVomit,
        _forcedVomit,
        ({bool? value}) => setState(() => _forcedVomit = value),
      ),
      (
        l10n.questionAteInSecret,
        _ateInSecret,
        ({bool? value}) => setState(() => _ateInSecret = value),
      ),
      (
        l10n.questionUsedLaxatives,
        _usedLaxatives,
        ({bool? value}) => setState(() => _usedLaxatives = value),
      ),
    ];

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 20,
                color: appColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.questionHiddenFood.split('?').first.contains(' ')
                      ? 'Comportamento'
                      : 'Comportamento',
                  style: AppTextStyles.h5.copyWith(color: appColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < questions.length; i++) ...[
            if (i > 0) ...[
              Divider(
                height: 24,
                color: appColors.grayLight,
              ),
            ],
            _BehaviorQuestion(
              label: questions[i].$1,
              value: questions[i].$2,
              yesLabel: l10n.yes,
              noLabel: l10n.no,
              onChanged: questions[i].$3,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // YES / NO CHIPS
  // ---------------------------------------------------------------------------

  Widget _buildYesNoRow({
    required AppColors appColors,
    required AppLocalizations l10n,
    required bool? value,
    required void Function({required bool? value}) onChanged,
  }) {
    return Row(
      children: [
        _YesNoChip(
          label: l10n.yes,
          selected: value == true,
          onTap: () => onChanged(value: true),
        ),
        const SizedBox(width: 10),
        _YesNoChip(
          label: l10n.no,
          selected: value == false,
          onTap: () => onChanged(value: false),
        ),
      ],
    );
  }
}

// =============================================================================
// EXTRACTED WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: appColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: appColors.neutralBlack,
            ),
          ),
        ),
      ],
    );
  }
}

class _YesNoChip extends StatelessWidget {
  const _YesNoChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? appColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? appColors.primary : appColors.grayLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? appColors.primary : appColors.gray,
          ),
        ),
      ),
    );
  }
}

class _BehaviorQuestion extends StatelessWidget {
  const _BehaviorQuestion({
    required this.label,
    required this.value,
    required this.yesLabel,
    required this.noLabel,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final String yesLabel;
  final String noLabel;
  final void Function({bool? value}) onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: appColors.grayDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _YesNoChip(
              label: yesLabel,
              selected: value == true,
              onTap: () => onChanged(value: true),
            ),
            const SizedBox(width: 10),
            _YesNoChip(
              label: noLabel,
              selected: value == false,
              onTap: () => onChanged(value: false),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  static const double _dashWidth = 6;
  static const double _dashGap = 4;
  static const double _strokeWidth = 1.5;

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    var distance = 0.0;

    while (distance < totalLength) {
      final end = math.min(distance + _dashWidth, totalLength);
      canvas.drawPath(
        metrics.extractPath(distance, end),
        paint,
      );
      distance = end + _dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius;
}
