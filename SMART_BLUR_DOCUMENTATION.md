# Smart Blur System Documentation

## Overview

The Smart Blur System is an iOS-inspired, multi-layer blur implementation with motion-aware effects, shader-enhanced gloss, and cross-platform compatibility. It provides a drop-in replacement for the existing `GlassContainer` while adding premium visual effects.

## Architecture

### Components

1. **BlurTheme** (`lib/presentation/widgets/common/blur_theme.dart`)
   - Configuration class for blur values and animations
   - Provides utility methods for calculating motion-based blur parameters
   - Handles light/dark mode adaptations

2. **SmartBlurContainer** (`lib/presentation/widgets/common/smart_blur_container.dart`)
   - Main container widget with multi-layer blur effects
   - Supports motion-aware blur adjustments
   - Includes tap and hover interactions
   - Five-layer rendering stack:
     1. Backdrop filter (blur)
     2. Vibrancy tint
     3. Gradient overlay for depth
     4. Shader gloss overlay
     5. Content layer

3. **ShaderGlossOverlay** (`lib/presentation/widgets/common/shader_gloss_overlay.dart`)
   - Fragment shader-based gloss effect
   - Animated diagonal highlight
   - Fallback gradient for unsupported platforms
   - Motion-reactive shimmer

4. **Fragment Shader** (`assets/shaders/gloss_shader.frag`)
   - GLSL shader for premium gloss effects
   - Diagonal gradient with shimmer
   - Color shifting based on motion

5. **GlassContainer** (refactored)
   - Now uses `SmartBlurContainer` internally
   - Maintains backward compatibility
   - Shader gloss disabled by default for existing uses

## Usage

### Basic Usage

```dart
SmartBlurContainer(
  padding: const EdgeInsets.all(20),
  child: Text('Hello World'),
)
```

### With Motion Awareness

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 
          ? (currentScroll / maxScroll).clamp(0.0, 1.0) 
          : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: SmartBlurContainer(
        padding: const EdgeInsets.all(20),
        motionFactor: _scrollProgress,
        enableShaderGloss: true,
        child: YourContent(),
      ),
    );
  }
}
```

### With Glow Effect

```dart
SmartBlurContainer(
  padding: const EdgeInsets.all(20),
  showGlow: true,
  glowColor: Colors.purple,
  enableShaderGloss: true,
  child: YourContent(),
)
```

### With Tap Interaction

```dart
SmartBlurContainer(
  padding: const EdgeInsets.all(20),
  onTap: () => print('Tapped!'),
  child: YourContent(),
)
```

## Parameters

### SmartBlurContainer

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | Widget | required | Content to display |
| `width` | double? | null | Container width |
| `height` | double? | null | Container height |
| `padding` | EdgeInsetsGeometry? | null | Internal padding |
| `margin` | EdgeInsetsGeometry? | null | External margin |
| `borderRadius` | double | 20 | Corner radius |
| `borderColor` | Color? | null | Border color (auto if null) |
| `baseBlur` | double | 10 | Base blur sigma |
| `baseOpacity` | double | 0.1 | Base opacity |
| `onTap` | VoidCallback? | null | Tap callback |
| `enableBackdropFilter` | bool | true | Enable backdrop blur |
| `enableShaderGloss` | bool | true | Enable shader effects |
| `showGlow` | bool | false | Show glow effect |
| `glowColor` | Color? | null | Glow color |
| `motionFactor` | double | 0.0 | Motion intensity (0.0-1.0) |
| `enableVibrancy` | bool | true | Enable vibrancy layer |

## Performance

### Optimization Strategies

1. **Shader Guards**: Fragment shader gracefully falls back to gradient if not supported
2. **Motion Throttling**: Scroll updates are batched via `setState`
3. **Layer Optimization**: Each layer uses efficient rendering primitives
4. **Animation Controller**: Single controller for shader animations
5. **Conditional Rendering**: Layers only render when enabled

### Target Performance

- **60 FPS** on mid-range devices
- **Smooth scroll** at 120Hz on supported devices
- **<16ms** frame time for motion updates

### Platform Compatibility

| Platform | Backdrop Filter | Fragment Shader | Fallback |
|----------|----------------|-----------------|----------|
| iOS | ✅ Full | ✅ Full | N/A |
| Android | ✅ Full | ✅ Full* | Gradient |
| Web | ✅ Full | ⚠️ Limited** | Gradient |
| Desktop | ✅ Full | ✅ Full | N/A |

*Some Android devices may not support fragment shaders  
**Web shader support varies by browser

## Integration Examples

### Profile Screen
```dart
// Header with motion blur
SmartBlurContainer(
  padding: const EdgeInsets.all(24),
  motionFactor: _scrollProgress,
  enableShaderGloss: true,
  child: ProfileHeader(),
)

// Stats cards
SmartBlurContainer(
  padding: const EdgeInsets.all(20),
  motionFactor: _scrollProgress,
  enableShaderGloss: true,
  child: StatCard(),
)
```

### Achievements Screen
```dart
// Stone cards with glow
SmartBlurContainer(
  padding: const EdgeInsets.all(16),
  motionFactor: _scrollProgress,
  enableShaderGloss: true,
  showGlow: isUnlocked,
  glowColor: stone.glowColor,
  child: CrystalStone(),
)
```

### Backward Compatibility

All existing `GlassContainer` usages continue to work:

```dart
// Old code - still works!
GlassContainer(
  padding: const EdgeInsets.all(20),
  useBackdropFilter: true,
  child: Content(),
)
```

The refactored `GlassContainer` uses `SmartBlurContainer` internally with shader gloss disabled by default.

## Testing

Run the test suite:

```bash
flutter test test/smart_blur_test.dart
```

### Test Coverage

- ✅ BlurTheme calculations
- ✅ SmartBlurContainer rendering
- ✅ Motion factor handling
- ✅ Tap interactions
- ✅ Shader fallback
- ✅ Layout constraints
- ✅ Scroll integration

## Demo

A demo screen is available at:
```
lib/presentation/screens/demo/smart_blur_demo.dart
```

This demonstrates:
- Motion-aware blur
- Shader gloss effects
- Glow effects
- Interactive elements
- Progress tracking

## Troubleshooting

### Shader Not Working

If shaders don't load:
1. Check `pubspec.yaml` includes shader assets
2. Verify Flutter SDK version (3.10+)
3. Shader automatically falls back to gradient

### Performance Issues

If experiencing lag:
1. Reduce `motionFactor` update frequency
2. Disable `enableShaderGloss` on low-end devices
3. Use `enableBackdropFilter: false` for better performance

### Layout Overflow

If content overflows:
1. Ensure parent constraints are set
2. Use `Flexible` or `Expanded` for flexible children
3. Add appropriate padding/margins

## Future Enhancements

Potential improvements:
- [ ] Ambient light sensor integration
- [ ] Haptic feedback on interactions
- [ ] Advanced shader presets
- [ ] Performance profiling tools
- [ ] Adaptive quality based on device capabilities

## Credits

Inspired by iOS UIKit vibrancy and glassmorphism design principles.
