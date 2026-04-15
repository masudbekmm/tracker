import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/phases_cubit.dart';
import '../cubit/phases_state.dart';
import 'phase_detail_screen.dart';

class PhasesScreen extends StatefulWidget {
  const PhasesScreen({super.key});

  @override
  State<PhasesScreen> createState() => _PhasesScreenState();
}

class _PhasesScreenState extends State<PhasesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PhasesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phases')),
      body: BlocBuilder<PhasesCubit, PhasesState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: state.phases
                .map((p) => _PhaseCard(
                      pwp: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhaseDetailScreen(pwp: p),
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final PhaseWithProgress pwp;
  final VoidCallback onTap;

  const _PhaseCard({required this.pwp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final phase = pwp.phase;
    final isActive = phase.isActive;
    final pct = pwp.progress.clamp(0.0, 1.0);
    final fmt = DateFormat('MMM d');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Month ${phase.number}',
                    style: TextStyle(
                      color: isActive ? AppColors.accent : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'active',
                    style: TextStyle(color: AppColors.accent, fontSize: 11),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              phase.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${fmt.format(phase.startDate)} – ${fmt.format(phase.endDate)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${pwp.completedDays} / ${phase.totalDays} days',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
    );
  }
}