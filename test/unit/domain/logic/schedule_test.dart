// test/unit/domain/logic/schedule_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/schedule.dart';

void main() {
  group('Schedule Generation', () {
    test('generates correct schedule for 3 cards peak', () {
      final schedule = buildRoundSchedule(3);

      expect(schedule.length, equals(5)); // 1-2-3-2-1
      expect(schedule, equals([1, 2, 3, 2, 1]));
    });

    test('generates correct schedule for 5 cards peak', () {
      final schedule = buildRoundSchedule(5);

      expect(schedule.length, equals(9)); // 1-2-3-4-5-4-3-2-1
      expect(schedule, equals([1, 2, 3, 4, 5, 4, 3, 2, 1]));
    });

    test('generates correct schedule for 7 cards peak', () {
      final schedule = buildRoundSchedule(7);

      expect(schedule.length, equals(13)); // 1-2-3-4-5-6-7-6-5-4-3-2-1
      expect(schedule, equals([1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1]));
    });

    test('generates correct schedule for 10 cards peak', () {
      final schedule = buildRoundSchedule(10);

      expect(schedule.length, equals(19)); // 1-2-...-10-...-2-1
      expect(schedule.first, equals(1));
      expect(schedule.last, equals(1));
      expect(schedule[9], equals(10)); // Peak at middle
    });

    test('generates symmetrical schedule', () {
      for (int peak = 3; peak <= 10; peak++) {
        final schedule = buildRoundSchedule(peak);

        // Check symmetry
        for (int i = 0; i < schedule.length ~/ 2; i++) {
          expect(schedule[i], equals(schedule[schedule.length - 1 - i]),
              reason: 'Schedule should be symmetrical for peak $peak');
        }
      }
    });

    test('has peak at correct position', () {
      for (int peak = 3; peak <= 10; peak++) {
        final schedule = buildRoundSchedule(peak);
        final maxCards = schedule.reduce((a, b) => a > b ? a : b);
        final peakIndex = schedule.indexOf(maxCards);

        // Peak should be at the middle
        final expectedPeakIndex = schedule.length ~/ 2;
        expect(peakIndex, equals(expectedPeakIndex),
            reason: 'Peak should be at middle for peak $peak');
        expect(maxCards, equals(peak),
            reason: 'Max cards should equal peak parameter');
      }
    });

    test('handles edge cases', () {
      expect(() => buildRoundSchedule(1), throwsArgumentError);
      expect(() => buildRoundSchedule(0), throwsArgumentError);
      expect(() => buildRoundSchedule(-1), throwsArgumentError);
    });

    test('ensures progression consistency', () {
      for (int peak = 3; peak <= 10; peak++) {
        final schedule = buildRoundSchedule(peak);

        // Verify ascending phase
        for (int i = 0; i < schedule.length ~/ 2; i++) {
          expect(schedule[i] < schedule[i + 1], isTrue,
              reason: 'Schedule should be ascending in first half');
        }

        // Verify descending phase
        for (int i = schedule.length ~/ 2 + 1; i < schedule.length - 1; i++) {
          expect(schedule[i] > schedule[i + 1], isTrue,
              reason: 'Schedule should be descending in second half');
        }
      }
    });

    test('schedule starts and ends with minimum cards (1)', () {
      for (int peak = 3; peak <= 10; peak++) {
        final schedule = buildRoundSchedule(peak);

        expect(schedule.first, equals(1),
            reason: 'Schedule should start with 1 card');
        expect(schedule.last, equals(1),
            reason: 'Schedule should end with 1 card');
      }
    });

    test('schedule length is correct for given peak', () {
      for (int peak = 2; peak <= 10; peak++) {
        final schedule = buildRoundSchedule(peak);
        final expectedLength = 2 * peak - 1;
        expect(schedule.length, equals(expectedLength),
            reason: 'Schedule length should be 2*peak-1 for peak $peak');
      }
    });
  });
}
