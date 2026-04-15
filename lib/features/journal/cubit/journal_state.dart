import '../../../models/journal_entry.dart';

class JournalState {
  final List<JournalEntry> entries;
  final JournalEntry? currentWeekEntry;
  final bool loading;
  final bool saving;

  const JournalState({
    this.entries = const [],
    this.currentWeekEntry,
    this.loading = true,
    this.saving = false,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    JournalEntry? currentWeekEntry,
    bool? loading,
    bool? saving,
    bool clearCurrentWeek = false,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      currentWeekEntry: clearCurrentWeek ? null : currentWeekEntry ?? this.currentWeekEntry,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
    );
  }
}