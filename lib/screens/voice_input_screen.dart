import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoiceInputScreenState createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoading = false;
  String _recognizedText = '';
  String _response = '';

  // Color scheme
  final Color primaryBrown = const Color(0xFF8B5A2B);
  final Color lightBrown = const Color(0xFFD2B48C);
  final Color darkBrown = const Color(0xFF5D4037);

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isLoading = true;
      _response = 'Processing your complaint...';
    });
    _processComplaint(_recognizedText);
  }

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
                      "- Classification of the case.\n"
                      "- Provide Relevant BNS Sections(compulsary) with IPC sections (if the given complaint matches any of the following updated sections, use them):\n"
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
                      "Complaint:\n$complaint\n\n",
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBrown,
        elevation: 0,
        title: const Text(
          "Voice Legal Assistant",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightBrown.withOpacity(0.3), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Microphone and voice visualization
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isListening ? _stopListening : _startListening,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color:
                                _isListening
                                    ? Colors.red.withOpacity(0.2)
                                    : lightBrown.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            size: 50,
                            color: _isListening ? Colors.red : primaryBrown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _isListening ? "Tap to stop" : "Tap to speak",
                        style: TextStyle(
                          color: darkBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Recognized text display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _recognizedText.isEmpty
                      ? "Your speech will appear here..."
                      : _recognizedText,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _recognizedText.isEmpty ? Colors.grey : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Response section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child:
                      _isLoading
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: primaryBrown),
                                const SizedBox(height: 15),
                                Text(
                                  "Analyzing your case...",
                                  style: TextStyle(color: darkBrown),
                                ),
                              ],
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Legal Analysis",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: darkBrown,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _response.isEmpty
                                      ? "Your legal analysis will appear here after you speak."
                                      : _response.replaceAll('**', ''),
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color:
                                        _response.isEmpty
                                            ? Colors.grey
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
