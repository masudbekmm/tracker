import '../../../models/phase.dart';

class PhaseWithProgress {
  final Phase phase;
  final int completedDays;

  const PhaseWithProgress({required this.phase, required this.completedDays});

  double get progress => phase.totalDays == 0 ? 0 : completedDays / phase.totalDays;
}

class PhasesState {
  final List<PhaseWithProgress> phases;
  final bool loading;

  const PhasesState({this.phases = const [], this.loading = true});
}