import '../../../models/task.dart';
import '../../../models/task_log.dart';

class TodayItem {
  final Task task;
  final TaskLog? log;

  const TodayItem({required this.task, this.log});

  bool get isDone => log?.isDone ?? false;
}

class TodayState {
  final List<TodayItem> items;
  final int streak;
  final bool loading;

  const TodayState({
    this.items = const [],
    this.streak = 0,
    this.loading = true,
  });

  int get totalTasks => items.length;
  int get doneTasks => items.where((i) => i.isDone).length;
  bool get allDone => totalTasks > 0 && doneTasks == totalTasks;

  TodayState copyWith({
    List<TodayItem>? items,
    int? streak,
    bool? loading,
  }) {
    return TodayState(
      items: items ?? this.items,
      streak: streak ?? this.streak,
      loading: loading ?? this.loading,
    );
  }
}