// Path: lib/services/query_handler.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';

class QueryHandler {
  static const _apiBaseUrl = "https://orionbot-api.onrender.com";

  static Future<String> handleUserQuery(String query) async {
    query = query.trim();

    // ---------------- Greeting Logic ----------------
    const greetings = [
      "hi", "hello", "hey", "whatsup", "what's up",
      "good morning", "good afternoon", "good evening"
    ];
    if (greetings.any((g) => query.toLowerCase().contains(g))) {
      return "Hello! How can I help you today?";
    }

    // ---------------- Math Solver ----------------
    try {
      Parser p = Parser();
      Expression exp = p.parse(query);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return "Answer: $result";
    } catch (_) {
      // Not math → continue
    }

    // ---------------- Web Search via Render API ----------------
    String webResult = "";
    try {
      final url = Uri.parse("$_apiBaseUrl/search?q=${Uri.encodeComponent(query)}");
      final res = await http.get(url).timeout(const Duration(seconds: 60)); // ↑ increased timeout

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Adjust to match your current Flask API structure
        // Your API returns keys: google, bing, wikipedia
        final snippets = <String>[];
        if (data['google'] != null && data['google'].toString().isNotEmpty) {
          snippets.add("**Google Results:**\n${data['google']}");
        }
        if (data['bing'] != null && data['bing'].toString().isNotEmpty) {
          snippets.add("**Bing Results:**\n${data['bing']}");
        }

        webResult = snippets.join("\n\n");
      } else {
        // API returned error status
        return "Sorry, the search service returned an error (${res.statusCode}).";
      }
    } catch (e) {
      // handle timeouts or unreachable server
      return "Sorry, your internet is down or the search service is unreachable.\nError: $e";
    }

    // ---------------- Wikipedia Summary ----------------
    String wikiResult = "";
    try {
      final wikiUrl = Uri.parse(
        "https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(query)}",
      );
      final wikiRes = await http.get(wikiUrl).timeout(const Duration(seconds: 12));
      if (wikiRes.statusCode == 200) {
        final wikiData = jsonDecode(wikiRes.body);
        wikiResult = wikiData["extract"] ?? "";
      }
    } catch (_) {
      // ignore
    }

    // ---------------- Combine Results ----------------
    if (webResult.isEmpty && wikiResult.isEmpty) {
      return "Sorry, I couldn’t find anything useful.";
    }

    return [
      if (webResult.isNotEmpty) webResult,
        if (wikiResult.isNotEmpty) "**Wikipedia Summary:**\n$wikiResult"
    ].join("\n\n");
  }
}
