import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/today/cubit/today_cubit.dart';
import 'features/today/screens/today_screen.dart';
import 'features/weekly/cubit/weekly_cubit.dart';
import 'features/weekly/screens/weekly_screen.dart';
import 'features/phases/cubit/phases_cubit.dart';
import 'features/phases/screens/phases_screen.dart';
import 'features/journal/cubit/journal_cubit.dart';
import 'features/journal/screens/journal_screen.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/screens/settings_screen.dart';

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TodayCubit()),
        BlocProvider(create: (_) => WeeklyCubit()),
        BlocProvider(create: (_) => PhasesCubit()),
        BlocProvider(create: (_) => JournalCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: MaterialApp(
        title: 'Tracker',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const _Shell(),
          '/settings': (ctx) => BlocProvider.value(
                value: BlocProvider.of<SettingsCubit>(ctx, listen: false),
                child: const SettingsScreen(),
              ),
        },
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    WeeklyScreen(),
    PhasesScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          // Reload data when switching tabs
          if (i == 0) context.read<TodayCubit>().load();
          if (i == 1) context.read<WeeklyCubit>().load();
          if (i == 2) context.read<PhasesCubit>().load();
          if (i == 3) context.read<JournalCubit>().load();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_outlined), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week_outlined), label: 'Week'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), label: 'Phases'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Journal'),
        ],
      ),
    );
  }
}