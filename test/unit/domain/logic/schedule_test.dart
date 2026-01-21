// test/unit/domain/logic/schedule_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/schedule.dart';

void main() {
  group('Schedule Generation', () {
    test('generates correct schedule for 3 players', () {
      final schedule = generateSchedule(3);

      expect(schedule.length, equals(7)); // 3-4-5-6-5-4-3
      expect(schedule, equals([3, 4, 5, 6, 5, 4, 3]));
    });

    test('generates correct schedule for 4 players', () {
      final schedule = generateSchedule(4);

      expect(schedule.length, equals(9)); // 4-5-6-7-8-7-6-5-4
      expect(schedule, equals([4, 5, 6, 7, 8, 7, 6, 5, 4]));
    });

    test('generates correct schedule for 5 players', () {
      final schedule = generateSchedule(5);

      expect(schedule.length, equals(11)); // 5-6-7-8-9-10-9-8-7-6-5
      expect(schedule, equals([5, 6, 7, 8, 9, 10, 9, 8, 7, 6, 5]));
    });

    test('generates correct schedule for 6 players', () {
      final schedule = generateSchedule(6);

      expect(schedule.length, equals(13)); // 6-7-8-9-10-11-12-11-10-9-8-7-6
      expect(schedule, equals([6, 7, 8, 9, 10, 11, 12, 11, 10, 9, 8, 7, 6]));
    });

    test('generates symmetrical schedule', () {
      for (int players = 3; players <= 6; players++) {
        final schedule = generateSchedule(players);

        // Check symmetry
        for (int i = 0; i < schedule.length ~/ 2; i++) {
          expect(schedule[i], equals(schedule[schedule.length - 1 - i]),
              reason: 'Schedule should be symmetrical for $players players');
        }
      }
    });

    test('has peak at correct position', () {
      for (int players = 3; players <= 6; players++) {
        final schedule = generateSchedule(players);
        final peak = schedule.reduce((a, b) => a > b ? a : b);
        final peakIndex = schedule.indexOf(peak);

        // Peak should be in the middle
        expect(peakIndex, equals(schedule.length ~/ 2),
            reason: 'Peak should be at center for $players players');

        // Peak should equal players + number of rounds up
        final expectedPeak = players + (schedule.length ~/ 2);
        expect(peak, equals(expectedPeak),
            reason: 'Peak value incorrect for $players players');
      }
    });

    test('throws exception for invalid player count', () {
      expect(() => generateSchedule(2), throwsArgumentError);
      expect(() => generateSchedule(7), throwsArgumentError);
      expect(() => generateSchedule(0), throwsArgumentError);
      expect(() => generateSchedule(-1), throwsArgumentError);
    });

    test('each round has valid card count', () {
      for (int players = 3; players <= 6; players++) {
        final schedule = generateSchedule(players);

        for (final cards in schedule) {
          expect(cards, greaterThanOrEqualTo(players),
              reason: 'Cards must be >= player count');
          expect(cards, lessThanOrEqualTo(13),
              reason: 'Cards must be <= 13 (deck limit per suit)');
        }
      }
    });

    test('schedule progression is consistent', () {
      for (int players = 3; players <= 6; players++) {
        final schedule = generateSchedule(players);
        final mid = schedule.length ~/ 2;

        // Ascending part
        for (int i = 0; i < mid; i++) {
          expect(schedule[i + 1], equals(schedule[i] + 1),
              reason: 'Ascending part should increment by 1');
        }

        // Descending part
        for (int i = mid + 1; i < schedule.length - 1; i++) {
          expect(schedule[i + 1], equals(schedule[i] - 1),
              reason: 'Descending part should decrement by 1');
        }
      }
    });
  });
}
