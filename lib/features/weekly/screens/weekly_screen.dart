import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/weekly_cubit.dart';
import '../cubit/weekly_state.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WeeklyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('This Week')),
      body: BlocBuilder<WeeklyCubit, WeeklyState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _WeekGrid(week: state.week),
              const SizedBox(height: 20),
              _CompletionSummary(pct: state.completionPct),
              const SizedBox(height: 24),
              const Text(
                'Daily breakdown',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ...state.week.map((d) => _DayRow(day: d)),
            ],
          );
        },
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  final List<DayStatus> week;
  const _WeekGrid({required this.week});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: week.map((d) {
        Color dotColor;
        if (d.hasNoTasks) {
          dotColor = AppColors.surface;
        } else if (d.isFullyDone) {
          dotColor = AppColors.done;
        } else if (d.isPartial) {
          dotColor = AppColors.partial;
        } else {
          dotColor = AppColors.missed;
        }

        final isToday = _isSameDay(d.date, DateTime.now());

        return Column(
          children: [
            Text(
              DateFormat('EEE').format(d.date).toUpperCase(),
              style: TextStyle(
                color: isToday ? AppColors.accent : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.accent, width: 2)
                    : null,
              ),
              child: d.isFullyDone
                  ? const Icon(Icons.check, size: 16, color: AppColors.background)
                  : (!d.hasNoTasks && !d.isMissed)
                      ? Center(
                          child: Text(
                            '${d.done}/${d.total}',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CompletionSummary extends StatelessWidget {
  final double pct;
  const _CompletionSummary({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(pct * 100).round()}% this week',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final DayStatus day;
  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(day.date, DateTime.now());
    final isFuture = day.date.isAfter(DateTime.now());

    Color statusColor;
    String statusText;
    if (day.hasNoTasks) {
      statusColor = AppColors.textSecondary;
      statusText = 'no tasks';
    } else if (isFuture) {
      statusColor = AppColors.textSecondary;
      statusText = '${day.total} scheduled';
    } else if (day.isFullyDone) {
      statusColor = AppColors.done;
      statusText = 'complete';
    } else if (day.isPartial) {
      statusColor = AppColors.partial;
      statusText = '${day.done}/${day.total} done';
    } else {
      statusColor = AppColors.error;
      statusText = 'missed';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              DateFormat('EEEE').format(day.date),
              style: TextStyle(
                color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const Spacer(),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}