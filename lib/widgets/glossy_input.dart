import 'package:flutter/material.dart';
import 'dart:ui';

class GlossyInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onMic;
  const GlossyInput({super.key, required this.controller, required this.onSend, required this.onMic});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, offset: const Offset(0,6))],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFF7BE0E0)),
              onPressed: onMic,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ask anything — Orion searches the web',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: onSend,
              ),
            ),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF46D6AC), Color(0xFF1FB8FF)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))],
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
