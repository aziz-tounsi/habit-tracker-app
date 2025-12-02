import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shader-based gloss overlay for premium surfaces
class ShaderGlossOverlay extends StatefulWidget {
  final double width;
  final double height;
  final double motionFactor;
  final bool enabled;

  const ShaderGlossOverlay({
    super.key,
    required this.width,
    required this.height,
    this.motionFactor = 0.0,
    this.enabled = true,
  });

  @override
  State<ShaderGlossOverlay> createState() => _ShaderGlossOverlayState();
}

class _ShaderGlossOverlayState extends State<ShaderGlossOverlay>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late AnimationController _animationController;
  bool _shaderLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/gloss_shader.frag',
      );
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      // Shader not supported or failed to load
      setState(() {
        _shaderLoadFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If shader is disabled, not loaded, or failed to load, show fallback
    if (!widget.enabled || _shader == null || _shaderLoadFailed) {
      return _buildFallbackGloss();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _ShaderGlossPainter(
            shader: _shader!,
            motionFactor: widget.motionFactor,
            time: _animationController.value * 6.28, // 0 to 2π
          ),
        );
      },
    );
  }

  /// Fallback gloss effect when shaders are not available
  Widget _buildFallbackGloss() {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15 * (1 + widget.motionFactor * 0.5)),
            Colors.white.withOpacity(0.0),
            Colors.cyan.withOpacity(0.05 * widget.motionFactor),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _ShaderGlossPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double motionFactor;
  final double time;

  _ShaderGlossPainter({
    required this.shader,
    required this.motionFactor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms
    shader.setFloat(0, size.width);  // uSize.x
    shader.setFloat(1, size.height); // uSize.y
    shader.setFloat(2, motionFactor); // uMotionFactor
    shader.setFloat(3, time);        // uTime

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ShaderGlossPainter oldDelegate) {
    return oldDelegate.motionFactor != motionFactor ||
        oldDelegate.time != time;
  }
}
