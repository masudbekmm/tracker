class JournalEntry {
  final int? id;
  final DateTime weekStart; // Monday of that week
  final String whatClicked;
  final String stillConfusing;
  final String whatIBuilt;

  const JournalEntry({
    this.id,
    required this.weekStart,
    required this.whatClicked,
    required this.stillConfusing,
    required this.whatIBuilt,
  });

  JournalEntry copyWith({
    String? whatClicked,
    String? stillConfusing,
    String? whatIBuilt,
  }) {
    return JournalEntry(
      id: id,
      weekStart: weekStart,
      whatClicked: whatClicked ?? this.whatClicked,
      stillConfusing: stillConfusing ?? this.stillConfusing,
      whatIBuilt: whatIBuilt ?? this.whatIBuilt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'week_start': _dateKey(weekStart),
      'what_clicked': whatClicked,
      'still_confusing': stillConfusing,
      'what_i_built': whatIBuilt,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      weekStart: DateTime.parse(map['week_start'] as String),
      whatClicked: map['what_clicked'] as String,
      stillConfusing: map['still_confusing'] as String,
      whatIBuilt: map['what_i_built'] as String,
    );
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}