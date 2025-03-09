import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({super.key});

  @override
  _ImageInputScreenState createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  File? _selectedImage;
  String _response = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // 🔑 Replace with your actual Gemini API key
  final String apiKey = "AIzaSyBYzzROLQPaTw5v7FW7B9TT6R11M3s-hbI";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _response = ''; // Clear previous response
      });
      _extractTextFromImage(_selectedImage!);
    }
  }

  // 🟢 Step 1: Extract Text from Image (OCR)
  Future<void> _extractTextFromImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _response = "Extracting text...";
    });

    // New way to use text recognition
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final extractedText = recognizedText.text;

      if (extractedText.isEmpty) {
        setState(() {
          _response = "No text found in the image.";
        });
        return;
      }

      _sendToGemini(extractedText);
    } catch (e) {
      setState(() {
        _response = "Error extracting text: $e";
      });
    } finally {
      textRecognizer.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🟢 Step 2: Send Extracted Text to Gemini API
  Future<void> _sendToGemini(String extractedText) async {
    setState(() {
      _isLoading = true;
      _response = "Analyzing legal content...";
    });

    try {
      final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey",
      );

      final response = await http.post(
        uri,
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
                      "Complaint:\n$extractedText\n\n"
                      "Important: Format your response using proper Markdown. Use ## for headings, * for bullet points, and **bold** for emphasis. Make sure to use proper Markdown formatting for bold text.",
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
          _response =
              "Error processing text. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Processing failed: ${e.toString()}";
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
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF8B5A2B),
        title: const Text(
          "Image Legal Assistance",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ), // Removed the heading as requested
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Upload a Legal Document",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Select Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Results section
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analysis Results",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.brown[600]!,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Analyzing document...",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.brown[800],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Expanded(
                              child:
                                  _response.isEmpty
                                      ? Center(
                                        child: Text(
                                          "Upload a document to see analysis",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : SingleChildScrollView(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: MarkdownBody(
                                            data: _response,
                                            selectable: true,
                                            styleSheet: MarkdownStyleSheet(
                                              h1: GoogleFonts.montserrat(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown[800],
                                              ),
                                              h2: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown[700],
                                              ),
                                              h3: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.brown[600],
                                              ),
                                              p: GoogleFonts.roboto(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Colors.black87,
                                              ),
                                              strong: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown[900],
                                              ),
                                              em: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ),
                                              blockquote: GoogleFonts.roboto(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Colors.brown[800],
                                                backgroundColor:
                                                    Colors.brown[50],
                                              ),
                                              code: GoogleFonts.sourceCodePro(
                                                fontSize: 14,
                                                backgroundColor:
                                                    Colors.grey[200],
                                              ),
                                              codeblockDecoration:
                                                  BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                              listBullet: TextStyle(
                                                color: Colors.brown[800],
                                              ),
                                            ),
                                          ),
                                        ),
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
