import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> saveChatToDownloads(String content) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("\${dir.path}/orion_chat_\${DateTime.now().millisecondsSinceEpoch}.txt");
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      return "Save failed: \$e";
    }
  }
}
