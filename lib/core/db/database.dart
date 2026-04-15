import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/task.dart';
import '../../models/task_log.dart';
import '../../models/journal_entry.dart';
import '../../models/phase.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration TEXT,
        days TEXT NOT NULL DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE task_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        UNIQUE(task_id, date),
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start TEXT NOT NULL UNIQUE,
        what_clicked TEXT NOT NULL DEFAULT '',
        still_confusing TEXT NOT NULL DEFAULT '',
        what_i_built TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE phases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        title TEXT NOT NULL,
        focus TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        goals TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed default tasks
    final tasks = [
      {'name': 'DSA', 'duration': '45min', 'days': '', 'is_active': 1},
      {'name': 'Arabic', 'duration': '30min', 'days': '', 'is_active': 1},
      {'name': 'Swift', 'duration': '1hr', 'days': '', 'is_active': 1},
      {'name': 'Kotlin', 'duration': '1hr', 'days': '', 'is_active': 1},
      {'name': 'Practice (Swift + Kotlin)', 'duration': '1hr', 'days': '', 'is_active': 1},
      {'name': 'Main work', 'duration': null, 'days': '', 'is_active': 1},
      {'name': 'Workout', 'duration': null, 'days': '1,2,3,4,5', 'is_active': 1},
      {'name': 'Sunday docs', 'duration': null, 'days': '7', 'is_active': 1},
    ];
    for (final t in tasks) {
      await db.insert('tasks', t);
    }

    // Seed phases
    final phases = [
      {
        'number': 1,
        'title': 'Kotlin + HBand core',
        'focus': 'Kotlin',
        'start_date': '2026-04-14',
        'end_date': '2026-05-11',
        'goals': 'DSA daily in Kotlin (easy → medium)||HBand integration: break, understand, rebuild||Arabic 30 min daily||Sunday: document what you learned',
      },
      {
        'number': 2,
        'title': 'Swift + HBand features',
        'focus': 'Swift',
        'start_date': '2026-05-12',
        'end_date': '2026-06-08',
        'goals': 'DSA in Kotlin + Swift + Dart (rotate)||Add HBand features, understand each deeply||Arabic continues||Sunday: English prompt analysis + documentation',
      },
      {
        'number': 3,
        'title': 'Embedded AI enters',
        'focus': 'Embedded AI',
        'start_date': '2026-06-09',
        'end_date': '2026-07-06',
        'goals': 'Start local AI experiments on device||DSA intensity increases — more mediums||HBand data + local model = first prototype||Document everything with PhD lens',
      },
      {
        'number': 4,
        'title': 'Deepen + polish',
        'focus': 'Polish',
        'start_date': '2026-07-07',
        'end_date': '2026-08-03',
        'goals': 'DSA pushing into hards||HBand + local AI more refined||Portfolio starts taking shape||Document architecture decisions',
      },
      {
        'number': 5,
        'title': 'Job hunt ready',
        'focus': 'Job Hunt',
        'start_date': '2026-08-04',
        'end_date': '2026-09-14',
        'goals': 'DSA sharp — hard problems||Two languages solid||Real project with AI component in portfolio||Research interest becoming clearer',
      },
    ];
    for (final p in phases) {
      await db.insert('phases', p);
    }
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  Future<List<Task>> getTasks({bool activeOnly = false}) async {
    final d = await db;
    final where = activeOnly ? 'WHERE is_active = 1' : '';
    final rows = await d.rawQuery('SELECT * FROM tasks $where ORDER BY id');
    return rows.map(Task.fromMap).toList();
  }

  Future<Task> insertTask(Task task) async {
    final d = await db;
    final id = await d.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<void> updateTask(Task task) async {
    final d = await db;
    await d.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final d = await db;
    await d.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Task Logs ────────────────────────────────────────────────────────────

  Future<List<TaskLog>> getLogsForDate(DateTime date) async {
    final d = await db;
    final key = _dateKey(date);
    final rows = await d.query('task_logs', where: 'date = ?', whereArgs: [key]);
    return rows.map(TaskLog.fromMap).toList();
  }

  Future<List<TaskLog>> getLogsForRange(DateTime from, DateTime to) async {
    final d = await db;
    final rows = await d.query(
      'task_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [_dateKey(from), _dateKey(to)],
    );
    return rows.map(TaskLog.fromMap).toList();
  }

  Future<void> upsertLog(TaskLog log) async {
    final d = await db;
    await d.insert(
      'task_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Journal ──────────────────────────────────────────────────────────────

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final d = await db;
    final rows = await d.query('journal_entries', orderBy: 'week_start DESC');
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<JournalEntry?> getJournalEntryForWeek(DateTime weekStart) async {
    final d = await db;
    final rows = await d.query(
      'journal_entries',
      where: 'week_start = ?',
      whereArgs: [_dateKey(weekStart)],
    );
    if (rows.isEmpty) return null;
    return JournalEntry.fromMap(rows.first);
  }

  Future<void> upsertJournalEntry(JournalEntry entry) async {
    final d = await db;
    await d.insert(
      'journal_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final d = await db;
    final rows = await d.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final d = await db;
    await d.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Phases ───────────────────────────────────────────────────────────────

  Future<List<Phase>> getPhases() async {
    final d = await db;
    final rows = await d.query('phases', orderBy: 'number');
    return rows.map(Phase.fromMap).toList();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}