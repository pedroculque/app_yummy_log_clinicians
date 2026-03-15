import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:diary_feature/src/cubit/diary_cubit.dart';
import 'package:diary_feature/src/domain/meal_entry.dart';
import 'package:diary_feature/src/l10n/meal_entry_labels.dart';
import 'package:diary_feature/src/util/meal_photo_storage.dart';
import 'package:diary_feature/src/util/meal_photo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sync_foundation/sync_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({
    super.key,
    this.authStateStream,
  });

  final Stream<AuthUser?>? authStateStream;

  @override
  Widget build(BuildContext context) {
    return _DiaryView(authStateStream: authStateStream);
  }
}

class _DiaryView extends StatefulWidget {
  const _DiaryView({this.authStateStream});

  final Stream<AuthUser?>? authStateStream;

  @override
  State<_DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<_DiaryView> {
  late DateTime _selectedDate;
  bool _showCalendarView = false;
  late DateTime _displayedMonth;
  String? _highlightEntryId;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month);
    unawaited(getDocsDir());
  }

  Future<void> _openAddMeal() async {
    final result = await context.push<Object?>(
      '/diary/add',
      extra: _selectedDate,
    );
    if (!mounted) return;
    if (result is String) {
      setState(() => _highlightEntryId = result);
      Future<void>.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _highlightEntryId = null);
      });
    }
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
      _displayedMonth = DateTime(now.year, now.month);
      _showCalendarView = false;
    });
  }

  void _showCalendar() {
    setState(() {
      _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
      _showCalendarView = true;
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDate = day;
      _showCalendarView = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  void _hideCalendar() {
    setState(() => _showCalendarView = false);
  }

  Future<void> _showConfirmDelete(
    BuildContext context,
    MealEntry entry,
  ) async {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    final cubit = context.read<DiaryCubit>();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
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
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: appColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: appColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.confirmDeleteEntry,
                style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
              ),
              const SizedBox(height: 24),
              UiFixedButton(
                text: l10n.yes,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 10),
              UiFixedButton(
                text: l10n.no,
                type: UiFixedButtonType.outline,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || confirmed != true) return;
    await cubit.deleteEntry(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: _showCalendarView
          ? AppBar(
              backgroundColor: appColors.backgroundDefault,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 56,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(
                      Icons.view_agenda_outlined,
                      color: appColors.grayDark,
                    ),
                    onPressed: _hideCalendar,
                    tooltip: l10n.viewDayList,
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.grayLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          if (state.loading && state.entries.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: appColors.primary),
            );
          }

          final byDay = _groupByDay(state.entries);
          final daysWithEntries = byDay.keys.toSet();
          final entriesForSelected = byDay[_selectedDate] ?? [];

          if (_showCalendarView) {
            return _CalendarMonthView(
              displayedMonth: _displayedMonth,
              selectedDate: _selectedDate,
              daysWithEntries: daysWithEntries,
              entriesByDay: byDay,
              today: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              locale: locale,
              onSelectDay: _selectDay,
              onToday: _goToToday,
              onPrevMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onAddMeal: _openAddMeal,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<AuthUser?>(
                stream: widget.authStateStream,
                builder: (context, snapshot) => _DiaryHeader(
                  greeting: l10n.greeting,
                  user: snapshot.data,
                ),
              ),
              _DayStrip(
                selectedDate: _selectedDate,
                locale: locale,
                onSelectDay: (d) {
                  unawaited(HapticFeedback.lightImpact());
                  setState(() {
                    _selectedDate = d;
                    _displayedMonth = DateTime(d.year, d.month);
                  });
                },
                onCalendarTap: _showCalendar,
                onToday: _goToToday,
              ),
              Expanded(
                child: entriesForSelected.isEmpty
                    ? _EmptyDayState(onAddMeal: _openAddMeal)
                    : RefreshIndicator(
                        onRefresh: () async {
                          debugPrint('[DiaryPage] Pull-to-refresh triggered');
                          final syncCubit = context.read<SyncCubit>();
                          final diaryCubit = context.read<DiaryCubit>();
                          debugPrint('[DiaryPage] Calling forceSync...');
                          await syncCubit.forceSync();
                          debugPrint('[DiaryPage] forceSync done, reloading');
                          await diaryCubit.load();
                          debugPrint('[DiaryPage] DiaryCubit.load() done');
                        },
                        color: appColors.primary,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: ListView.builder(
                            key: ValueKey<DateTime>(_selectedDate),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                            itemCount: entriesForSelected.length,
                            itemBuilder: (context, i) {
                              final e = entriesForSelected[i];
                              final isLast = i == entriesForSelected.length - 1;

                              Duration? gap;
                              if (!isLast) {
                                final next = entriesForSelected[i + 1];
                                gap = e.dateTime
                                    .difference(next.dateTime)
                                    .abs();
                              }

                              return _ArrowConnectorEntry(
                                index: i,
                                entry: e,
                                highlight: e.id == _highlightEntryId,
                                isLast: isLast,
                                gap: gap,
                                onTap: () {
                                  unawaited(HapticFeedback.lightImpact());
                                  unawaited(
                                    context.push('/diary/entry/${e.id}'),
                                  );
                                },
                                onEdit: () {
                                  unawaited(
                                    context.push(
                                      '/diary/entry/${e.id}/edit',
                                      extra: e,
                                    ),
                                  );
                                },
                                onDelete: () {
                                  unawaited(
                                    _showConfirmDelete(context, e),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _showCalendarView
          ? null
          : _AddMealFab(onPressed: _openAddMeal),
    );
  }

  Map<DateTime, List<MealEntry>> _groupByDay(List<MealEntry> entries) {
    final map = <DateTime, List<MealEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    final sorted = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sorted.map((k) => MapEntry(k, map[k]!)),
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.greeting,
    this.user,
  });

  final String greeting;
  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final isLoggedIn = user != null;
    final displayName = user?.displayName?.trim();
    final hasName = displayName != null && displayName.isNotEmpty;
    final firstName = hasName ? displayName.split(' ').first : null;
    final titleText = isLoggedIn && firstName != null
        ? '$greeting, $firstName 👋'
        : '$greeting 👋';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: [
            if (isLoggedIn)
              UserAvatar(user: user!, size: 44)
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
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
                    titleText,
                    style: AppTextStyles.h2.copyWith(
                      color: appColors.neutralBlack,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(DateTime.now()),
                    style: AppTextStyles.body3.copyWith(
                      color: appColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SyncIndicator(
              compact: true,
              showLabel: false,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DAY STRIP
// =============================================================================

class _DayStrip extends StatefulWidget {
  const _DayStrip({
    required this.selectedDate,
    required this.locale,
    required this.onSelectDay,
    required this.onCalendarTap,
    required this.onToday,
  });

  final DateTime selectedDate;
  final String locale;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onCalendarTap;
  final VoidCallback onToday;

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const int _totalDays = 14;
  static const double _chipWidth = 56;

  final ScrollController _scrollController = ScrollController();
  DateTime? _lastScrolledDate;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int selectedIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final target =
          (selectedIndex * _chipWidth) -
          (pos.viewportDimension / 2) +
          (_chipWidth / 2);
      unawaited(
        _scrollController.animateTo(
          target.clamp(0.0, pos.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  int _selectedIndex(List<DateTime> dates) {
    for (var i = 0; i < dates.length; i++) {
      final d = dates[i];
      if (d.year == widget.selectedDate.year &&
          d.month == widget.selectedDate.month &&
          d.day == widget.selectedDate.day) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final monthName = DateFormat.MMMM(
      widget.locale,
    ).format(widget.selectedDate);
    final capitalizedMonth =
        '${monthName[0].toUpperCase()}${monthName.substring(1)}';
    final year = widget.selectedDate.year;
    final weekdayFormat = DateFormat.E(widget.locale);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: _totalDays - 1));
    final dates = List.generate(
      _totalDays,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
    final selectedIndex = _selectedIndex(dates);
    if (_lastScrolledDate != widget.selectedDate) {
      _lastScrolledDate = widget.selectedDate;
      _scrollToSelected(selectedIndex);
    }

    final showYear = year != now.year;
    final isSelectedToday = widget.selectedDate == today;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                showYear ? '$capitalizedMonth $year' : capitalizedMonth,
                style: AppTextStyles.h4.copyWith(color: appColors.neutralBlack),
              ),
              if (!isSelectedToday) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    unawaited(HapticFeedback.lightImpact());
                    widget.onToday();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.today,
                      style: AppTextStyles.body3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: widget.onCalendarTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: appColors.grayLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: UiIcon(
                      UiIcons.calendar,
                      size: 20,
                      color: appColors.grayDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemExtent: _chipWidth,
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final d = dates[i];
                final isSelected = i == selectedIndex;
                final isToday = d == today;
                final wdLabel = weekdayFormat.format(d);
                final end = wdLabel.length.clamp(0, 3);
                final shortWd =
                    '${wdLabel[0].toUpperCase()}${wdLabel.substring(1, end)}';
                return GestureDetector(
                  onTap: () => widget.onSelectDay(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? appColors.primary
                          : isToday
                          ? appColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: appColors.primary.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shortWd,
                          style: AppTextStyles.body3.copyWith(
                            color: isSelected
                                ? appColors.neutralWhite.withValues(
                                    alpha: 0.7,
                                  )
                                : appColors.gray,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? appColors.neutralWhite
                                : isToday
                                ? appColors.primary
                                : appColors.neutralBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({required this.onAddMeal});

  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: appColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                size: 36,
                color: appColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noMealsThisDay,
              style: AppTextStyles.body1.copyWith(
                color: appColors.grayDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.diaryEmptySubtitle,
              style: AppTextStyles.body3.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            UiAutoWidthButton(
              text: l10n.addMeal,
              icon: UiIcons.camera,
              iconAlignment: UiButtonIconAlignment.before,
              onPressed: onAddMeal,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ARROW CONNECTOR ENTRY (Card with arrow below)
// =============================================================================

class _ArrowConnectorEntry extends StatelessWidget {
  const _ArrowConnectorEntry({
    required this.index,
    required this.entry,
    required this.highlight,
    required this.isLast,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.gap,
  });

  final int index;
  final MealEntry entry;
  final bool highlight;
  final bool isLast;
  final Duration? gap;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AnimatedEntryCard(
          index: index,
          entry: entry,
          highlight: highlight,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        if (!isLast) _ArrowConnector(gap: gap, pulse: highlight),
      ],
    );
  }
}

// =============================================================================
// ARROW CONNECTOR (Seta apontando para cima - "depois disso")
// =============================================================================

class _ArrowConnector extends StatefulWidget {
  const _ArrowConnector({this.gap, this.pulse = false});

  final Duration? gap;
  final bool pulse;

  @override
  State<_ArrowConnector> createState() => _ArrowConnectorState();
}

class _ArrowConnectorState extends State<_ArrowConnector>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.08, end: 0.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.pulse) {
      _startPulse();
    }
  }

  @override
  void didUpdateWidget(_ArrowConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _startPulse();
    }
  }

  void _startPulse() {
    unawaited(_pulseController.repeat(reverse: true));
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _pulseController
            ..stop()
            ..reset();
        }
      }),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final showGap = widget.gap != null && widget.gap!.inMinutes >= 5;
    final isLongGap = widget.gap != null && widget.gap!.inHours >= 4;

    String? label;
    if (showGap) {
      final hours = widget.gap!.inHours;
      final minutes = widget.gap!.inMinutes % 60;
      if (hours > 0 && minutes > 0) {
        label = '${hours}h ${minutes}min';
      } else if (hours > 0) {
        label = '${hours}h';
      } else {
        label = '${minutes}min';
      }
    }

    final baseColor = isLongGap ? appColors.alert : appColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Linha esquerda
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    baseColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Centro: seta + badge com animação
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.pulse ? _scaleAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(
                      alpha: widget.pulse ? _opacityAnimation.value : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: baseColor.withValues(
                        alpha: widget.pulse ? 0.5 : 0.2,
                      ),
                    ),
                    boxShadow: widget.pulse
                        ? [
                            BoxShadow(
                              color: baseColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Seta para cima
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 14,
                        color: baseColor.withValues(
                          alpha: widget.pulse ? 1.0 : 0.7,
                        ),
                      ),
                      if (showGap) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: baseColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          label!,
                          style: AppTextStyles.body3.copyWith(
                            color: baseColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          // Linha direita
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    baseColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FAB
// =============================================================================

class _AddMealFab extends StatelessWidget {
  const _AddMealFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: appColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const UiIcon(UiIcons.camera),
    );
  }
}

// =============================================================================
// CALENDAR MONTH VIEW
// =============================================================================

class _CalendarMonthView extends StatelessWidget {
  const _CalendarMonthView({
    required this.displayedMonth,
    required this.selectedDate,
    required this.daysWithEntries,
    required this.entriesByDay,
    required this.today,
    required this.locale,
    required this.onSelectDay,
    required this.onToday,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onAddMeal,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> daysWithEntries;
  final Map<DateTime, List<MealEntry>> entriesByDay;
  final DateTime today;
  final String locale;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onToday;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final monthName = DateFormat.MMMM(locale).format(displayedMonth);
    final capitalizedMonth =
        '${monthName[0].toUpperCase()}${monthName.substring(1)}';
    final year = displayedMonth.year;
    final now = DateTime.now();
    final showYear = year != now.year;

    final first = DateTime(displayedMonth.year, displayedMonth.month);
    final lastDay = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;
    final firstWeekday = first.weekday % 7;
    final leadingBlanks = firstWeekday;
    final totalCells = leadingBlanks + lastDay;
    final rows = (totalCells / 7).ceil();

    final isDisplayedMonthCurrent =
        displayedMonth.year == now.year && displayedMonth.month == now.month;
    final canGoNext = !isDisplayedMonthCurrent;

    final selectedEntries = entriesByDay[selectedDate] ?? [];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onPrevMonth,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appColors.grayLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: appColors.grayDark,
                          size: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          showYear
                              ? '$capitalizedMonth $year'
                              : capitalizedMonth,
                          style: AppTextStyles.h2.copyWith(
                            color: appColors.neutralBlack,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: canGoNext ? onNextMonth : null,
                      child: AnimatedOpacity(
                        opacity: canGoNext ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appColors.grayLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: appColors.grayDark,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isDisplayedMonthCurrent)
                  GestureDetector(
                    onTap: onToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.today,
                        style: AppTextStyles.body2.copyWith(
                          color: appColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: isDisplayedMonthCurrent ? 8 : 16),
                _WeekdayHeader(locale: locale),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: rows * 7,
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) {
                      return const SizedBox.shrink();
                    }
                    final dayNum = index - leadingBlanks + 1;
                    if (dayNum > lastDay) {
                      return const SizedBox.shrink();
                    }
                    final day = DateTime(
                      displayedMonth.year,
                      displayedMonth.month,
                      dayNum,
                    );
                    final isFuture = day.isAfter(today);
                    final hasEntries = daysWithEntries.contains(day);
                    final isSelected = day == selectedDate;
                    final isToday = day == today;
                    final entryCount = entriesByDay[day]?.length ?? 0;

                    return _CalendarDayCell(
                      dayNum: dayNum,
                      isSelected: isSelected,
                      isToday: isToday,
                      isFuture: isFuture,
                      hasEntries: hasEntries,
                      entryCount: entryCount,
                      onTap: isFuture ? null : () => onSelectDay(day),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        _SelectedDayPreview(
          selectedDate: selectedDate,
          entries: selectedEntries,
          locale: locale,
          onTap: () => onSelectDay(selectedDate),
          onAddMeal: onAddMeal,
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final weekdays = _getWeekdayLabels(locale);

    return Row(
      children: weekdays.map((label) {
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body3.copyWith(
                fontWeight: FontWeight.w600,
                color: appColors.gray,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _getWeekdayLabels(String locale) {
    final format = DateFormat.E(locale);
    return List.generate(7, (i) {
      final wd = (i + 1) % 7;
      final dt = DateTime(2024, 1, 7 + wd);
      final label = format.format(dt);
      return label[0].toUpperCase();
    });
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.dayNum,
    required this.isSelected,
    required this.isToday,
    required this.isFuture,
    required this.hasEntries,
    required this.entryCount,
    required this.onTap,
  });

  final int dayNum;
  final bool isSelected;
  final bool isToday;
  final bool isFuture;
  final bool hasEntries;
  final int entryCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary
              : isToday
              ? appColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(
                  color: appColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: AppTextStyles.body1.copyWith(
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isFuture
                    ? appColors.gray.withValues(alpha: 0.4)
                    : isSelected
                    ? appColors.neutralWhite
                    : isToday
                    ? appColors.primary
                    : appColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 4),
            if (hasEntries && !isFuture)
              _EntryDots(
                count: entryCount,
                isSelected: isSelected,
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _EntryDots extends StatelessWidget {
  const _EntryDots({
    required this.count,
    required this.isSelected,
  });

  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final displayCount = count.clamp(1, 3);
    final dotColor = isSelected
        ? appColors.neutralWhite.withValues(alpha: 0.8)
        : appColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(displayCount, (i) {
        return Container(
          width: 5,
          height: 5,
          margin: EdgeInsets.only(left: i > 0 ? 2 : 0),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _SelectedDayPreview extends StatelessWidget {
  const _SelectedDayPreview({
    required this.selectedDate,
    required this.entries,
    required this.locale,
    required this.onTap,
    required this.onAddMeal,
  });

  final DateTime selectedDate;
  final List<MealEntry> entries;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    final dayFormat = DateFormat.MMMEd(locale);
    final dayLabel = dayFormat.format(selectedDate);
    final capitalizedDay =
        '${dayLabel[0].toUpperCase()}${dayLabel.substring(1)}';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate == today;
    final yesterday = today.subtract(const Duration(days: 1));
    final isYesterday = selectedDate == yesterday;

    String displayLabel;
    if (isToday) {
      displayLabel = l10n.today;
    } else if (isYesterday) {
      displayLabel = l10n.yesterday;
    } else {
      displayLabel = capitalizedDay;
    }

    final entryCount = entries.length;
    final mealTypes = entries
        .map((e) => mealTypeLabel(e.mealType, l10n))
        .toSet();
    final mealSummary = mealTypes.take(3).join(', ');
    final mealLabel = entryCount == 1 ? l10n.mealSingular : l10n.mealPlural;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.neutralSilver,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors.grayLight.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.neutralBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: entryCount > 0
                          ? appColors.primary.withValues(alpha: 0.1)
                          : appColors.grayLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: entryCount > 0
                          ? Text(
                              '$entryCount',
                              style: AppTextStyles.h4.copyWith(
                                color: appColors.primary,
                              ),
                            )
                          : Icon(
                              Icons.restaurant_menu_outlined,
                              color: appColors.gray,
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayLabel,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: appColors.neutralBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entryCount > 0
                              ? '$entryCount $mealLabel • $mealSummary'
                              : l10n.noMealsThisDay,
                          style: AppTextStyles.body3.copyWith(
                            color: appColors.gray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: appColors.gray,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAddMeal,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: UiIcon(UiIcons.camera, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ANIMATED ENTRY CARD
// =============================================================================

class _AnimatedEntryCard extends StatefulWidget {
  const _AnimatedEntryCard({
    required this.index,
    required this.entry,
    required this.highlight,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final MealEntry entry;
  final bool highlight;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_AnimatedEntryCard> createState() => _AnimatedEntryCardState();
}

class _AnimatedEntryCardState extends State<_AnimatedEntryCard> {
  bool _visible = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      Duration(milliseconds: widget.index * 65),
      () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Dismissible(
              key: ValueKey(widget.entry.id),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                decoration: BoxDecoration(
                  color: appColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: appColors.neutralWhite,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.actionEdit,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.neutralWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
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
                      l10n.actionDelete,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.neutralWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.delete_outline_rounded,
                      color: appColors.neutralWhite,
                      size: 22,
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                unawaited(HapticFeedback.lightImpact());
                if (direction == DismissDirection.startToEnd) {
                  widget.onEdit();
                  return false;
                } else {
                  widget.onDelete();
                  return false;
                }
              },
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                onTap: widget.onTap,
                child: AnimatedScale(
                  scale: _pressed ? 0.98 : 1,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: _EntryCard(
                    entry: widget.entry,
                    highlight: widget.highlight,
                    onTap: widget.onTap,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ENTRY CARD
// =============================================================================

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.highlight,
    required this.onTap,
  });

  final MealEntry entry;
  final bool highlight;
  final VoidCallback onTap;

  static const double _leadingSize = 56;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final description = entry.description ?? entry.feelingText;
    final timeStr = DateFormat.Hm().format(entry.dateTime);

    return Container(
      decoration: BoxDecoration(
        color: appColors.neutralSilver,
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(color: appColors.primary, width: 2)
            : Border.all(
                color: appColors.grayLight.withValues(alpha: 0.6),
              ),
        boxShadow: [
          if (highlight)
            BoxShadow(
              color: appColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: appColors.neutralBlack.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeading(appColors),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mealTypeLabel(entry.mealType, l10n),
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: appColors.neutralBlack,
                              ),
                            ),
                          ),
                          if (entry.feelingLabel != null)
                            _buildFeelingBadge(
                              entry.feelingLabel!,
                              appColors,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: AppTextStyles.body3.copyWith(
                          color: appColors.gray,
                        ),
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: AppTextStyles.body2.copyWith(
                            color: appColors.grayDark,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(AppColors appColors) {
    return Container(
      width: _leadingSize,
      height: _leadingSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: appColors.grayLight.withValues(alpha: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: MealPhoto(
        photoPath: entry.photoPath,
        photoUrl: entry.photoUrl,
        width: _leadingSize,
        height: _leadingSize,
        borderRadius: BorderRadius.circular(14),
        placeholder: _leadingPlaceholder(appColors),
      ),
    );
  }

  Widget _leadingPlaceholder(AppColors appColors) {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        color: appColors.gray.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }

  Widget _buildFeelingBadge(FeelingLabel f, AppColors appColors) {
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
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: UiIcon(uiIcon, size: 18, color: color),
      ),
    );
  }
}
