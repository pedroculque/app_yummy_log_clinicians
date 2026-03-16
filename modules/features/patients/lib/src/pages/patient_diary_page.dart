import 'dart:async';

import 'package:diary_feature/diary_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patients_feature/src/cubit/patient_diary_cubit.dart';
import 'package:patients_feature/src/cubit/patient_diary_state.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PatientDiaryPage extends StatefulWidget {
  const PatientDiaryPage({
    required this.patientId,
    this.patientName,
    super.key,
  });

  final String patientId;
  final String? patientName;

  @override
  State<PatientDiaryPage> createState() => _PatientDiaryPageState();
}

class _PatientDiaryPageState extends State<PatientDiaryPage> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  bool _showCalendarView = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month);

    debugPrint(
      '[PatientDiaryPage] initState load(patientId=${widget.patientId}, '
      'patientName=${widget.patientName})',
    );
    unawaited(
      context.read<PatientDiaryCubit>().load(
        patientId: widget.patientId,
        patientName: widget.patientName ?? '',
      ),
    );
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

  void _hideCalendar() {
    setState(() => _showCalendarView = false);
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

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final displayName =
        widget.patientName?.isEmpty ?? true
            ? l10n.patientDefaultName
            : widget.patientName!;

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: _showCalendarView
          ? AppBar(
              backgroundColor: appColors.backgroundDefault,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: appColors.neutralBlack,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.h4.copyWith(
                      color: appColors.neutralBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.diaryTitle,
                    style: AppTextStyles.body3.copyWith(
                      color: appColors.gray,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                _AppBarFormConfigButton(
                  patientId: widget.patientId,
                  patientName: displayName,
                  l10n: l10n,
                  appColors: appColors,
                ),
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
          : AppBar(
              backgroundColor: appColors.backgroundDefault,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: appColors.neutralBlack,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.h4.copyWith(
                      color: appColors.neutralBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.diaryTitle,
                    style: AppTextStyles.body3.copyWith(
                      color: appColors.gray,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                _AppBarFormConfigButton(
                  patientId: widget.patientId,
                  patientName: displayName,
                  l10n: l10n,
                  appColors: appColors,
                ),
              ],
            ),
      body: BlocBuilder<PatientDiaryCubit, PatientDiaryState>(
        builder: (context, state) {
          if (state.status == PatientDiaryStatus.loading ||
              state.status == PatientDiaryStatus.initial) {
            return Center(
              child: CircularProgressIndicator(color: appColors.primary),
            );
          }

          if (state.status == PatientDiaryStatus.error) {
            return _ErrorState(
              error: state.error ?? context.l10n.diaryLoadError,
              onRetry: () => context.read<PatientDiaryCubit>().load(
                    patientId: widget.patientId,
                    patientName: widget.patientName ?? '',
                  ),
            );
          }

          final byDay = _groupByDay(state.entries);
          final daysWithEntries = byDay.keys.toSet();
          final entriesForSelected = byDay[_selectedDate] ?? [];

          debugPrint(
            '[PatientDiaryPage] build loaded: '
            'state.entries=${state.entries.length} byDay.days=${byDay.length} '
            'selectedDate=$_selectedDate '
            'entriesForSelected=${entriesForSelected.length}',
          );

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
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DayStrip(
                selectedDate: _selectedDate,
                locale: locale,
                daysWithEntries: daysWithEntries,
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
                    ? _EmptyDayState(l10n: l10n)
                    : _EntriesList(
                        entries: entriesForSelected,
                        locale: locale,
                        onRefresh: () => context
                            .read<PatientDiaryCubit>()
                            .refresh(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<MealEntry>> _groupByDay(List<MealEntry> entries) {
    final map = <DateTime, List<MealEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    return map;
  }
}

class _AppBarFormConfigButton extends StatelessWidget {
  const _AppBarFormConfigButton({
    required this.patientId,
    required this.patientName,
    required this.l10n,
    required this.appColors,
  });

  final String patientId;
  final String patientName;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(Icons.tune_rounded, color: appColors.grayDark, size: 22),
        onPressed: () {
          final encodedName = Uri.encodeComponent(patientName);
          unawaited(
            context.push(
              '/patients/$patientId/form-config?name=$encodedName',
            ),
          );
        },
        tooltip: l10n.formConfigButton,
        style: IconButton.styleFrom(
          backgroundColor: appColors.grayLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: appColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTextStyles.body1.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            UiAutoWidthButton(
              text: context.l10n.tryAgain,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayStrip extends StatefulWidget {
  const _DayStrip({
    required this.selectedDate,
    required this.locale,
    required this.daysWithEntries,
    required this.onSelectDay,
    required this.onCalendarTap,
    required this.onToday,
  });

  final DateTime selectedDate;
  final String locale;
  final Set<DateTime> daysWithEntries;
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
      final target = (selectedIndex * _chipWidth) -
          (pos.viewportDimension / 2) +
          (_chipWidth / 2);
      unawaited(_scrollController.animateTo(
        target.clamp(0.0, pos.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ));
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
    final monthName =
        DateFormat.MMMM(widget.locale).format(widget.selectedDate);
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                final hasEntries = widget.daysWithEntries.contains(d);
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
                                ? appColors.neutralWhite.withValues(alpha: 0.7)
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
                        const SizedBox(height: 4),
                        if (hasEntries)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? appColors.neutralWhite
                                      .withValues(alpha: 0.8)
                                  : appColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 6),
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
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
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
  });

  final DateTime selectedDate;
  final List<MealEntry> entries;
  final String locale;
  final VoidCallback onTap;

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
        .map((e) => _mealTypeLabel(e.mealType, l10n))
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
    );
  }

  String _mealTypeLabel(MealType type, AppLocalizations l10n) {
    return switch (type) {
      MealType.breakfast => l10n.mealTypeBreakfast,
      MealType.lunch => l10n.mealTypeLunch,
      MealType.dinner => l10n.mealTypeDinner,
      MealType.supper => l10n.mealTypeSupper,
      MealType.morningSnack => l10n.mealTypeMorningSnack,
      MealType.afternoonSnack => l10n.mealTypeAfternoonSnack,
      MealType.eveningSnack => l10n.mealTypeEveningSnack,
    };
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({required this.l10n});

  final AppLocalizations l10n;

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
              l10n.patientNoMealsThisDay,
              style: AppTextStyles.body3.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntriesList extends StatelessWidget {
  const _EntriesList({
    required this.entries,
    required this.locale,
    this.onRefresh,
  });

  final List<MealEntry> entries;
  final String locale;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;

        Duration? gap;
        if (!isLast) {
          final next = entries[i + 1];
          gap = entry.dateTime.difference(next.dateTime).abs();
        }

        return _EntryItem(
          entry: entry,
          isLast: isLast,
          gap: gap,
        );
      },
    );
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }
    return listView;
  }
}

class _EntryItem extends StatelessWidget {
  const _EntryItem({
    required this.entry,
    required this.isLast,
    this.gap,
  });

  final MealEntry entry;
  final bool isLast;
  final Duration? gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EntryCard(entry: entry),
        if (!isLast) _ArrowConnector(gap: gap),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final MealEntry entry;

  static const double _leadingSize = 56;

  bool get _hasRiskBehaviors =>
      entry.forcedVomit == true ||
      entry.usedLaxatives == true ||
      entry.diuretics == true ||
      entry.regurgitated == true ||
      entry.hiddenFood == true ||
      entry.ateInSecret == true;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final description = entry.description ?? entry.feelingText;
    final timeStr = DateFormat.Hm().format(entry.dateTime);

    return GestureDetector(
      onTap: () => _showMealDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: appColors.neutralSilver,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasRiskBehaviors
                ? appColors.error.withValues(alpha: 0.4)
                : appColors.grayLight.withValues(alpha: 0.6),
            width: _hasRiskBehaviors ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: appColors.neutralBlack.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                                _mealTypeLabel(entry.mealType, l10n),
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
              if (_hasRiskBehaviors) ...[
                const SizedBox(height: 10),
                _BehaviorTags(entry: entry, l10n: l10n, appColors: appColors),
              ],
              if (entry.amountEaten != null || entry.whereAte != null) ...[
                const SizedBox(height: 8),
                _DetailChips(entry: entry, l10n: l10n, appColors: appColors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetail(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _MealDetailSheet(entry: entry),
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
      child: entry.photoUrl != null
          ? Image.network(
              entry.photoUrl!,
              width: _leadingSize,
              height: _leadingSize,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _leadingPlaceholder(appColors),
            )
          : _leadingPlaceholder(appColors),
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

  String _mealTypeLabel(MealType type, AppLocalizations l10n) {
    return switch (type) {
      MealType.breakfast => l10n.mealTypeBreakfast,
      MealType.lunch => l10n.mealTypeLunch,
      MealType.dinner => l10n.mealTypeDinner,
      MealType.supper => l10n.mealTypeSupper,
      MealType.morningSnack => l10n.mealTypeMorningSnack,
      MealType.afternoonSnack => l10n.mealTypeAfternoonSnack,
      MealType.eveningSnack => l10n.mealTypeEveningSnack,
    };
  }
}

class _BehaviorTags extends StatelessWidget {
  const _BehaviorTags({
    required this.entry,
    required this.l10n,
    required this.appColors,
  });

  final MealEntry entry;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final behaviors = <Widget>[];

    if (entry.forcedVomit == true) {
      behaviors.add(_buildTag(l10n.behaviorForcedVomit, appColors.error));
    }
    if (entry.usedLaxatives == true) {
      behaviors.add(_buildTag(l10n.behaviorUsedLaxatives, appColors.error));
    }
    if (entry.diuretics == true) {
      behaviors.add(_buildTag(l10n.behaviorDiuretics, appColors.error));
    }
    if (entry.regurgitated == true) {
      behaviors.add(_buildTag(l10n.behaviorRegurgitated, Colors.orange));
    }
    if (entry.hiddenFood == true) {
      behaviors.add(_buildTag(l10n.behaviorHiddenFood, Colors.orange));
    }
    if (entry.ateInSecret == true) {
      behaviors.add(_buildTag(l10n.behaviorAteInSecret, Colors.amber.shade700));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: behaviors,
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChips extends StatelessWidget {
  const _DetailChips({
    required this.entry,
    required this.l10n,
    required this.appColors,
  });

  final MealEntry entry;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (entry.amountEaten != null)
          _buildChip(
            Icons.pie_chart_outline,
            _amountLabel(entry.amountEaten!, l10n),
          ),
        if (entry.whereAte != null && entry.whereAte!.isNotEmpty)
          _buildChip(Icons.place_outlined, entry.whereAte!),
        if (entry.ateWithOthers == true)
          _buildChip(Icons.people_outline, l10n.yes),
        if (entry.ateWithOthers == false)
          _buildChip(Icons.person_outline, l10n.no),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: appColors.gray),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              color: appColors.grayDark,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _amountLabel(AmountEaten amount, AppLocalizations l10n) {
    return switch (amount) {
      AmountEaten.nothing => l10n.amountNothing,
      AmountEaten.aLittle => l10n.amountLittle,
      AmountEaten.half => l10n.amountHalf,
      AmountEaten.most => l10n.amountMost,
      AmountEaten.all => l10n.amountAll,
    };
  }
}

class _MealDetailSheet extends StatelessWidget {
  const _MealDetailSheet({required this.entry});

  final MealEntry entry;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appColors.gray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.mealDetailTitle,
                    style: AppTextStyles.h3.copyWith(
                      color: appColors.neutralBlack,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: appColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.photoUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        entry.photoUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _DetailRow(
                    icon: Icons.restaurant,
                    label: l10n.labelMeal,
                    value: _mealTypeLabel(entry.mealType, l10n),
                    appColors: appColors,
                  ),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: l10n.labelDate,
                    value: dateFormat.format(entry.dateTime),
                    appColors: appColors,
                  ),
                  if (entry.whereAte != null && entry.whereAte!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: l10n.mealDetailWhere,
                      value: entry.whereAte!,
                      appColors: appColors,
                    ),
                  if (entry.ateWithOthers != null)
                    _DetailRow(
                      icon: Icons.people_outline,
                      label: l10n.mealDetailWithOthers,
                      value: entry.ateWithOthers! ? l10n.yes : l10n.no,
                      appColors: appColors,
                    ),
                  if (entry.amountEaten != null)
                    _DetailRow(
                      icon: Icons.pie_chart_outline,
                      label: l10n.mealDetailAmount,
                      value: _amountLabel(entry.amountEaten!, l10n),
                      appColors: appColors,
                      valueColor: _amountColor(entry.amountEaten!, appColors),
                    ),
                  if (entry.feelingLabel != null)
                    _DetailRow(
                      icon: Icons.mood,
                      label: l10n.mealDetailFeeling,
                      value: _feelingLabel(entry.feelingLabel!, l10n),
                      appColors: appColors,
                      valueColor: _feelingColor(entry.feelingLabel!, appColors),
                    ),
                  if (entry.description != null &&
                      entry.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.mealDetailDescription,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.gray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.gray.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.description!,
                        style: AppTextStyles.body2.copyWith(
                          color: appColors.neutralBlack,
                        ),
                      ),
                    ),
                  ],
                  if (entry.feelingText != null &&
                      entry.feelingText!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.mealDetailFeelingText,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.gray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.gray.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.feelingText!,
                        style: AppTextStyles.body2.copyWith(
                          color: appColors.neutralBlack,
                        ),
                      ),
                    ),
                  ],
                  if (_hasRiskBehaviors) ...[
                    const SizedBox(height: 20),
                    Text(
                      l10n.mealDetailBehaviors,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BehaviorsList(
                      entry: entry,
                      l10n: l10n,
                      appColors: appColors,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasRiskBehaviors =>
      entry.forcedVomit == true ||
      entry.usedLaxatives == true ||
      entry.diuretics == true ||
      entry.regurgitated == true ||
      entry.hiddenFood == true ||
      entry.ateInSecret == true;

  String _mealTypeLabel(MealType type, AppLocalizations l10n) {
    return switch (type) {
      MealType.breakfast => l10n.mealTypeBreakfast,
      MealType.lunch => l10n.mealTypeLunch,
      MealType.dinner => l10n.mealTypeDinner,
      MealType.supper => l10n.mealTypeSupper,
      MealType.morningSnack => l10n.mealTypeMorningSnack,
      MealType.afternoonSnack => l10n.mealTypeAfternoonSnack,
      MealType.eveningSnack => l10n.mealTypeEveningSnack,
    };
  }

  String _amountLabel(AmountEaten amount, AppLocalizations l10n) {
    return switch (amount) {
      AmountEaten.nothing => l10n.amountNothing,
      AmountEaten.aLittle => l10n.amountLittle,
      AmountEaten.half => l10n.amountHalf,
      AmountEaten.most => l10n.amountMost,
      AmountEaten.all => l10n.amountAll,
    };
  }

  Color? _amountColor(AmountEaten amount, AppColors appColors) {
    return switch (amount) {
      AmountEaten.nothing => appColors.error,
      AmountEaten.aLittle => Colors.orange,
      AmountEaten.half => Colors.amber.shade700,
      AmountEaten.most => appColors.success,
      AmountEaten.all => appColors.success,
    };
  }

  String _feelingLabel(FeelingLabel feeling, AppLocalizations l10n) {
    return switch (feeling) {
      FeelingLabel.sad => l10n.feelingSad,
      FeelingLabel.nothing => l10n.feelingNothing,
      FeelingLabel.happy => l10n.feelingHappy,
      FeelingLabel.proud => l10n.feelingProud,
      FeelingLabel.angry => l10n.feelingAngry,
    };
  }

  Color? _feelingColor(FeelingLabel feeling, AppColors appColors) {
    return switch (feeling) {
      FeelingLabel.sad => appColors.error,
      FeelingLabel.angry => appColors.error,
      FeelingLabel.nothing => appColors.alert,
      FeelingLabel.happy => appColors.success,
      FeelingLabel.proud => appColors.success,
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.appColors,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColors appColors;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: appColors.gray),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(color: appColors.gray),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: valueColor ?? appColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorsList extends StatelessWidget {
  const _BehaviorsList({
    required this.entry,
    required this.l10n,
    required this.appColors,
  });

  final MealEntry entry;
  final AppLocalizations l10n;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (entry.forcedVomit == true)
          _buildBehaviorItem(
            l10n.behaviorForcedVomit,
            appColors.error,
            Icons.warning_rounded,
          ),
        if (entry.usedLaxatives == true)
          _buildBehaviorItem(
            l10n.behaviorUsedLaxatives,
            appColors.error,
            Icons.warning_rounded,
          ),
        if (entry.diuretics == true)
          _buildBehaviorItem(
            l10n.behaviorDiuretics,
            appColors.error,
            Icons.warning_rounded,
          ),
        if (entry.regurgitated == true)
          _buildBehaviorItem(
            l10n.behaviorRegurgitated,
            Colors.orange,
            Icons.warning_amber_rounded,
          ),
        if (entry.hiddenFood == true)
          _buildBehaviorItem(
            l10n.behaviorHiddenFood,
            Colors.orange,
            Icons.warning_amber_rounded,
          ),
        if (entry.ateInSecret == true)
          _buildBehaviorItem(
            l10n.behaviorAteInSecret,
            Colors.amber.shade700,
            Icons.visibility_off_outlined,
          ),
      ],
    );
  }

  Widget _buildBehaviorItem(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowConnector extends StatelessWidget {
  const _ArrowConnector({this.gap});

  final Duration? gap;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final showGap = gap != null && gap!.inMinutes >= 5;
    final isLongGap = gap != null && gap!.inHours >= 4;

    String? label;
    if (showGap) {
      final hours = gap!.inHours;
      final minutes = gap!.inMinutes % 60;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: baseColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 14,
                  color: baseColor.withValues(alpha: 0.7),
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
