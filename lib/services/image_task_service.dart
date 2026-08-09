import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ImageTaskService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<List<String>> extractTasksFromCamera() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile == null) {
      return [];
    }

    final File imageFile = File(pickedFile.path);
    final TextRecognizer textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(
        InputImage.fromFile(imageFile),
      );

      return recognizedText.text
          .trim()
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } finally {
      await textRecognizer.close();
    }
  }
}