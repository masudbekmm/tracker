import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/db/database.dart';
import 'phases_state.dart';

class PhasesCubit extends Cubit<PhasesState> {
  PhasesCubit() : super(const PhasesState());

  final _db = AppDatabase.instance;

  Future<void> load() async {
    emit(const PhasesState(loading: true));

    final phases = await _db.getPhases();
    final tasks = await _db.getTasks(activeOnly: true);

    final result = await Future.wait(phases.map((phase) async {
      final logs = await _db.getLogsForRange(phase.startDate, phase.endDate);
      final logMap = <String, bool>{};
      for (final l in logs) {
        logMap['${l.taskId}_${l.date.toIso8601String().substring(0, 10)}'] = l.isDone;
      }

      int completedDays = 0;
      for (int i = 0; i < phase.totalDays; i++) {
        final day = phase.startDate.add(Duration(days: i));
        if (day.isAfter(DateTime.now())) break;
        final dayTasks = tasks.where((t) => t.isScheduledOn(day)).toList();
        if (dayTasks.isEmpty) continue;
        final dateKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final allDone = dayTasks.every((t) => logMap['${t.id}_$dateKey'] == true);
        if (allDone) completedDays++;
      }

      return PhaseWithProgress(phase: phase, completedDays: completedDays);
    }));

    emit(PhasesState(phases: result, loading: false));
  }
}