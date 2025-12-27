// lib/domain/logic/schedule.dart
List<int> buildRoundSchedule(int peakCards) {
  if (peakCards < 2) throw ArgumentError('peakCards must be >= 2');
  final up = List<int>.generate(peakCards, (i) => i + 1);          // 1..P
  final down = List<int>.generate(peakCards - 1, (i) => peakCards - 1 - i); // P-1..1
  return [...up, ...down];
}
