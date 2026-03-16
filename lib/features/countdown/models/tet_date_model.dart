class TetDateModel {
  final int year;
  final DateTime date;
  
  TetDateModel({required this.year, required this.date});

  // Map of Solar Year -> Tet Date (Midnight 00:00:00 of Mùng 1 Tết, local time)
  // Giao thừa is exactly at this datetime.
  static final Map<int, DateTime> _tetDates = {
    2025: DateTime(2025, 1, 29, 0, 0, 0),
    2026: DateTime(2026, 2, 17, 0, 0, 0),
    2027: DateTime(2027, 2, 6, 0, 0, 0),
    2028: DateTime(2028, 1, 26, 0, 0, 0),
    2029: DateTime(2029, 2, 13, 0, 0, 0),
    2030: DateTime(2030, 2, 3, 0, 0, 0),
  };

  static DateTime? getTetDateForYear(int year) {
    return _tetDates[year];
  }
}
