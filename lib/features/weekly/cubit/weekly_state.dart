class DayStatus {
  final DateTime date;
  final int total;
  final int done;

  const DayStatus({required this.date, required this.total, required this.done});

  bool get isFullyDone => total > 0 && done == total;
  bool get isPartial => done > 0 && done < total;
  bool get isMissed => total > 0 && done == 0;
  bool get hasNoTasks => total == 0;
}

class WeeklyState {
  final List<DayStatus> week; // 7 items Mon–Sun
  final bool loading;

  const WeeklyState({this.week = const [], this.loading = true});

  double get completionPct {
    final relevant = week.where((d) => !d.hasNoTasks);
    if (relevant.isEmpty) return 0;
    return relevant.where((d) => d.isFullyDone).length / relevant.length;
  }
}