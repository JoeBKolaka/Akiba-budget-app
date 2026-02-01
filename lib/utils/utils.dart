import 'dart:ui';

String rgbToHex(Color color) {
  return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToRgb(String hex) {
  String hexColor = hex.replaceAll('#', '');

  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  return Color(int.parse(hexColor, radix: 16));
}

List<DateTime> generateWeekDates(int weekOffset) {
  final today = DateTime.now();

  DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  startOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));

  return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
}
