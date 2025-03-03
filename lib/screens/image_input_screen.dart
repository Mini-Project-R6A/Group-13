import 'package:flutter/material.dart';

class ImageInputScreen extends StatelessWidget {
  const ImageInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Query")),
      body: const Center(child: Text("Upload an image for OCR processing")),
    );
  }
}
