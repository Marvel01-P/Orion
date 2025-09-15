// Path: lib/screens/chat_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/query_handler.dart';   // ✅ use QueryHandler instead of meta_search
import '../services/file_service.dart';
import '../services/voice_service.dart';
import '../widgets/glossy_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final List<_Msg> _msgs = [];
  bool _loading = false;
  String _status = '';

  void _addUser(String t) {
    setState(() {
      _msgs.add(_Msg(t, true));
    });
  }

  void _addBot(String t) {
    setState(() {
      _msgs.add(_Msg(t, false));
    });
    // ❌ Removed speak(t) so bot won’t read messages aloud
  }

  Future<void> _ask(String q) async {
    if (q.trim().isEmpty) return;
    _addUser(q);
    _ctrl.clear();
    setState(() {
      _loading = true;
      _status = "Searching multiple sources...";
    });
    _addBot("Searching multiple sources...");

    // ✅ call QueryHandler
    final ans = await QueryHandler.handleUserQuery(q);

    setState(() {
      // remove the "Searching..." bot message
      for (int i = _msgs.length - 1; i >= 0; i--) {
        if (!_msgs[i].isUser && _msgs[i].text == "Searching multiple sources...") {
          _msgs.removeAt(i);
          break;
        }
      }
      _msgs.add(_Msg(ans, false));
      _loading = false;
      _status = '';
    });

    // ❌ Removed speak(ans) so answers are text only
  }

  Future<void> _saveAll() async {
    final content = _msgs.map((m) => "${m.isUser ? 'You' : 'Orion'}: ${m.text}").join("\n\n");
    final path = await FileService.saveChatToDownloads(content);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to: $path')));
  }

  Future<void> _listenAndAsk() async {
    final txt = await startListening();
    if (txt.isNotEmpty) _ask(txt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orion • MetaSearch', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(onPressed: _saveAll, icon: const Icon(Icons.save_alt)),
          IconButton(onPressed: _listenAndAsk, icon: const Icon(Icons.mic))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF031023), Color(0xFF081528)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length,
                itemBuilder: (_, i) {
                  final m = _msgs[i];
                  return Align(
                    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: m.isUser ? const Color(0xFFD0EEFF) : const Color(0xFF0F2236),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: m.isUser ? Colors.white10 : Colors.white10.withOpacity(0.02),
                            ),
                          ),
                          child: m.isUser
                          ? Text(m.text, style: const TextStyle(color: Color(0xFF001428)))
                          : SelectableText(m.text, style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SizedBox(
                  height: 24,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText(_status, textStyle: const TextStyle(color: Colors.white70))
                    ],
                    isRepeatingAnimation: true,
                  ),
                ),
              ),
              GlossyInput(
                controller: _ctrl,
                onSend: (text) => _ask(text),
                onMic: () => _listenAndAsk(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
}
