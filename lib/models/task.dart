class Task {
  final int? id;
  final String name;
  final String? duration;
  // days: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
  // empty list means every day
  final List<int> days;
  final bool isActive;

  const Task({
    this.id,
    required this.name,
    this.duration,
    required this.days,
    this.isActive = true,
  });

  bool isScheduledOn(DateTime date) {
    if (days.isEmpty) return true;
    return days.contains(date.weekday); // DateTime.monday == 1, .sunday == 7
  }

  Task copyWith({
    int? id,
    String? name,
    String? duration,
    List<int>? days,
    bool? isActive,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'duration': duration,
      'days': days.join(','),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final daysStr = map['days'] as String? ?? '';
    final days = daysStr.isEmpty
        ? <int>[]
        : daysStr.split(',').map(int.parse).toList();
    return Task(
      id: map['id'] as int?,
      name: map['name'] as String,
      duration: map['duration'] as String?,
      days: days,
      isActive: (map['is_active'] as int) == 1,
    );
  }
}