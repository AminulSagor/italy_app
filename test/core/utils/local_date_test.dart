import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/utils/local_date.dart';

void main() {
  group('formatLocalDate', () {
    test('formats the local calendar date without a time component', () {
      final DateTime localTime = DateTime(2026, 9, 28, 1, 30);

      expect(formatLocalDate(localTime), '2026-09-28');
    });

    test('pads single-digit months and days', () {
      final DateTime localTime = DateTime(2026, 2, 3, 23, 59);

      expect(formatLocalDate(localTime), '2026-02-03');
    });
  });

  group('formatLocalDateTimeWithOffset', () {
    test('keeps timestamps parseable and explicitly zoned', () {
      final DateTime instant = DateTime.utc(2026, 9, 28, 1, 30);
      final String value = formatLocalDateTimeWithOffset(instant);

      expect(value, matches(RegExp(r'(Z|[+-]\d{2}:\d{2})$')));
      expect(DateTime.parse(value).toUtc(), instant);
    });
  });
}
