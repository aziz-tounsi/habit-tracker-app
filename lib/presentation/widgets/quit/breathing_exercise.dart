import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  
  int _currentStep = 0; // 0: breathe in, 1: hold, 2: breathe out
  int _countdown = 4;
  int _cyclesCompleted = 0;
  final int _targetCycles = 4;
  bool _isActive = false;

  final List<String> _instructions = [
    'Breathe In',
    'Hold',
    'Breathe Out',
  ];

  final List<int> _durations = [4, 7, 8]; // 4-7-8 breathing technique

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _cyclesCompleted = 0;
      _currentStep = 0;
      _countdown = _durations[0];
    });
    _startStep();
  }

  void _startStep() {
    final duration = _durations[_currentStep];
    
    // Animate based on step
    if (_currentStep == 0) {
      // Breathe in - expand
      _controller.duration = Duration(seconds: duration);
      _controller.forward(from: 0);
    } else if (_currentStep == 1) {
      // Hold - stay at max
      _controller.duration = Duration(seconds: duration);
      _controller.animateTo(1.0);
    } else {
      // Breathe out - contract
      _controller.duration = Duration(seconds: duration);
      _controller.reverse(from: 1.0);
    }

    // Start countdown
    _countdown = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _nextStep();
        }
      });
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _startStep();
    } else {
      // Completed one cycle
      setState(() {
        _cyclesCompleted++;
        if (_cyclesCompleted < _targetCycles) {
          _currentStep = 0;
          _startStep();
        } else {
          _completeExercise();
        }
      });
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });
    
    // Show completion message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Great Job!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You completed the breathing exercise.\nFeeling better?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes, I\'m Better'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startExercise();
            },
            child: const Text('Do Another Round'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              Text(
                'Cycle ${_cyclesCompleted + 1} of $_targetCycles',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              // Animated breathing circle
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 300 * _scaleAnimation.value,
                        height: 300 * _scaleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentCyan.withAlpha(76),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Main circle
                      Container(
                        width: 250 * _scaleAnimation.value,
                        height: 250 * _scaleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.cyanPurpleGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withAlpha(102),
                              blurRadius: 30 * _scaleAnimation.value,
                              spreadRadius: 10 * _scaleAnimation.value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isActive)
                                Text(
                                  _countdown.toString(),
                                  style: const TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.air,
                                  size: 80,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 60),
              // Instruction text
              if (_isActive)
                Column(
                  children: [
                    Text(
                      _instructions[_currentStep],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentStep == 0
                          ? 'Through your nose'
                          : _currentStep == 1
                              ? 'Keep breathing held'
                              : 'Through your mouth',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Text(
                      '4-7-8 Breathing',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A simple technique to calm anxiety',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _startExercise,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        backgroundColor: AppColors.accentCyan,
                      ),
                      child: const Text(
                        'Start Exercise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
