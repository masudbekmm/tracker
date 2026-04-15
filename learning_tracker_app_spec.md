# Learning Tracker App — Build Spec

A personal progress tracker to hold your 5-month learning plan accountable.
Built in Flutter (naturally), so it also becomes a Dart deepening exercise.

---

## What the App Does

- Tracks daily habits (DSA, main skill, Arabic, documentation)
- Shows weekly progress per phase
- Stores weekly Sunday notes (what clicked, what confused, what I built)
- Later: local notifications for daily reminders

---

## Screens

### 1. Home Screen
- Today's date + current phase name (e.g. "Month 1 — Kotlin")
- Daily checklist with 4 items:
  - DSA (30-45 min)
  - Main skill session (1-2 hrs)
  - Arabic (30 min)
  - Sunday only: documentation + English analysis
- Simple tap to check/uncheck each item
- Streak counter (how many days in a row all items completed)

### 2. Weekly View Screen
- 7-day grid showing which days were fully completed
- Each day shows a dot: green = all done, orange = partial, gray = missed
- Weekly completion percentage

### 3. Phase Overview Screen
- 5 phases displayed as cards:
  - Month 1: Kotlin + HBand core
  - Month 2: Swift + HBand features
  - Month 3: Embedded AI enters
  - Month 4: Deepen + polish
  - Month 5: Job hunt ready
- Each card shows: phase goal, progress bar (days completed / total days)
- Tap a phase to see its details and goals

### 4. Sunday Journal Screen
- Only fully unlocks on Sundays (but readable any day)
- Three text fields:
  - What clicked this week?
  - What still confuses me?
  - What did I build?
- Saves entry with date
- Past entries listed below, newest first

### 5. Settings Screen
- Set phase start date (so progress bars calculate correctly)
- Toggle notification reminders (implement later)
- Reset streak (in case of illness/break)

---

## Data Models

```dart
// Daily log entry
class DayLog {
  final DateTime date;
  bool dsaDone;
  bool mainSkillDone;
  bool arabicDone;
  bool documentationDone; // Sundays only

  DayLog({
    required this.date,
    this.dsaDone = false,
    this.mainSkillDone = false,
    this.arabicDone = false,
    this.documentationDone = false,
  });

  bool get isFullyComplete {
    if (date.weekday == DateTime.sunday) {
      return dsaDone && mainSkillDone && arabicDone && documentationDone;
    }
    return dsaDone && mainSkillDone && arabicDone;
  }
}

// Weekly journal entry
class JournalEntry {
  final DateTime weekStart;
  final String whatClicked;
  final String stillConfusing;
  final String whatIBuilt;

  JournalEntry({
    required this.weekStart,
    required this.whatClicked,
    required this.stillConfusing,
    required this.whatIBuilt,
  });
}

// Phase definition
class Phase {
  final int number;
  final String title;
  final String focus;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> goals;

  Phase({
    required this.number,
    required this.title,
    required this.focus,
    required this.startDate,
    required this.endDate,
    required this.goals,
  });

  int get totalDays => endDate.difference(startDate).inDays;

  int completedDays(List<DayLog> logs) {
    return logs.where((log) =>
      log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      log.date.isBefore(endDate.add(const Duration(days: 1))) &&
      log.isFullyComplete
    ).length;
  }

  double progress(List<DayLog> logs) {
    return completedDays(logs) / totalDays;
  }
}
```

---

## Local Storage

Use `shared_preferences` for simple key-value data.
Use `hive` or `isar` for structured data (DayLog, JournalEntry).

Recommended: **Hive** — lightweight, fast, works great in Flutter, good learning exercise.

```dart
// Hive boxes to open at app start
await Hive.openBox<DayLog>('dayLogs');
await Hive.openBox<JournalEntry>('journal');
await Hive.openBox('settings');
```

---

## State Management

Use **Provider** or **Riverpod** — keep it simple.

Suggested providers:
- `DayLogProvider` — today's log, streak count, weekly data
- `JournalProvider` — all journal entries, save/read
- `PhaseProvider` — current phase, all phases with progress

---

## Navigation

Use `go_router` or simple `Navigator` — 5 screens, no deep nesting needed.

Bottom navigation bar with 4 tabs:
- Today (home icon)
- Week (calendar icon)
- Phases (flag icon)
- Journal (book icon)

Settings reachable via icon in top right of Home screen.

---

## Phase Data (hardcode at start)

```dart
final List<Phase> phases = [
  Phase(
    number: 1,
    title: "Kotlin + HBand core",
    focus: "Kotlin",
    startDate: DateTime(2026, 4, 14),  // adjust to your actual start
    endDate: DateTime(2026, 5, 11),
    goals: [
      "DSA daily in Kotlin (easy → medium)",
      "HBand integration: break, understand, rebuild",
      "Arabic 30 min daily",
      "Sunday: document what you learned",
    ],
  ),
  Phase(
    number: 2,
    title: "Swift + HBand features",
    focus: "Swift",
    startDate: DateTime(2026, 5, 12),
    endDate: DateTime(2026, 6, 8),
    goals: [
      "DSA in Kotlin + Swift + Dart (rotate)",
      "Add HBand features, understand each deeply",
      "Arabic continues",
      "Sunday: English prompt analysis + documentation",
    ],
  ),
  Phase(
    number: 3,
    title: "Embedded AI enters",
    focus: "Embedded AI",
    startDate: DateTime(2026, 6, 9),
    endDate: DateTime(2026, 7, 6),
    goals: [
      "Start local AI experiments on device",
      "DSA intensity increases — more mediums",
      "HBand data + local model = first prototype",
      "Document everything with PhD lens",
    ],
  ),
  Phase(
    number: 4,
    title: "Deepen + polish",
    focus: "Polish",
    startDate: DateTime(2026, 7, 7),
    endDate: DateTime(2026, 8, 3),
    goals: [
      "DSA pushing into hards",
      "HBand + local AI more refined",
      "Portfolio starts taking shape",
      "Document architecture decisions",
    ],
  ),
  Phase(
    number: 5,
    title: "Job hunt ready",
    focus: "Job Hunt",
    startDate: DateTime(2026, 8, 4),
    endDate: DateTime(2026, 9, 14),
    goals: [
      "DSA sharp — hard problems",
      "Two languages solid",
      "Real project with AI component in portfolio",
      "Research interest becoming clearer",
    ],
  ),
];
```

---

## Streak Logic

```dart
int calculateStreak(List<DayLog> logs) {
  int streak = 0;
  DateTime day = DateTime.now();

  while (true) {
    final log = logs.firstWhere(
      (l) => isSameDay(l.date, day),
      orElse: () => DayLog(date: day),
    );

    if (!log.isFullyComplete) break;
    streak++;
    day = day.subtract(const Duration(days: 1));
  }

  return streak;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
```

---

## Notifications (add later)

Use `flutter_local_notifications` package.

Planned reminders:
- 9:00 AM — "DSA session. 45 min. Go."
- 8:00 PM — "Did you finish today's checklist?"
- Sunday 7:00 PM — "Time for your weekly journal."

Do NOT implement until core app is working. Add as a separate feature sprint.

---

## Packages to Use

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.1.1        # or riverpod if preferred
  go_router: ^13.0.0
  intl: ^0.19.0           # date formatting

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

---

## Build Order (recommended)

1. Set up Hive, define models, generate adapters
2. Build Home screen with hardcoded UI first
3. Wire up DayLog saving/reading
4. Build streak logic
5. Build Weekly view
6. Build Phase overview with progress bars
7. Build Journal screen
8. Connect all with Provider
9. Add navigation
10. Add settings
11. Notifications (later sprint)

---

## Why This App is Also Good Practice

- Hive teaches you local storage patterns you'll use in HBand app
- Provider/Riverpod teaches state management you'll need everywhere
- Date logic (streaks, phases) is practical DSA applied
- The whole app is yours — you'll break it, understand it, rebuild it
- By the time it's done, you'll be noticeably more confident in Dart/Flutter

---

*Start date: adjust Phase dates above to match your actual start.*
*Notifications: do not implement until core is stable.*
*Keep it simple first — a working ugly app beats a beautiful unfinished one.*
