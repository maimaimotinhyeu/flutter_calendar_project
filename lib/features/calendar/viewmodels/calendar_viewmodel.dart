import 'package:flutter/foundation.dart';
import 'package:lunar/lunar.dart';
import '../models/calendar_day_model.dart';
import '../../timeline/viewmodels/timeline_viewmodel.dart';

class CalendarViewModel extends ChangeNotifier {
  late DateTime _currentMonth;
  List<CalendarDayModel> _days = [];

  // Temporary dependency to get the Tet events
  final TimelineViewModel _timelineViewModel = TimelineViewModel();

  CalendarViewModel({DateTime? initialMonth}) {
    _currentMonth = initialMonth ?? DateTime.now();
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    _timelineViewModel.changeYear(
      _currentMonth.year,
    ); // Load events for the year
    _generateDays();
  }

  DateTime get currentMonth => _currentMonth;
  List<CalendarDayModel> get days => _days;

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    if (_currentMonth.month == 12) {
      _timelineViewModel.changeYear(_currentMonth.year);
    }
    _generateDays();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    if (_currentMonth.month == 1) {
      _timelineViewModel.changeYear(_currentMonth.year);
    }
    _generateDays();
  }

  void _generateDays() {
    _days = [];
    final now = DateTime.now();

    // Find the first day of the week for this month
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    // 1: Monday, 7: Sunday. We want Monday to be the start.
    final int weekdayOfFirstDay = firstDayOfMonth.weekday;
    final int daysFromPreviousMonth = weekdayOfFirstDay - 1;

    // Start date for the grid
    DateTime currentDate = firstDayOfMonth.subtract(
      Duration(days: daysFromPreviousMonth),
    );

    // Generate exactly 42 days (6 weeks) to fill the grid consistently
    for (int i = 0; i < 42; i++) {
      final isCurrentMonth = currentDate.month == _currentMonth.month;
      final isToday =
          currentDate.year == now.year &&
          currentDate.month == now.month &&
          currentDate.day == now.day;

      // Real Lunar Conversion using the `lunar` package
      final solarDate = Solar.fromDate(currentDate);
      final lunarDate = solarDate.getLunar();

      int mockLunarDay = lunarDate.getDay();
      int mockLunarMonth = lunarDate.getMonth();

      // Check if this solar date matches any Tet event
      bool isTetEvent = false;
      String? description;

      for (var event in _timelineViewModel.events) {
        if (event.solarDate.year == currentDate.year &&
            event.solarDate.month == currentDate.month &&
            event.solarDate.day == currentDate.day) {
          isTetEvent = true;
          description = event.title;
          break;
        }
      }

      _days.add(
        CalendarDayModel(
          solarDate: currentDate,
          lunarDay: mockLunarDay.toString(),
          lunarMonth: mockLunarMonth.toString(),
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isTetEvent: isTetEvent,
          eventDescription: description,
        ),
      );

      currentDate = currentDate.add(const Duration(days: 1));
    }
    notifyListeners();
  }
}
