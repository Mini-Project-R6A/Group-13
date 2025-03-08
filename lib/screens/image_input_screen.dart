import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({super.key});

  @override
  _ImageInputScreenState createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  File? _selectedImage; // Stores the selected image
  String _response = ''; // Stores API response
  bool _isLoading = false; // Shows loading indicator

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _response = ''; // Clear old response
      });
      _processImage(_selectedImage!); // Process the selected image
    }
  }

  // Function to send image to Gemini API for OCR
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _response = 'Processing the image...';
    });

    const String apiKey = "AIzaSyBYzzROLQPaTw5v7FW7B9TT6R11M3s-hbI";
    const String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-vision:generateContent?key=$apiKey";

    try {
      List<int> imageBytes =
          await imageFile.readAsBytes(); // Read file as bytes
      String base64Image = base64Encode(imageBytes); // Convert to Base64

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "mime_type": "image/jpeg",
                  "data": base64Image, // Send image in Base64 format
                },
                {
                  "text":
                      "You are a legal assistant. Extract the text from this image and analyze if it's a legal complaint. If so, provide relevant IPC/BNS sections, classification, and a simplified explanation.",
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
          _response = 'Error processing the image. Please try again.';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _response = 'Connection error. Please check your internet.';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // UI of the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Query")), // App title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button to pick an image
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Upload an Image"),
            ),
            const SizedBox(height: 20),

            // Display the selected image
            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
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
                        _response,
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
