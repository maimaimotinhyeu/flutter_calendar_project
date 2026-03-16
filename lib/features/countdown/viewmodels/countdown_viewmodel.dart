import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/tet_date_model.dart';
import '../../timeline/viewmodels/timeline_viewmodel.dart';

class CountdownViewModel extends ChangeNotifier {
  int _selectedYear =
      2026; // Default to 2026 initially, can be changed based on current year
  DateTime? _targetDate;
  Timer? _timer;

  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  bool isPassed = false;

  int get selectedYear => _selectedYear;

  CountdownViewModel() {
    // initialize with current year or next available Tet
    final now = DateTime.now();
    if (now.isAfter(TetDateModel.getTetDateForYear(now.year) ?? now)) {
      _selectedYear = now.year + 1;
    } else {
      _selectedYear = now.year;
    }
    _setTargetDate();
    startTimer();
  }

  void _setTargetDate() {
    if (_selectedYear == 2026) {
      _targetDate = DateTime.now().add(const Duration(seconds: 10));
    } else {
      _targetDate = TetDateModel.getTetDateForYear(_selectedYear);
    }
    _calculateTimeLeft();
  }

  void changeYear(int year) {
    if (_selectedYear == year) return;
    _selectedYear = year;
    _setTargetDate();
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    if (_targetDate == null) return;
    final now = DateTime.now();

    if (now.isAfter(_targetDate!)) {
      isPassed = true;
      days = 0;
      hours = 0;
      minutes = 0;
      seconds = 0;
    } else {
      isPassed = false;
      final difference = _targetDate!.difference(now);
      days = difference.inDays;
      hours = difference.inHours % 24;
      minutes = difference.inMinutes % 60;
      seconds = difference.inSeconds % 60;
    }

    // Update Android Widget every tick (every second)
    _updateHomeWidget();

    notifyListeners();
  }

  Future<void> _updateHomeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'tet_title',
        'Đếm Ngược Đến Tết $_selectedYear',
      );

      if (isPassed) {
        await HomeWidget.saveWidgetData<String>('tet_days', '00');
        await HomeWidget.saveWidgetData<String>('tet_hours', '00');
        await HomeWidget.saveWidgetData<String>('tet_mins', '00');
        await HomeWidget.saveWidgetData<String>('tet_secs', '00');
      } else {
        final d = days.toString().padLeft(3, '0');
        final h = hours.toString().padLeft(2, '0');
        final m = minutes.toString().padLeft(2, '0');
        final s = seconds.toString().padLeft(2, '0');

        await HomeWidget.saveWidgetData<String>('tet_days', d);
        await HomeWidget.saveWidgetData<String>('tet_hours', h);
        await HomeWidget.saveWidgetData<String>('tet_mins', m);
        await HomeWidget.saveWidgetData<String>('tet_secs', s);
      }

      // Calculate upcoming event
      final timelineViewModel = TimelineViewModel()..changeYear(_selectedYear);
      String upcomingText = "Sắp tới: Tết Nguyên Đán";
      final now = DateTime.now();
      for (var event in timelineViewModel.events) {
        final eventEndOfDay = DateTime(
          event.solarDate.year,
          event.solarDate.month,
          event.solarDate.day,
          23,
          59,
          59,
        );
        if (now.isBefore(eventEndOfDay)) {
          upcomingText = "Sắp tới: ${event.title}";
          break;
        }
      }
      await HomeWidget.saveWidgetData<String>('upcoming_event', upcomingText);

      await HomeWidget.updateWidget(
        androidName: 'TetWidgetProvider',
        iOSName: 'TetWidget',
      );
    } catch (e) {
      debugPrint('Error updating Home Widget: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
