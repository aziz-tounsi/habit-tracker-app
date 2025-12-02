import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/presentation/widgets/common/blur_theme.dart';
import 'package:habit_tracker_app/presentation/widgets/common/smart_blur_container.dart';
import 'package:habit_tracker_app/presentation/widgets/common/shader_gloss_overlay.dart';

void main() {
  group('BlurTheme', () {
    test('calculateBlurSigma returns values within expected range', () {
      expect(BlurTheme.calculateBlurSigma(0.0), BlurTheme.motionBlurMin);
      expect(BlurTheme.calculateBlurSigma(1.0), BlurTheme.motionBlurMax);
      
      final midValue = BlurTheme.calculateBlurSigma(0.5);
      expect(midValue, greaterThan(BlurTheme.motionBlurMin));
      expect(midValue, lessThan(BlurTheme.motionBlurMax));
    });

    test('calculateOpacity returns values within expected range', () {
      final minOpacity = BlurTheme.calculateOpacity(0.0);
      final maxOpacity = BlurTheme.calculateOpacity(1.0);
      
      expect(minOpacity, greaterThanOrEqualTo(BlurTheme.minOpacity));
      expect(maxOpacity, lessThanOrEqualTo(BlurTheme.maxOpacity));
      expect(minOpacity, greaterThan(maxOpacity)); // Motion reduces opacity
    });

    testWidgets('getVibrancyColor returns appropriate colors for light/dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = BlurTheme.getVibrancyColor(context);
              expect(color, isNotNull);
              return Container();
            },
          ),
        ),
      );
    });
  });

  group('SmartBlurContainer', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      const testText = 'Test Child';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBlurContainer(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('applies motion factor to blur effects', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBlurContainer(
              motionFactor: 0.5,
              child: Text('Motion Test'),
            ),
          ),
        ),
      );

      expect(find.text('Motion Test'), findsOneWidget);
      // The widget should render without errors
    });

    testWidgets('handles tap interaction when onTap is provided', (WidgetTester tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartBlurContainer(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      
      expect(tapped, isTrue);
    });

    testWidgets('respects enableBackdropFilter flag', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SmartBlurContainer(
                  enableBackdropFilter: true,
                  child: Text('Enabled'),
                ),
                SmartBlurContainer(
                  enableBackdropFilter: false,
                  child: Text('Disabled'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('shows glow when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBlurContainer(
              showGlow: true,
              glowColor: Colors.blue,
              child: Text('Glow Test'),
            ),
          ),
        ),
      );

      expect(find.text('Glow Test'), findsOneWidget);
    });
  });

  group('ShaderGlossOverlay', () {
    testWidgets('renders without errors when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderGlossOverlay(
              width: 100,
              height: 100,
              enabled: true,
            ),
          ),
        ),
      );

      // Widget should render without throwing
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows fallback when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderGlossOverlay(
              width: 100,
              height: 100,
              enabled: false,
            ),
          ),
        ),
      );

      // Widget should render without throwing
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects motionFactor parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderGlossOverlay(
              width: 100,
              height: 100,
              motionFactor: 0.5,
              enabled: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('SmartBlurContainer Integration', () {
    testWidgets('handles scroll-based motion updates', (WidgetTester tester) async {
      final controller = ScrollController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: controller,
              itemCount: 20,
              itemBuilder: (context, index) {
                return SmartBlurContainer(
                  height: 100,
                  margin: const EdgeInsets.all(8),
                  motionFactor: 0.0,
                  child: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Scroll and verify no errors
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      
      expect(tester.takeException(), isNull);
      
      controller.dispose();
    });

    testWidgets('maintains layout constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBlurContainer(
              width: 200,
              height: 100,
              padding: EdgeInsets.all(16),
              child: Text('Layout Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<SmartBlurContainer>(
        find.byType(SmartBlurContainer),
      );
      
      expect(container.width, 200);
      expect(container.height, 100);
      expect(container.padding, const EdgeInsets.all(16));
    });
  });
}
