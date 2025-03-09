import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart'; // Add this import

// Main screen widget that handles the legal query functionality
class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  // Function to submit the complaint to the API
  Future<void> _submitComplaint() async {
    setState(() {
      _isLoading = true;
      _response = 'Processing your complaint...';
    });

    // API connection details
    const String apiKey = "AIzaSyBYzzROLQPaTw5v7FW7B9TT6R11M3s-hbI";
    const String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    try {
      // Making the API request
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
                      "- Provide Relevant BNS Sections(compulsary) with IPC sections (if the given complaint matches any of the following updated sections, use them(BNS->IPC as given)):\n"
                      "  - Section 4 (Punishments) -> Section 53\n"
                      "  - Section 11 (Solitary confinement) -> Section 73\n"
                      "  - Section 20 (Act of a child under seven years of age) -> Section 82\n"
                      "  - Section 22 (Act of a person of unsound mind) -> Section 84\n"
                      "  - Section 45 (Abetment of a thing) -> Section 107\n"
                      "  - Section 61 (Criminal conspiracy) -> Section 120A\n"
                      "  - Section 63 (Rape) -> Section 375\n"
                      "  - Section 80 (Dowry death) -> Section 304B\n"
                      "  - Section 85 (Husband or relative of husband subjecting a woman to cruelty) -> Section 498A\n"
                      "  - Section 100 (Culpable homicide) -> Section 299\n"
                      "  - Section 101 (Murder) -> Section 300\n"
                      "  - Section 106 (Causing death by negligence) -> Section 304A\n"
                      "  - Section 108 (Abetment of suicide) -> Section 306\n"
                      "  - Section 109 (Attempt to murder) -> Section 307\n"
                      "  - Section 129 (Criminal force) -> Section 350\n"
                      "  - Section 130 (Assault) -> Section 351\n"
                      "  - Section 137 (Kidnapping) -> Section 359\n"
                      "  - Section 138 (Abduction) -> Section 362\n"
                      "  - Section 189 (Unlawful assembly) -> Section 141\n"
                      "  - Section 194 (Affray) -> Section 159\n"
                      "  - Section 270 (Public nuisance) -> Section 268\n"
                      "  - Section 303 (Theft) -> Section 378\n"
                      "  - Section 308 (Extortion) -> Section 383\n"
                      "  - Section 309 (Robbery) -> Section 390\n"
                      "  - Section 310 (Dacoity) -> Section 391\n"
                      "  - Section 316 (Criminal breach of trust) -> Section 405\n"
                      "  - Section 318 (Cheating) -> Section 415\n"
                      "  - Section 329 (Criminal trespass) -> Section 441\n"
                      "  - Section 351 (Criminal intimidation) -> Section 503\n"
                      "  - Section 356 (Defamation) -> Section 499\n"
                      "- Landmark Judgments.\n"
                      "- Simplified Explanation.\n\n"
                      "Complaint:\n${_controller.text}\n\n"
                      "Important: Format your response using proper Markdown. Use ## for headings, * for bullet points, and **bold** for emphasis. Make sure to use proper Markdown formatting for bold text.",
                },
              ],
            },
          ],
        }),
      );

      // Processing the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content =
            data['candidates']?[0]['content']['parts'][0]['text'] ??
            "No response received";

        setState(() => _response = content);
      } else {
        setState(
          () =>
              _response = 'Error processing your complaint. Please try again.',
        );
      }
    } catch (e) {
      setState(
        () => _response = 'Connection error. Please check your internet.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define theme colors - brown shade
    final primaryColor = const Color(0xFF8B5A2B);
    final backgroundColor = Colors.brown[50];

    return Scaffold(
      // App bar with theme color
      appBar: AppBar(
        title: const Text("Legal Query"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0, // Modern flat design
        centerTitle: true,
      ),
      // Background color for the entire screen
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field with theme styling
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide(color: Colors.brown[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                labelText: 'Enter your legal complaint',
                labelStyle: TextStyle(color: Colors.brown[400]),
                hintText: 'Describe your legal issue in detail...',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button with modern styling
            _isLoading
                ? CircularProgressIndicator(color: primaryColor)
                : ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2, // Subtle shadow
                  ),
                  child: const Text(
                    'Submit Complaint',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            const SizedBox(height: 20),

            // Response Display with card design and Markdown support
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      _response.isEmpty
                          ? Center(
                            child: Text(
                              "Your legal analysis will appear here",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.brown[300],
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Markdown(
                              data: _response,
                              styleSheet: MarkdownStyleSheet(
                                h1: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[800],
                                ),
                                h2: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[700],
                                ),
                                h3: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[600],
                                ),
                                p: TextStyle(
                                  fontSize: 16,
                                  color: Colors.brown[800],
                                  height: 1.5,
                                ),
                                strong: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                listBullet: TextStyle(color: Colors.brown[600]),
                              ),
                            ),
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
