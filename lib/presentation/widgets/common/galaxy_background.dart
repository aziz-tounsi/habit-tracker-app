import 'package:flutter/material.dart';

class GalaxyBackground extends StatelessWidget {
  final Widget child;
  
  const GalaxyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D0D), // Dark gray
            Color(0xFF1A1A1A), // Slightly lighter dark gray
          ],
        ),
      ),
      child: child,
    );
  }
}
