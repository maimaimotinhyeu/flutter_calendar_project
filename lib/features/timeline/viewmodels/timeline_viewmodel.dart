import 'package:flutter/material.dart';
import '../models/timeline_event_model.dart';
import '../../countdown/models/tet_date_model.dart';

class TimelineViewModel extends ChangeNotifier {
  int _selectedYear = 2026;
  List<TimelineEventModel> events = [];

  int get selectedYear => _selectedYear;

  TimelineViewModel() {
    final now = DateTime.now();
    if (now.isAfter(TetDateModel.getTetDateForYear(now.year) ?? now)) {
      _selectedYear = now.year + 1;
    } else {
      _selectedYear = now.year;
    }
    _loadEventsForYear(_selectedYear);
  }

  void changeYear(int year) {
    if (_selectedYear == year) return;
    _selectedYear = year;
    _loadEventsForYear(year);
    notifyListeners();
  }

  void _loadEventsForYear(int year) {
    // Initialize events based on Tet day for the given year
    final tetDate =
        TetDateModel.getTetDateForYear(year) ??
        DateTime(year, 2, 17); // fallback 2026

    events = [
      TimelineEventModel(
        title: 'Ông Táo Chầu Trời',
        lunarDate: '23/12 Âm lịch',
        solarDate: tetDate.subtract(const Duration(days: 7)),
        description: 'Cúng Ông Táo về trời',
        solarDateText: _formatDate(tetDate.subtract(const Duration(days: 7))),
        vanKhanId: 'ong-tao',
      ),
      TimelineEventModel(
        title: 'Giao Thừa',
        lunarDate: '30/12 Âm lịch', // Hoặc 29 tùy tháng thiếu
        solarDate: tetDate.subtract(
          const Duration(minutes: 1),
        ), // Midnight exactly is Tet, so 1 min before is Giao Thua eve
        description: 'Đêm Giao Thừa',
        solarDateText: _formatDate(tetDate.subtract(const Duration(days: 1))),
        vanKhanId: 'giao-thua',
      ),
      TimelineEventModel(
        title: 'Mùng 1 Tết',
        lunarDate: '1/1 Âm lịch',
        solarDate: tetDate,
        description: 'Ngày đầu tiên của năm mới',
        solarDateText: _formatDate(tetDate),
        vanKhanId: 'mung-1',
      ),
      TimelineEventModel(
        title: 'Mùng 2 Tết',
        lunarDate: '2/1 Âm lịch',
        solarDate: tetDate.add(const Duration(days: 1)),
        description: 'Về quê nội',
        solarDateText: _formatDate(tetDate.add(const Duration(days: 1))),
      ),
      TimelineEventModel(
        title: 'Mùng 3 Tết',
        lunarDate: '3/1 Âm lịch',
        solarDate: tetDate.add(const Duration(days: 2)),
        description: 'Về quê ngoại',
        solarDateText: _formatDate(tetDate.add(const Duration(days: 2))),
      ),
      TimelineEventModel(
        title: 'Lễ Khai Hạ',
        lunarDate: '7/1 Âm lịch',
        solarDate: tetDate.add(const Duration(days: 6)),
        description: 'Lễ hóa vàng, kết thúc kỳ nghỉ Tết',
        solarDateText: _formatDate(tetDate.add(const Duration(days: 6))),
        vanKhanId: 'khai-ha',
      ),
    ];
  }

  String _formatDate(DateTime date) {
    // Simple Vietnamese formatting without adding extra heavy package for just days
    const days = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    final weekday = date.weekday == 7 ? days[0] : days[date.weekday];
    return '$weekday, ${date.day} tháng ${date.month}, ${date.year}';
  }

  // Helper method to determine the status of an event
  // Returns:
  // - 1 if passed
  // - 0 if current (next upcoming)
  // - -1 if future
  int getEventStatus(TimelineEventModel event) {
    final now = DateTime.now();
    // If it's the exact same day, we can consider it "upcoming/current" depending on time
    // For simplicity, if now is past the solar date (day end), it's passed
    final eventEndOfDay = DateTime(
      event.solarDate.year,
      event.solarDate.month,
      event.solarDate.day,
      23,
      59,
      59,
    );

    if (now.isAfter(eventEndOfDay)) {
      return 1; // Passed
    }

    // Find the next upcoming event
    final futureEvents = events.where((e) {
      final eEnd = DateTime(
        e.solarDate.year,
        e.solarDate.month,
        e.solarDate.day,
        23,
        59,
        59,
      );
      return now.isBefore(eEnd);
    }).toList();

    if (futureEvents.isNotEmpty && futureEvents.first.title == event.title) {
      return 0; // Current / Next
    }

    return -1; // Future
  }
}
