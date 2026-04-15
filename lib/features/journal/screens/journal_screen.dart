import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../../../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _clickedCtrl = TextEditingController();
  final _confusingCtrl = TextEditingController();
  final _builtCtrl = TextEditingController();

  bool get _isSunday => DateTime.now().weekday == DateTime.sunday;

  @override
  void initState() {
    super.initState();
    context.read<JournalCubit>().load();
  }

  void _syncControllers(JournalEntry? entry) {
    if (entry != null) {
      _clickedCtrl.text = entry.whatClicked;
      _confusingCtrl.text = entry.stillConfusing;
      _builtCtrl.text = entry.whatIBuilt;
    } else {
      _clickedCtrl.clear();
      _confusingCtrl.clear();
      _builtCtrl.clear();
    }
  }

  @override
  void dispose() {
    _clickedCtrl.dispose();
    _confusingCtrl.dispose();
    _builtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: BlocConsumer<JournalCubit, JournalState>(
        listenWhen: (prev, curr) => prev.loading && !curr.loading,
        listener: (context, state) => _syncControllers(state.currentWeekEntry),
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _ThisWeekSection(
                clickedCtrl: _clickedCtrl,
                confusingCtrl: _confusingCtrl,
                builtCtrl: _builtCtrl,
                isSunday: _isSunday,
                saving: state.saving,
                onSave: () {
                  context.read<JournalCubit>().save(
                        whatClicked: _clickedCtrl.text,
                        stillConfusing: _confusingCtrl.text,
                        whatIBuilt: _builtCtrl.text,
                      );
                  FocusScope.of(context).unfocus();
                },
              ),
              if (state.entries.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'PAST ENTRIES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                ...state.entries
                    .where((e) {
                      final ws = JournalCubit.currentWeekStart;
                      return !_isSameDay(e.weekStart, ws);
                    })
                    .map((e) => _PastEntryCard(entry: e)),
              ],
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ThisWeekSection extends StatelessWidget {
  final TextEditingController clickedCtrl;
  final TextEditingController confusingCtrl;
  final TextEditingController builtCtrl;
  final bool isSunday;
  final bool saving;
  final VoidCallback onSave;

  const _ThisWeekSection({
    required this.clickedCtrl,
    required this.confusingCtrl,
    required this.builtCtrl,
    required this.isSunday,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'This week',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isSunday) ...[
              const SizedBox(width: 10),
              const Text(
                '(editable on Sunday)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _JournalField(
          label: 'What clicked this week?',
          controller: clickedCtrl,
          enabled: isSunday,
        ),
        const SizedBox(height: 12),
        _JournalField(
          label: 'What still confuses me?',
          controller: confusingCtrl,
          enabled: isSunday,
        ),
        const SizedBox(height: 12),
        _JournalField(
          label: 'What did I build?',
          controller: builtCtrl,
          enabled: isSunday,
        ),
        if (isSunday) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Text('Save entry', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }
}

class _JournalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _JournalField({
    required this.label,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: enabled ? 'Write here...' : '—',
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PastEntryCard extends StatelessWidget {
  final JournalEntry entry;
  const _PastEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    // Show week ending (Sunday)
    final weekEnd = entry.weekStart.add(const Duration(days: 6));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            'Week of ${fmt.format(entry.weekStart)} – ${DateFormat('MMM d').format(weekEnd)}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            _Field('What clicked', entry.whatClicked),
            const SizedBox(height: 10),
            _Field('Still confusing', entry.stillConfusing),
            const SizedBox(height: 10),
            _Field('What I built', entry.whatIBuilt),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}