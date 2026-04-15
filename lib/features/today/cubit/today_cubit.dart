import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/db/database.dart';
import '../../../models/task_log.dart';
import 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit() : super(const TodayState());

  final _db = AppDatabase.instance;
  final _today = DateTime.now();

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    final tasks = await _db.getTasks(activeOnly: true);
    final todayTasks = tasks.where((t) => t.isScheduledOn(_today)).toList();
    final logs = await _db.getLogsForDate(_today);
    final logMap = {for (final l in logs) l.taskId: l};

    final items = todayTasks.map((t) => TodayItem(task: t, log: logMap[t.id])).toList();
    final streak = await _calculateStreak(tasks);

    emit(TodayState(items: items, streak: streak, loading: false));
  }

  Future<void> toggle(TodayItem item) async {
    final taskId = item.task.id!;
    final newDone = !item.isDone;

    final log = TaskLog(
      id: item.log?.id,
      taskId: taskId,
      date: _today,
      isDone: newDone,
    );
    await _db.upsertLog(log);

    final updatedItems = state.items.map((i) {
      if (i.task.id == taskId) return TodayItem(task: i.task, log: log);
      return i;
    }).toList();

    final streak = await _calculateStreak(
      updatedItems.map((i) => i.task).toList(),
    );
    emit(state.copyWith(items: updatedItems, streak: streak));
  }

  Future<int> _calculateStreak(List<dynamic> tasks) async {
    int streak = 0;
    DateTime day = _today;

    while (true) {
      final allTasks = await _db.getTasks(activeOnly: true);
      final dayTasks = allTasks.where((t) => t.isScheduledOn(day)).toList();
      if (dayTasks.isEmpty) break;

      final logs = await _db.getLogsForDate(day);
      final logMap = {for (final l in logs) l.taskId: l};
      final allDone = dayTasks.every((t) => logMap[t.id]?.isDone == true);

      if (!allDone) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }
}