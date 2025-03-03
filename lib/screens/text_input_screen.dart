import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  _TextInputScreenState createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> _submitComplaint() async {
    setState(() {
      _isLoading = true;
      _response = 'Processing your complaint...';
    });

    const String apiKey = "AIzaSyBYzzROLQPaTw5v7FW7B9TT6R11M3s-hbI";
    const String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are a legal expert assistant. Analyze the following legal complaint and provide a structured response with:\n\n"
                      "- Identify if the victim is male or female (based on the text). no need to display this info\n"
                      "- Classification of the case.\n"
                      "- Relevant IPC Sections with new Bharatiya Nyaya Samhita (BNS) sections, if applicable, in bullet points.\n"
                      "- If the complaint involves harm against a female, include additional IPC/BNS sections related to crimes against women.\n"
                      "- Landmark Judgments.\n"
                      "- Simplified Explanation.\n\n"
                      "Format your response in clear, concise paragraphs without numbering or markdown.\n\n"
                      "Complaint:\n${_controller.text}",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content =
            data['candidates']?[0]['content']['parts'][0]['text'] ??
            "No response received";

        setState(() {
          _response = content;
        });
      } else {
        print('API Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        setState(() {
          _response = 'Error processing your complaint. Please try again.';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _response = 'Connection error. Please check your internet.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Legal Query")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your legal complaint',
                hintText: 'Describe your legal issue in detail...',
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitComplaint,
                  child: const Text('Submit Complaint'),
                ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _response.replaceAll(
                      '**',
                      '',
                    ), // Remove bold markers if any
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
