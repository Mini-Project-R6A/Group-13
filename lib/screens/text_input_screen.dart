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
                      "- Classification of the case.\n"
                      "- Relevant IPC Sections with BNS sections (with the most latest updated BNS sections and verify it carefully before adding in the output) in bullet points.\n"
                      "- If the complaint involves harm against a female, include additional IPC/BNS sections.\n"
                      "- Landmark Judgments.\n"
                      "- Simplified Explanation.\n\n"
                      "Format your response with clear headings, bullet points, and structured paragraphs. Do not use markdown symbols like ** or ##.\n\n"
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
        setState(() {
          _response = 'Error processing your complaint. Please try again.';
        });
      }
    } catch (e) {
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
            // Input Field
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

            // Submit Button or Loading Indicator
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitComplaint,
                  child: const Text('Submit Complaint'),
                ),
            const SizedBox(height: 20),

            // Styled Response Display
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child:
                      _response.isEmpty
                          ? const Text(
                            "Your response will be displayed here.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _formatResponse(_response),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _formatResponse(String response) {
    List<String> lines = response.split("\n");
    List<Widget> formattedText = [];

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.contains(":")) {
        // Bold the headings
        List<String> parts = line.split(":");
        formattedText.add(
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "${parts[0]}:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " ${parts.sublist(1).join(":")}"),
              ],
            ),
          ),
        );
      } else if (line.startsWith("-")) {
        // Bullet points
        formattedText.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  line.substring(1).trim(),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        );
      } else {
        // Normal text
        formattedText.add(
          Text(line, style: const TextStyle(fontSize: 16, height: 1.5)),
        );
      }

      formattedText.add(const SizedBox(height: 5)); // Spacing
    }

    return formattedText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
