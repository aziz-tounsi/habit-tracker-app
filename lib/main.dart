import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import 'core/theme/app_theme.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/add_habit/add_habit_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..init()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  /// Helper to check if app is still loading
  bool _isLoading(HabitProvider habitProvider, AuthProvider authProvider) {
    return habitProvider.isLoading || 
           authProvider.state == AuthState.initial || 
           authProvider.state == AuthState.loading;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, AuthProvider>(
      builder: (context, habitProvider, authProvider, child) {
        // Show loading screen while initializing
        if (_isLoading(habitProvider, authProvider)) {
          return const LoadingScreen();
        }

        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Show onboarding if not completed
        if (!habitProvider.hasCompletedOnboarding) {
          return const OnboardingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withAlpha(102),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'Habit Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeIn(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      // Center FAB for Add Habit - always visible
      floatingActionButton: FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withAlpha(128),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'addHabitFab',
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddHabitScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomAppBar(
            height: 70,
            notchMargin: 8,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left side items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(Icons.home_outlined, Icons.home, 'Home', 0),
                      _buildNavBarItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Stats', 1),
                    ],
                  ),
                ),
                // Center space for FAB
                const SizedBox(width: 72),
                // Right side items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(Icons.emoji_events_outlined, Icons.emoji_events, 'Awards', 2),
                      _buildNavBarItem(Icons.person_outline, Icons.person, 'Profile', 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: Icon(activeIcon, color: Colors.white, size: 24),
                  )
                : Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryPurple : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
