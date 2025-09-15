import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

final stt.SpeechToText _speech = stt.SpeechToText();
final FlutterTts _tts = FlutterTts();

Future<String> startListening() async {
  bool available = await _speech.initialize();
  if (!available) return '';
  String result = '';
  await _speech.listen(onResult: (r) {
    if (r.finalResult) {
      result = r.recognizedWords;
    }
  }, listenFor: const Duration(seconds: 8));
  // Wait until listening stops (speech_to_text will stop automatically), then return last recognizedWords
  await Future.delayed(const Duration(seconds: 1));
  await _speech.stop();
  return result;
}

Future<void> speak(String text) async {
  await _tts.setSpeechRate(0.45);
  await _tts.speak(text);
}
