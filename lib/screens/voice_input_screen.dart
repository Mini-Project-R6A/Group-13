import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  _VoiceInputScreenState createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final stt.SpeechToText _speech =
      stt.SpeechToText(); // Initialize speech recognition
  bool _isListening = false; // Tracks if listening is active
  bool _isLoading = false; // Shows loading indicator
  String _recognizedText = ''; // Stores the speech text
  String _response = ''; // Stores API response

  // Starts listening and updates _recognizedText
  void _startListening() async {
    bool available =
        await _speech.initialize(); // Check if speech recognition is available
    if (available) {
      setState(() {
        _isListening = true; // Indicate that listening started
        _recognizedText = ''; // Clear old text
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords; // Store recognized words
          });
        },
      );
    } else {
      print("Speech recognition not available"); // Debugging
    }
  }

  // Stops listening and processes the complaint
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false; // Update UI to show listening stopped
      _isLoading = true; // Show loading
      _response = 'Processing your complaint...'; // Display message
    });

    _processComplaint(_recognizedText); // Call API function
  }

  // Sends complaint text to Gemini API
  Future<void> _processComplaint(String complaint) async {
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
                      "Complaint:\n$complaint",
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
          _response = content; // Store API response
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
        _isLoading = false; // Hide loading
      });
    }
  }

  // UI of the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Query")), // App title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show recognized text or prompt user to speak
            Text(
              _recognizedText.isEmpty
                  ? "Speak to get legal information"
                  : _recognizedText,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Button to start/stop speech recognition
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? "Stop Listening" : "Start Listening"),
            ),
            const SizedBox(height: 20),

            // Show loading indicator while processing
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
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
}
