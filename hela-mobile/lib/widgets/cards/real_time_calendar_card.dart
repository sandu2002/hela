import 'package:flutter/material.dart';
import 'package:hela/pages/home/home_page.dart';

/// Data model for an individual calendar day slot
class CalendarDayData {
  final String dayName;
  final int dayNumber;
  final DateTime date;
  final bool isStart;
  final bool isInRange;
  final bool isEnd;
  final bool isToday;
  final bool isInactive;

  const CalendarDayData({
    required this.dayName,
    required this.dayNumber,
    required this.date,
    this.isStart = false,
    this.isInRange = false,
    this.isEnd = false,
    this.isToday = false,
    this.isInactive = false,
  });
}

/// Real-Time Interactive Travel Timeframe Calendar Card
///
/// Features:
/// - Real-time date range tracking and calculation
/// - Formatted header ("Month Day — Month Day · X Days")
/// - Interactive "Edit" button opening Flutter's rich Date Range Picker
/// - Weekday strip (Sun–Sat) with live day numbers and selection highlights
/// - Week navigation (`<` and `>` buttons) to browse past or future weeks
/// - Direct day tapping to adjust trip start and end dates in real time
/// - Quick "+3 Days" extension action button
/// - Dynamic Sri Lankan seasonal weather intelligence based on selected month
/// - Optional expandable full-month calendar grid
class RealTimeCalendarCard extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final ValueChanged<DateTimeRange>? onDateRangeChanged;
  final String? customSeasonalHint;
  final EdgeInsetsGeometry padding;

  const RealTimeCalendarCard({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.onDateRangeChanged,
    this.customSeasonalHint,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  State<RealTimeCalendarCard> createState() => _RealTimeCalendarCardState();
}

class _RealTimeCalendarCardState extends State<RealTimeCalendarCard> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late DateTime _startDate;
  late DateTime _endDate;
  int _weekOffset = 0;
  bool _isMonthViewExpanded = false;
  late DateTime _monthViewDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to initialStartDate or real-time today
    final start = widget.initialStartDate ?? DateTime(now.year, now.month, now.day);
    // Default to initialEndDate or 7 days after start (8 days total)
    final end = widget.initialEndDate ?? start.add(const Duration(days: 7));
    _startDate = DateTime(start.year, start.month, start.day);
    _endDate = DateTime(end.year, end.month, end.day);
    _monthViewDate = DateTime(_startDate.year, _startDate.month, 1);
  }

  int get _totalDays {
    return _endDate.difference(_startDate).inDays + 1;
  }

  String _formatMonthDay(DateTime dt) {
    return '${_months[dt.month - 1]} ${dt.day}';
  }

  String _formatRange() {
    if (_startDate.year == _endDate.year && _startDate.month == _endDate.month) {
      return '${_months[_startDate.month - 1]} ${_startDate.day} — ${_months[_endDate.month - 1]} ${_endDate.day}';
    }
    return '${_formatMonthDay(_startDate)} — ${_formatMonthDay(_endDate)}';
  }

  String get _seasonalWeatherHint {
    if (widget.customSeasonalHint != null) {
      return widget.customSeasonalHint!;
    }
    final month = _startDate.month;
    if (month >= 11 || month <= 4) {
      return 'Peak seasonal weather in Central & Southern belts';
    } else if (month >= 5 && month <= 9) {
      return 'Optimal dry-season sunshine in Eastern & Northern belts';
    } else {
      return 'Lush green tea hills & active wildlife across reserves';
    }
  }

  String _getWeekdayLetter(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'S';
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      default:
        return '';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateInRange(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final s = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final e = DateTime(_endDate.year, _endDate.month, _endDate.day);
    return (day.isAfter(s) && day.isBefore(e)) || _isSameDay(day, s) || _isSameDay(day, e);
  }

  DateTime get _currentSunday {
    final base = _startDate.add(Duration(days: _weekOffset * 7));
    final daysFromSunday = base.weekday % 7; // Sunday in Dart is 7, 7 % 7 = 0
    return DateTime(base.year, base.month, base.day).subtract(Duration(days: daysFromSunday));
  }

  List<DateTime> get _visibleWeekDays {
    final sunday = _currentSunday;
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  void _notifyChange() {
    widget.onDateRangeChanged?.call(DateTimeRange(start: _startDate, end: _endDate));
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 365));
    final lastDate = now.add(const Duration(days: 730));

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'SELECT TRAVEL DATES',
      cancelText: 'CANCEL',
      confirmText: 'SET TIMEFRAME',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HelaColors.primary,
              onPrimary: HelaColors.onPrimary,
              secondary: HelaColors.secondary,
              onSecondary: Colors.white,
              surface: HelaColors.surfaceContainerLowest,
              onSurface: HelaColors.primary,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _weekOffset = 0;
        _monthViewDate = DateTime(picked.start.year, picked.start.month, 1);
      });
      _notifyChange();
    }
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      final selectedDay = DateTime(day.year, day.month, day.day);
      if (selectedDay.isBefore(_startDate)) {
        // Shift entire range starting on this tapped day
        final duration = _endDate.difference(_startDate);
        _startDate = selectedDay;
        _endDate = selectedDay.add(duration);
      } else if (_isSameDay(selectedDay, _startDate)) {
        // Tapped start day again, keep it
      } else if (selectedDay.isAfter(_startDate) && (selectedDay.isBefore(_endDate) || _isSameDay(selectedDay, _endDate))) {
        // Tapped inside the range: shorten range to end here
        _endDate = selectedDay;
      } else {
        // Tapped after current end: extend range to here
        _endDate = selectedDay;
      }
    });
    _notifyChange();
  }

  void _extendDays(int days) {
    setState(() {
      _endDate = _endDate.add(Duration(days: days));
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = _visibleWeekDays;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E24).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Timeframe Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDateRange(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: HelaColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: HelaColors.primary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TRAVEL TIMEFRAME',
                              style: TextStyle(
                                color: HelaColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_formatRange()} ',
                                    style: const TextStyle(
                                      color: HelaColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '· $_totalDays Days',
                                    style: const TextStyle(
                                      color: HelaColors.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons: Month Toggle & Edit
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMonthViewExpanded
                          ? Icons.view_week_rounded
                          : Icons.calendar_view_month_rounded,
                      size: 20,
                      color: HelaColors.primary,
                    ),
                    tooltip: _isMonthViewExpanded
                        ? 'Switch to Week Strip'
                        : 'Expand Month Calendar',
                    onPressed: () {
                      setState(() {
                        _isMonthViewExpanded = !_isMonthViewExpanded;
                      });
                    },
                  ),
                  TextButton(
                    onPressed: () => _pickDateRange(context),
                    style: TextButton.styleFrom(
                      foregroundColor: HelaColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: HelaColors.surfaceContainer),
          const SizedBox(height: 12),

          if (!_isMonthViewExpanded) ...[
            // Week navigation header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _weekOffset--;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 20,
                      color: HelaColors.primary,
                    ),
                  ),
                ),
                Text(
                  '${_months[weekDays.first.month - 1]} ${weekDays.first.year}',
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _weekOffset++;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: HelaColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Mini Calendar Days Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays.map((day) {
                final isStart = _isSameDay(day, _startDate);
                final isInRange = _isDateInRange(day);
                final isToday = _isSameDay(day, now);
                final isOutside = !isInRange;

                Color bg = Colors.transparent;
                Color textColor = HelaColors.primary;
                Color labelColor = HelaColors.onSurfaceVariant;

                if (isStart) {
                  bg = HelaColors.primary;
                  textColor = HelaColors.onPrimary;
                  labelColor = HelaColors.primaryFixed;
                } else if (isInRange) {
                  bg = HelaColors.secondaryContainer.withValues(alpha: 0.45);
                  textColor = HelaColors.primary;
                  labelColor = HelaColors.secondary;
                } else if (isOutside) {
                  textColor = HelaColors.onSurfaceVariant.withValues(alpha: 0.4);
                  labelColor = HelaColors.onSurfaceVariant.withValues(alpha: 0.4);
                }

                return Expanded(
                  child: InkWell(
                    onTap: () => _onDayTapped(day),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isStart
                            ? Border.all(
                                color: HelaColors.secondary.withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayLetter(day.weekday),
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: isStart || isInRange
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            // Full Month Grid View
            _buildMonthGrid(),
          ],

          const SizedBox(height: 10),

          // Weather hint info row with interactive extension
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: HelaColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _seasonalWeatherHint,
                        style: const TextStyle(
                          color: HelaColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _extendDays(3),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    '+3 Days',
                    style: TextStyle(
                      color: HelaColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final year = _monthViewDate.year;
    final month = _monthViewDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = firstDayOfMonth.weekday % 7; // Sunday is 0

    return Column(
      children: [
        // Month navigation header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _monthViewDate = DateTime(year, month - 1, 1);
                });
              },
            ),
            Text(
              '${_months[month - 1]} $year',
              style: const TextStyle(
                color: HelaColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _monthViewDate = DateTime(year, month + 1, 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Day letters row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((letter) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),

        // Month Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return const SizedBox();
            }
            final dayNumber = index - leadingBlanks + 1;
            final date = DateTime(year, month, dayNumber);
            final isStart = _isSameDay(date, _startDate);
            final isInRange = _isDateInRange(date);

            Color bg = Colors.transparent;
            Color textCol = HelaColors.primary;

            if (isStart) {
              bg = HelaColors.primary;
              textCol = HelaColors.onPrimary;
            } else if (isInRange) {
              bg = HelaColors.secondaryContainer.withValues(alpha: 0.45);
              textCol = HelaColors.primary;
            }

            return InkWell(
              onTap: () => _onDayTapped(date),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: textCol,
                      fontSize: 12,
                      fontWeight: isStart || isInRange
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
