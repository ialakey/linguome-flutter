import 'package:flutter_test/flutter_test.dart';
import 'package:linguome/entities/item.dart';
import 'package:linguome/screens/page_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Performance test: PageScreen Rendering', (WidgetTester tester) async {
    final List<Item> vocabList = List.generate(
      1000,
          (index) => Item(
        pageId: 'pageId_$index',
        word: 'word_$index',
        pos: 'noun',
        wordPosRank: index,
        definition: 'Definition of word_$index',
      ),
    );

    final String title = 'Test Title';

    await tester.pumpWidget(
      MaterialApp(
        home: PageScreen(title: title, vocabList: vocabList),
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