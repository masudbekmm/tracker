import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/notifications/notification_service.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../../models/task.dart';
import '../widgets/task_form_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // ── Notifications ──────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              _NotifTile(
                title: 'Morning DSA',
                repeat: 'daily',
                time: state.notifPrefs.morningDsaTime,
                enabled: state.notifPrefs.morningDsa,
                onToggle: (v) => _toggleNotif(context, () =>
                    context.read<SettingsCubit>().toggleMorningDsa(v)),
                onTimeTap: () => _pickTime(
                  context,
                  state.notifPrefs.morningDsaTime,
                  context.read<SettingsCubit>().setMorningDsaTime,
                ),
                onTest: () => _sendTest(context, 'Morning DSA',
                    '45 min. Open the app, mark it done.'),
              ),
              _NotifTile(
                title: 'Evening checklist',
                repeat: 'daily',
                time: state.notifPrefs.eveningChecklistTime,
                enabled: state.notifPrefs.eveningChecklist,
                onToggle: (v) => _toggleNotif(context, () =>
                    context.read<SettingsCubit>().toggleEveningChecklist(v)),
                onTimeTap: () => _pickTime(
                  context,
                  state.notifPrefs.eveningChecklistTime,
                  context.read<SettingsCubit>().setEveningChecklistTime,
                ),
                onTest: () => _sendTest(context, "Evening checklist",
                    "Did you finish today's checklist?"),
              ),
              _NotifTile(
                title: 'Sunday journal',
                repeat: 'Sundays',
                time: state.notifPrefs.sundayJournalTime,
                enabled: state.notifPrefs.sundayJournal,
                onToggle: (v) => _toggleNotif(context, () =>
                    context.read<SettingsCubit>().toggleSundayJournal(v)),
                onTimeTap: () => _pickTime(
                  context,
                  state.notifPrefs.sundayJournalTime,
                  context.read<SettingsCubit>().setSundayJournalTime,
                ),
                onTest: () => _sendTest(context, 'Sunday journal',
                    "Reflect on the week. What clicked? What didn't?"),
              ),
              // ── Tasks ──────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 10),
                child: Text(
                  'TASKS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ...state.tasks.map((task) => _TaskTile(
                    task: task,
                    onEdit: () => _openForm(context, existing: task),
                    onToggle: () => context.read<SettingsCubit>().toggleActive(task),
                    onDelete: () => _confirmDelete(context, task),
                  )),
              if (state.tasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text(
                      'No tasks yet. Tap + to add one.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Ensures permission is granted before actually toggling
  Future<void> _toggleNotif(BuildContext context, Future<void> Function() toggle) async {
    final notif = NotificationService.instance;
    final granted = await notif.requestPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable notifications in iOS Settings to use this.'),
          backgroundColor: AppColors.card,
        ),
      );
      return;
    }
    await toggle();
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay current,
    Future<void> Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) await onPicked(picked);
  }

  Future<void> _sendTest(BuildContext context, String title, String body) async {
    final notif = NotificationService.instance;
    final granted = await notif.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission required.'),
          backgroundColor: AppColors.card,
        ),
      );
      return;
    }
    await notif.sendTest(title: title, body: body, delaySeconds: 5);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification in 5 seconds — lock your screen.'),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  Future<void> _openForm(BuildContext context, {Task? existing}) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => TaskFormDialog(existing: existing),
    );
    if (result == null || !context.mounted) return;
    if (existing != null) {
      context.read<SettingsCubit>().updateTask(result);
    } else {
      context.read<SettingsCubit>().addTask(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete task', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Delete "${task.name}"? This also removes all its history.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SettingsCubit>().deleteTask(task.id!);
    }
  }
}

class _NotifTile extends StatelessWidget {
  final String title;
  final String repeat;
  final TimeOfDay time;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;
  final VoidCallback onTest;

  const _NotifTile({
    required this.title,
    required this.repeat,
    required this.time,
    required this.enabled,
    required this.onToggle,
    required this.onTimeTap,
    required this.onTest,
  });

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Tappable time chip
                      GestureDetector(
                        onTap: onTimeTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _fmt(time),
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 10,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(repeat,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Test button
            IconButton(
              icon: const Icon(Icons.send_outlined, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Send test (5s)',
              onPressed: onTest,
            ),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accentDim,
              inactiveTrackColor: AppColors.surface,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String _daysLabel() {
    if (task.days.isEmpty) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return task.days.map((d) => names[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(
          task.name,
          style: TextStyle(
            color: task.isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 15,
            decoration: task.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          [
            _daysLabel(),
            if (task.duration != null) task.duration!,
          ].join(' · '),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: task.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accentDim,
              inactiveTrackColor: AppColors.surface,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.textSecondary,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.textSecondary,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}