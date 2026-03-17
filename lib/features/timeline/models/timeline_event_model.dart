class AstrologyInfo {
  final List<String> zodiacHours;
  final String hyThan;
  final String taiThan;

  AstrologyInfo({
    required this.zodiacHours,
    required this.hyThan,
    required this.taiThan,
  });
}

class TimelineEventModel {
  final String title;
  final String lunarDate;
  final DateTime solarDate;
  final String description;
  final String solarDateText; // pre-formatted like "Thứ Sáu, 13 tháng 2, 2026"
  final String? vanKhanId; // Optional ID to link to a VanKhan
  final AstrologyInfo? astrology; // Tử vi tùy chọn

  TimelineEventModel({
    required this.title,
    required this.lunarDate,
    required this.solarDate,
    required this.description,
    required this.solarDateText,
    this.vanKhanId,
    this.astrology,
  });
}
