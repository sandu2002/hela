import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  test('Gemini API test', () async {
    HttpOverrides.global = null;
    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: 'AQ.Ab8RN6LcBcIS8jiH2GzAdjwITZJtC1IXTrvgdQnvky5gXnv4CA',
    );
    final response = await model.generateContent([
      Content.text('List 2 top places in Sri Lanka. Reply in JSON: [{"name": "...", "region": "..."}]'),
    ]);
    expect(response.text, isNotNull);
    expect(response.text!.isNotEmpty, isTrue);
  });
}
