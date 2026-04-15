import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/today_cubit.dart';
import '../cubit/today_state.dart';
import '../widgets/task_row.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TodayCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              _currentPhase(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<TodayCubit, TodayState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _StreakCard(streak: state.streak),
              const SizedBox(height: 16),
              _ProgressBar(done: state.doneTasks, total: state.totalTasks),
              const SizedBox(height: 20),
              if (state.items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'No tasks scheduled today.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...state.items.map(
                  (item) => TaskRow(
                    item: item,
                    onTap: () => context.read<TodayCubit>().toggle(item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _currentPhase() {
    final now = DateTime.now();
    final phases = [
      ('Month 1 — Kotlin', DateTime(2026, 4, 14), DateTime(2026, 5, 11)),
      ('Month 2 — Swift', DateTime(2026, 5, 12), DateTime(2026, 6, 8)),
      ('Month 3 — Embedded AI', DateTime(2026, 6, 9), DateTime(2026, 7, 6)),
      ('Month 4 — Polish', DateTime(2026, 7, 7), DateTime(2026, 8, 3)),
      ('Month 5 — Job Hunt', DateTime(2026, 8, 4), DateTime(2026, 9, 14)),
    ];
    for (final (name, start, end) in phases) {
      if (!now.isBefore(start) && !now.isAfter(end)) return name;
    }
    return 'No active phase';
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: streak > 0
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Text(
            streak > 0 ? '🔥' : '—',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day${streak == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'current streak',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressBar({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$done / $total done',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.card,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}