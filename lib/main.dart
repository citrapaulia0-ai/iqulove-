import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/collections_screens.dart';
import 'state/ourdays_state.dart';
import 'widgets/ourdays_widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OurDaysState()..load(),
      child: const OurDaysApp(),
    ),
  );
}

class OurDaysApp extends StatelessWidget {
  const OurDaysApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'OurDays',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brown,
        surface: AppColors.cream,
      ),
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Arial', color: AppColors.ink),
        bodyMedium: TextStyle(fontFamily: 'Arial', color: AppColors.ink),
        bodySmall: TextStyle(fontFamily: 'Arial', color: AppColors.muted),
        labelLarge: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.latte, width: 1.4),
        ),
      ),
    ),
    home: const _AppBootstrap(),
  );
}

class _AppBootstrap extends StatelessWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context) =>
      Consumer<OurDaysState>(builder: (context, state, _) {
        if (!state.isLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brown),
            ),
          );
        }
        if (state.loadError != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  state.loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Arial'),
                ),
              ),
            ),
          );
        }
        return const _MainNavigation();
      });
}

class _MainNavigation extends StatefulWidget {
  const _MainNavigation();

  @override
  State<_MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<_MainNavigation> {
  int _selectedIndex = 0;
  final _pages = const [
    HomeScreen(),
    CalendarScreen(),
    WishlistScreen(),
    MemoriesScreen(),
    NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _selectedIndex, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.softPink,
      labelBehavior: MediaQuery.sizeOf(context).width < 360
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border_rounded),
          selectedIcon: Icon(Icons.favorite_rounded),
          label: 'Wishlist',
        ),
        NavigationDestination(
          icon: Icon(Icons.photo_library_outlined),
          selectedIcon: Icon(Icons.photo_library_rounded),
          label: 'Memories',
        ),
        NavigationDestination(
          icon: Icon(Icons.sticky_note_2_outlined),
          selectedIcon: Icon(Icons.sticky_note_2_rounded),
          label: 'Notes',
        ),
      ],
    ),
  );
}
