String formatLocalDate(DateTime date) {
  final DateTime localDate = date.toLocal();
  final String month = localDate.month.toString().padLeft(2, '0');
  final String day = localDate.day.toString().padLeft(2, '0');

  return '${localDate.year}-$month-$day';
}

String formatLocalDateTimeWithOffset(DateTime date) {
  final DateTime localDate = date.toLocal();
  final Duration offset = localDate.timeZoneOffset;

  if (offset == Duration.zero) {
    return '${localDate.toIso8601String()}Z';
  }

  final String sign = offset.isNegative ? '-' : '+';
  final int totalMinutes = offset.inMinutes.abs();
  final String hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final String minutes = (totalMinutes % 60).toString().padLeft(2, '0');

  return '${localDate.toIso8601String()}$sign$hours:$minutes';
}
