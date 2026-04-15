import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/db/database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../models/task.dart';
import 'settings_state.dart';

// Toggle keys
const _kNotifMorningDsa = 'notif_morning_dsa';
const _kNotifEveningChecklist = 'notif_evening_checklist';
const _kNotifSundayJournal = 'notif_sunday_journal';
// Time keys (stored as "HH:mm")
const _kTimeMorningDsa = 'notif_morning_dsa_time';
const _kTimeEveningChecklist = 'notif_evening_checklist_time';
const _kTimeSundayJournal = 'notif_sunday_journal_time';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  final _db = AppDatabase.instance;
  final _notif = NotificationService.instance;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final tasks = await _db.getTasks();
    final prefs = await _loadNotifPrefs();
    emit(SettingsState(tasks: tasks, notifPrefs: prefs, loading: false));
  }

  Future<NotifPrefs> _loadNotifPrefs() async {
    return NotifPrefs(
      morningDsa: await _db.getSetting(_kNotifMorningDsa) == '1',
      morningDsaTime: await _loadTime(_kTimeMorningDsa, const TimeOfDay(hour: 9, minute: 0)),
      eveningChecklist: await _db.getSetting(_kNotifEveningChecklist) == '1',
      eveningChecklistTime: await _loadTime(_kTimeEveningChecklist, const TimeOfDay(hour: 20, minute: 0)),
      sundayJournal: await _db.getSetting(_kNotifSundayJournal) == '1',
      sundayJournalTime: await _loadTime(_kTimeSundayJournal, const TimeOfDay(hour: 19, minute: 0)),
    );
  }

  Future<TimeOfDay> _loadTime(String key, TimeOfDay fallback) async {
    final raw = await _db.getSetting(key);
    if (raw == null) return fallback;
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _timeKey(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Notification toggles ─────────────────────────────────────────────────

  Future<void> toggleMorningDsa(bool value) async {
    await _db.setSetting(_kNotifMorningDsa, value ? '1' : '0');
    final t = state.notifPrefs.morningDsaTime;
    if (value) {
      await _notif.scheduleMorningDsa(hour: t.hour, minute: t.minute);
    } else {
      await _notif.cancelMorningDsa();
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(morningDsa: value)));
  }

  Future<void> toggleEveningChecklist(bool value) async {
    await _db.setSetting(_kNotifEveningChecklist, value ? '1' : '0');
    final t = state.notifPrefs.eveningChecklistTime;
    if (value) {
      await _notif.scheduleEveningChecklist(hour: t.hour, minute: t.minute);
    } else {
      await _notif.cancelEveningChecklist();
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(eveningChecklist: value)));
  }

  Future<void> toggleSundayJournal(bool value) async {
    await _db.setSetting(_kNotifSundayJournal, value ? '1' : '0');
    final t = state.notifPrefs.sundayJournalTime;
    if (value) {
      await _notif.scheduleSundayJournal(hour: t.hour, minute: t.minute);
    } else {
      await _notif.cancelSundayJournal();
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(sundayJournal: value)));
  }

  // ─── Time changes ─────────────────────────────────────────────────────────

  Future<void> setMorningDsaTime(TimeOfDay time) async {
    await _db.setSetting(_kTimeMorningDsa, _timeKey(time));
    // Reschedule if enabled
    if (state.notifPrefs.morningDsa) {
      await _notif.scheduleMorningDsa(hour: time.hour, minute: time.minute);
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(morningDsaTime: time)));
  }

  Future<void> setEveningChecklistTime(TimeOfDay time) async {
    await _db.setSetting(_kTimeEveningChecklist, _timeKey(time));
    if (state.notifPrefs.eveningChecklist) {
      await _notif.scheduleEveningChecklist(hour: time.hour, minute: time.minute);
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(eveningChecklistTime: time)));
  }

  Future<void> setSundayJournalTime(TimeOfDay time) async {
    await _db.setSetting(_kTimeSundayJournal, _timeKey(time));
    if (state.notifPrefs.sundayJournal) {
      await _notif.scheduleSundayJournal(hour: time.hour, minute: time.minute);
    }
    emit(state.copyWith(notifPrefs: state.notifPrefs.copyWith(sundayJournalTime: time)));
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    final saved = await _db.insertTask(task);
    emit(state.copyWith(tasks: [...state.tasks, saved]));
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    final tasks = state.tasks.map((t) => t.id == task.id ? task : t).toList();
    emit(state.copyWith(tasks: tasks));
  }

  Future<void> toggleActive(Task task) async {
    await updateTask(task.copyWith(isActive: !task.isActive));
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    final tasks = state.tasks.where((t) => t.id != id).toList();
    emit(state.copyWith(tasks: tasks));
  }
}