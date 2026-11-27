import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/pages/ask_hela/ask_hela_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/chat/structured_ai_reply_view.dart';

void main() {
  group('AiReplyParser & StructuredAiReplyView', () {
    const sampleDeepSeekReply = '''
Traveling from the misty hills of Kandy up to the vibrant northern peninsula of Jaffna is an incredible journey.

* **Distance:** Approximately **300 kilometers** (186 miles) via the central/northern route.
* **Travel Time:**
  * **By Train:** About **6 to 7 hours**. The *Yal Devi* express offers a smooth ride.
  * **By Car/Taxi:** Around **5 to 6 hours** along the A9 highway.

### Practical Advice
* **Train Schedule & Pricing:** Expect to pay around **LKR 1,000 to LKR 3,000** for reserved seating.

### Local Insight
Grab a window seat on the right side for changing mountain to palm landscapes.
''';

    test(
      'parses sections, paragraphs, key-point labels, and nested items cleanly',
      () {
        final blocks = AiReplyParser.parse(sampleDeepSeekReply);

        expect(blocks[0], isA<AiParagraphBlock>());
        expect(blocks[1], isA<AiKeyPointsGroupBlock>());

        final topPoints = (blocks[1] as AiKeyPointsGroupBlock).items;
        expect(topPoints.length, 4);
        expect(topPoints[0].label, 'Distance');
        expect(topPoints[0].body, contains('300 kilometers'));
        expect(topPoints[0].isNested, isFalse);

        expect(topPoints[1].label, 'Travel Time');
        expect(topPoints[1].body, isEmpty);

        expect(topPoints[2].label, 'By Train');
        expect(topPoints[2].isNested, isTrue);

        expect(blocks[2], isA<AiHeadingBlock>());
        expect((blocks[2] as AiHeadingBlock).title, 'Practical Advice');
        expect(blocks[3], isA<AiKeyPointsGroupBlock>());
        expect(blocks[4], isA<AiHeadingBlock>());
        expect((blocks[4] as AiHeadingBlock).title, 'Local Insight');
        expect(blocks[5], isA<AiParagraphBlock>());
      },
    );

    testWidgets(
      'renders Key Points without raw markdown asterisks or ### headings',
      (tester) async {
        await tester.pumpWidget(
          HelaAppStateProvider(
            state: HelaAppState(),
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: StructuredAiReplyView(text: sampleDeepSeekReply),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Distance'), findsOneWidget);
        expect(find.text('Travel Time'), findsOneWidget);
        expect(find.text('By Train'), findsOneWidget);
        expect(find.text('By Car/Taxi'), findsOneWidget);
        expect(find.text('Practical Advice'), findsOneWidget);
        expect(find.text('Train Schedule & Pricing'), findsOneWidget);
        expect(find.text('Local Insight'), findsOneWidget);

        // Ensure raw markdown syntax tokens do not render literally
        expect(find.textContaining('###'), findsNothing);
        expect(find.textContaining('**'), findsNothing);
      },
    );

    testWidgets(
      'AskHelaPage applies Plus Jakarta Sans font and copy action cleanly',
      (tester) async {
        await tester.pumpWidget(
          HelaAppStateProvider(
            state: HelaAppState(),
            child: const MaterialApp(home: AskHelaPage()),
          ),
        );
        await tester.pump();

        final titleText = tester.widget<Text>(find.text('Ask HELA'));
        expect(titleText.style?.fontFamily, 'Plus Jakarta Sans');

        final welcomeText = tester.widget<Text>(
          find.text("Hello! I'm your HELA travel guide."),
        );
        expect(welcomeText.style?.fontFamily, 'Plus Jakarta Sans');
        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      },
    );
  });
}
