// One row = one task completion record for a given date
class TaskLog {
  final int? id;
  final int taskId;
  final DateTime date;
  final bool isDone;

  const TaskLog({
    this.id,
    required this.taskId,
    required this.date,
    required this.isDone,
  });

  TaskLog copyWith({bool? isDone}) {
    return TaskLog(
      id: id,
      taskId: taskId,
      date: date,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'date': _dateKey(date),
      'is_done': isDone ? 1 : 0,
    };
  }

  factory TaskLog.fromMap(Map<String, dynamic> map) {
    return TaskLog(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      date: DateTime.parse(map['date'] as String),
      isDone: (map['is_done'] as int) == 1,
    );
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}