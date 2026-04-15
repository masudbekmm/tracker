import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/db/database.dart';
import '../../../models/journal_entry.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  JournalCubit() : super(const JournalState());

  final _db = AppDatabase.instance;

  static DateTime get currentWeekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final entries = await _db.getAllJournalEntries();
    final current = await _db.getJournalEntryForWeek(currentWeekStart);
    emit(JournalState(
      entries: entries,
      currentWeekEntry: current,
      loading: false,
    ));
  }

  Future<void> save({
    required String whatClicked,
    required String stillConfusing,
    required String whatIBuilt,
  }) async {
    emit(state.copyWith(saving: true));

    final entry = JournalEntry(
      id: state.currentWeekEntry?.id,
      weekStart: currentWeekStart,
      whatClicked: whatClicked,
      stillConfusing: stillConfusing,
      whatIBuilt: whatIBuilt,
    );

    await _db.upsertJournalEntry(entry);
    await load();
  }
}