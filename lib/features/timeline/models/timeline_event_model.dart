class TimelineEventModel {
  final String title;
  final String lunarDate;
  final DateTime solarDate;
  final String description;
  final String solarDateText; // pre-formatted like "Thứ Sáu, 13 tháng 2, 2026"

  TimelineEventModel({
    required this.title,
    required this.lunarDate,
    required this.solarDate,
    required this.description,
    required this.solarDateText,
  });
}
