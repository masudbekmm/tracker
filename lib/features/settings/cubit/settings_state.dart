import 'package:flutter/material.dart';
import '../../../models/task.dart';

class NotifPrefs {
  final bool morningDsa;
  final TimeOfDay morningDsaTime;

  final bool eveningChecklist;
  final TimeOfDay eveningChecklistTime;

  final bool sundayJournal;
  final TimeOfDay sundayJournalTime;

  const NotifPrefs({
    this.morningDsa = false,
    this.morningDsaTime = const TimeOfDay(hour: 9, minute: 0),
    this.eveningChecklist = false,
    this.eveningChecklistTime = const TimeOfDay(hour: 20, minute: 0),
    this.sundayJournal = false,
    this.sundayJournalTime = const TimeOfDay(hour: 19, minute: 0),
  });

  NotifPrefs copyWith({
    bool? morningDsa,
    TimeOfDay? morningDsaTime,
    bool? eveningChecklist,
    TimeOfDay? eveningChecklistTime,
    bool? sundayJournal,
    TimeOfDay? sundayJournalTime,
  }) {
    return NotifPrefs(
      morningDsa: morningDsa ?? this.morningDsa,
      morningDsaTime: morningDsaTime ?? this.morningDsaTime,
      eveningChecklist: eveningChecklist ?? this.eveningChecklist,
      eveningChecklistTime: eveningChecklistTime ?? this.eveningChecklistTime,
      sundayJournal: sundayJournal ?? this.sundayJournal,
      sundayJournalTime: sundayJournalTime ?? this.sundayJournalTime,
    );
  }
}

class SettingsState {
  final List<Task> tasks;
  final NotifPrefs notifPrefs;
  final bool loading;

  const SettingsState({
    this.tasks = const [],
    this.notifPrefs = const NotifPrefs(),
    this.loading = true,
  });

  SettingsState copyWith({
    List<Task>? tasks,
    NotifPrefs? notifPrefs,
    bool? loading,
  }) {
    return SettingsState(
      tasks: tasks ?? this.tasks,
      notifPrefs: notifPrefs ?? this.notifPrefs,
      loading: loading ?? this.loading,
    );
  }
}