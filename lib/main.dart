import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const OrionApp());
}

class OrionApp extends StatelessWidget {
  const OrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF03040A),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF071127), elevation: 0),
    );

    return MaterialApp(
      title: 'Orion Bot',
      theme: theme,
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
