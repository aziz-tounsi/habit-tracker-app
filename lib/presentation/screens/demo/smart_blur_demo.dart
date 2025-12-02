import 'package:flutter/material.dart';
import 'package:habit_tracker_app/presentation/widgets/common/smart_blur_container.dart';
import 'package:habit_tracker_app/presentation/widgets/common/galaxy_background.dart';
import 'package:habit_tracker_app/core/theme/app_theme.dart';

/// Demo screen showcasing SmartBlurContainer features
/// This can be used for testing and demonstration purposes
/// 
/// NOTE: This file is intended for development and testing only.
/// Consider excluding from production builds or removing after QA approval.
/// 
/// To exclude from release builds, you can use tree-shaking by ensuring
/// this file is never imported in production code paths.
class SmartBlurDemo extends StatefulWidget {
  const SmartBlurDemo({super.key});

  @override
  State<SmartBlurDemo> createState() => _SmartBlurDemoState();
}

class _SmartBlurDemoState extends State<SmartBlurDemo> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GalaxyBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              
              // Title
              const Text(
                'Smart Blur Demo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scroll to see motion-aware blur in action',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Motion progress indicator
              SmartBlurContainer(
                padding: const EdgeInsets.all(20),
                enableShaderGloss: true,
                motionFactor: _scrollProgress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motion Factor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _scrollProgress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryPurple,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_scrollProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Standard blur card
              _buildDemoCard(
                'Standard Blur',
                'Basic backdrop filter with vibrancy',
                enableShaderGloss: false,
              ),
              const SizedBox(height: 16),
              
              // Shader gloss card
              _buildDemoCard(
                'Shader Gloss',
                'Enhanced with fragment shader effects',
                enableShaderGloss: true,
              ),
              const SizedBox(height: 16),
              
              // Motion-aware card
              _buildDemoCard(
                'Motion-Aware',
                'Blur and opacity adjust with scroll',
                enableShaderGloss: true,
                useMotion: true,
              ),
              const SizedBox(height: 16),
              
              // Glow effect card
              SmartBlurContainer(
                padding: const EdgeInsets.all(24),
                enableShaderGloss: true,
                showGlow: true,
                glowColor: AppColors.primaryPurple,
                motionFactor: _scrollProgress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Glow Effect',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Premium surface with glowing border',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Interactive cards
              Row(
                children: [
                  Expanded(
                    child: SmartBlurContainer(
                      padding: const EdgeInsets.all(20),
                      enableShaderGloss: true,
                      motionFactor: _scrollProgress,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Card 1 tapped!')),
                        );
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Tap Me',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SmartBlurContainer(
                      padding: const EdgeInsets.all(20),
                      enableShaderGloss: true,
                      motionFactor: _scrollProgress,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Card 2 tapped!')),
                        );
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.science, color: Colors.white, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Interactive',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    String title,
    String description, {
    bool enableShaderGloss = false,
    bool useMotion = false,
  }) {
    return SmartBlurContainer(
      padding: const EdgeInsets.all(24),
      enableShaderGloss: enableShaderGloss,
      motionFactor: useMotion ? _scrollProgress : 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
