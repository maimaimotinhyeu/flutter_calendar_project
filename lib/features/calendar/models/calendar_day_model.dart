class CalendarDayModel {
  final DateTime solarDate;
  final String lunarDay;
  final String lunarMonth;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isTetEvent;
  final String? eventDescription;

  CalendarDayModel({
    required this.solarDate,
    required this.lunarDay,
    required this.lunarMonth,
    required this.isCurrentMonth,
    this.isToday = false,
    this.isTetEvent = false,
    this.eventDescription,
  });
}
