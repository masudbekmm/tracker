import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/db/database.dart';
import 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  WeeklyCubit() : super(const WeeklyState());

  final _db = AppDatabase.instance;

  Future<void> load() async {
    emit(const WeeklyState(loading: true));

    final now = DateTime.now();
    // Start from Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final monday0 = DateTime(monday.year, monday.month, monday.day);
    final sunday = monday0.add(const Duration(days: 6));

    final tasks = await _db.getTasks(activeOnly: true);
    final logs = await _db.getLogsForRange(monday0, sunday);
    final logMap = <String, bool>{};
    for (final l in logs) {
      logMap['${l.taskId}_${l.date.toIso8601String().substring(0, 10)}'] = l.isDone;
    }

    final week = List.generate(7, (i) {
      final day = monday0.add(Duration(days: i));
      final dayTasks = tasks.where((t) => t.isScheduledOn(day)).toList();
      final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final done = dayTasks.where((t) => logMap['${t.id}_$dateKey'] == true).length;
      return DayStatus(date: day, total: dayTasks.length, done: done);
    });

    emit(WeeklyState(week: week, loading: false));
  }
}