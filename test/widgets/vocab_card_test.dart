import 'package:flutter_test/flutter_test.dart';
import 'package:linguome/widgets/vocab_card.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Performance test: Interface Rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VocabCard(
            title: "test",
            description: "test",
            pos: "test",
          ),
        ),
      ),
    );

    final Stopwatch stopwatch = Stopwatch()..start();

    const Duration testDuration = Duration(seconds: 5);
    int frameCount = 0;

    while (stopwatch.elapsed < testDuration) {
      await tester.pump();
      frameCount++;
    }

    stopwatch.stop();

    final double averageFrameTime = stopwatch.elapsedMilliseconds / frameCount;

    expect(averageFrameTime, lessThan(16.67), reason: 'Interface rendering is slower than 60 FPS');
  });
}