class Phase {
  final int? id;
  final int number;
  final String title;
  final String focus;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> goals;

  const Phase({
    this.id,
    required this.number,
    required this.title,
    required this.focus,
    required this.startDate,
    required this.endDate,
    required this.goals,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'number': number,
      'title': title,
      'focus': focus,
      'start_date': _dateKey(startDate),
      'end_date': _dateKey(endDate),
      'goals': goals.join('||'),
    };
  }

  factory Phase.fromMap(Map<String, dynamic> map) {
    final goalsStr = map['goals'] as String? ?? '';
    return Phase(
      id: map['id'] as int?,
      number: map['number'] as int,
      title: map['title'] as String,
      focus: map['focus'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      goals: goalsStr.isEmpty ? [] : goalsStr.split('||'),
    );
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}