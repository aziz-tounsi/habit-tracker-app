import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Build Better Habits',
      description:
          'Track your daily habits and build a routine that sticks. Small steps lead to big changes.',
      emoji: '🎯',
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPage(
      title: 'Stay Motivated',
      description:
          'Earn XP, unlock achievements, and maintain streaks. Gamification makes habit building fun!',
      emoji: '🔥',
      gradient: AppColors.cyanPurpleGradient,
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description:
          'Visualize your journey with beautiful charts and statistics. See how far you\'ve come.',
      emoji: '📊',
      gradient: AppColors.greenCyanGradient,
    ),
    OnboardingPage(
      title: 'Ready to Start?',
      description:
          'Let\'s begin your journey to a better you. Create your first habit and start building!',
      emoji: '🚀',
      gradient: AppColors.pinkOrangeGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    context.read<HabitProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: _currentPage == index
                          ? _pages[index].gradient
                          : null,
                      color: _currentPage == index
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(51),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                text: _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                gradient: _pages[_currentPage].gradient,
                onPressed: _nextPage,
                width: double.infinity,
                icon: _currentPage < _pages.length - 1
                    ? Icons.arrow_forward
                    : Icons.rocket_launch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with gradient background
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: page.gradient,
                boxShadow: [
                  BoxShadow(
                    color: page.gradient.colors.first.withAlpha(102),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          // Title
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: ShaderMask(
              shaderCallback: (bounds) => page.gradient.createShader(bounds),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String emoji;
  final LinearGradient gradient;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
    required this.gradient,
  });
}
