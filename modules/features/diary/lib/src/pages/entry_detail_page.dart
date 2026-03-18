import 'dart:async';

import 'package:diary_feature/src/cubit/entry_detail_cubit.dart';
import 'package:diary_feature/src/l10n/meal_entry_labels.dart';
import 'package:diary_feature/src/util/meal_photo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:meal_domain/meal_domain.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class EntryDetailPage extends StatelessWidget {
  const EntryDetailPage({
    required this.entryId,
    required this.onUpdated,
    super.key,
  });

  final String entryId;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntryDetailCubit, EntryDetailState>(
      builder: (context, state) {
        if (state.loading) {
          return _LoadingView(entryId: entryId);
        }
        if (state.error != null && state.error!.isNotEmpty) {
          return _ErrorView(
            entryId: entryId,
            message: state.error!,
            onRetry: () => context.read<EntryDetailCubit>().load(),
          );
        }
        if (state.entry == null) {
          return _NotFoundView(entryId: entryId);
        }
        return _DetailContent(
          entry: state.entry!,
          onUpdated: onUpdated,
        );
      },
    );
  }
}

// =============================================================================
// LOADING / ERROR / NOT FOUND
// =============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: _buildAppBar(context),
      body: Center(
        child: CircularProgressIndicator(color: appColors.primary),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.entryId,
    required this.message,
    required this.onRetry,
  });
  final String entryId;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: _buildAppBar(context),
      body: Center(
        child: UiErrorState(
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: _buildAppBar(context),
      body: Center(
        child: UiEmptyState(
          title: l10n.entryNotFound,
          icon: Icons.search_off_rounded,
          action: UiAutoWidthButton(
            text: l10n.back,
            type: UiAutoWidthType.outline,
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

AppBar _buildAppBar(BuildContext context) {
  final appColors = AppColors.fromContext(context);
  return AppBar(
    backgroundColor: appColors.backgroundDefault,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    leadingWidth: 48,
    title: const SizedBox.shrink(),
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: IconButton(
        onPressed: () => context.pop(),
        tooltip: '',
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: appColors.grayDark,
        ),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: appColors.grayDark,
          size: 24,
        ),
      ),
    ),
  );
}

// =============================================================================
// DETAIL CONTENT
// =============================================================================

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.entry,
    required this.onUpdated,
  });

  final MealEntry entry;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final e = entry;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat.yMMMMd(locale).format(e.dateTime);
    final timeStr = DateFormat.Hm().format(e.dateTime);
    final hasPhoto = (e.photoPath != null && e.photoPath!.isNotEmpty) ||
        (e.photoUrl != null && e.photoUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: CustomScrollView(
        slivers: [
          // --- APP BAR ---
          SliverAppBar(
            pinned: true,
            backgroundColor: appColors.backgroundDefault,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 48,
            title: const SizedBox.shrink(),
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                onPressed: () => context.pop(),
                tooltip: '',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: appColors.grayDark,
                ),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: appColors.grayDark,
                  size: 24,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () async {
                    await context.push(
                      '/diary/entry/${e.id}/edit',
                      extra: e,
                    );
                    if (!context.mounted) return;
                    onUpdated();
                    unawaited(context.read<EntryDetailCubit>().load());
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: appColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    Icons.edit_rounded,
                    color: appColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // --- CONTENT ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // FOTO
                if (hasPhoto) ...[
                  _buildPhoto(e.photoPath, e.photoUrl, appColors),
                  const SizedBox(height: 24),
                ],

                // TÍTULO + DATA/HORA
                _buildHeader(
                  appColors,
                  l10n,
                  e,
                  dateStr,
                  timeStr,
                ),
                const SizedBox(height: 24),

                // INFORMAÇÕES PRINCIPAIS
                UiCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.restaurant_rounded,
                        iconColor: appColors.primary,
                        label: l10n.labelMeal,
                        value: mealTypeLabel(e.mealType, l10n),
                      ),
                      if (e.whereAte != null && e.whereAte!.isNotEmpty) ...[
                        _tileDivider(appColors),
                        _InfoTile(
                          icon: Icons.place_outlined,
                          iconColor: appColors.secondary,
                          label: l10n.labelWhereAte,
                          value: whereAteDisplay(e.whereAte, l10n),
                        ),
                      ],
                      if (e.ateWithOthers != null) ...[
                        _tileDivider(appColors),
                        _InfoTile(
                          icon: Icons.people_outline_rounded,
                          iconColor: appColors.alert,
                          label: l10n.labelAteWithOthers,
                          value: e.ateWithOthers! ? l10n.yes : l10n.no,
                        ),
                      ],
                      if (e.amountEaten != null) ...[
                        _tileDivider(appColors),
                        _InfoTile(
                          icon: Icons.pie_chart_outline_rounded,
                          iconColor: appColors.success,
                          label: l10n.labelHowMuch,
                          value: amountEatenLabel(e.amountEaten!, l10n),
                        ),
                      ],
                    ],
                  ),
                ),

                // SENTIMENTO
                if (e.feelingLabel != null) ...[
                  const SizedBox(height: 20),
                  _buildFeelingCard(appColors, l10n, e),
                ],

                // DESCRIÇÃO
                if (e.description != null &&
                    e.description!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTextCard(
                    appColors: appColors,
                    icon: Icons.edit_note_rounded,
                    iconColor: appColors.primary,
                    title: l10n.sectionDescribeWhatAte,
                    text: e.description!,
                  ),
                ],

                // TEXTO SOBRE SENTIMENTO
                if (e.feelingText != null &&
                    e.feelingText!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTextCard(
                    appColors: appColors,
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: appColors.secondary,
                    title: l10n.labelAboutFeeling,
                    text: e.feelingText!,
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String? photoPath, String? photoUrl, AppColors appColors) {
    return MealPhoto(
      photoPath: photoPath,
      photoUrl: photoUrl,
      height: 220,
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _buildHeader(
    AppColors appColors,
    AppLocalizations l10n,
    MealEntry e,
    String dateStr,
    String timeStr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealTypeLabel(e.mealType, l10n),
          style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: appColors.gray,
            ),
            const SizedBox(width: 6),
            Text(
              dateStr,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: appColors.gray,
            ),
            const SizedBox(width: 6),
            Text(
              timeStr,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeelingCard(
    AppColors appColors,
    AppLocalizations l10n,
    MealEntry e,
  ) {
    final f = e.feelingLabel!;
    final color = switch (f) {
      FeelingLabel.angry => appColors.error,
      FeelingLabel.sad => appColors.error,
      FeelingLabel.nothing => appColors.alert,
      FeelingLabel.happy => appColors.success,
      FeelingLabel.proud => appColors.success,
    };
    final uiIcon = switch (f) {
      FeelingLabel.sad => UiIcons.feelingSad,
      FeelingLabel.nothing => UiIcons.feelingNothing,
      FeelingLabel.happy => UiIcons.feelingHappy,
      FeelingLabel.proud => UiIcons.feelingPride,
      FeelingLabel.angry => UiIcons.feelingAngry,
    };

    return UiCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: UiIcon(uiIcon, size: 26, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.labelFeeling,
                style: AppTextStyles.body3.copyWith(color: appColors.gray),
              ),
              const SizedBox(height: 2),
              Text(
                feelingLabel(f, l10n),
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard({
    required AppColors appColors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body3.copyWith(
                  color: appColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: AppTextStyles.body1.copyWith(
              height: 1.5,
              color: appColors.grayDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileDivider(AppColors appColors) {
    return Divider(
      height: 1,
      indent: 56,
      color: appColors.grayLight,
    );
  }
}

// =============================================================================
// INFO TILE
// =============================================================================

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w500,
              color: appColors.neutralBlack,
            ),
          ),
        ],
      ),
    );
  }
}
