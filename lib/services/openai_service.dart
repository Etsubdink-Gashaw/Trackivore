import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendToOpenAI(String userMessage) async {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    },
    body: jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": userMessage},
      ],
    }),
  );

  final data = jsonDecode(response.body);
  return data["choices"][0]["message"]["content"];
}
