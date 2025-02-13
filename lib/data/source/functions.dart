import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageHelper {
  static Future<XFile> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      throw Exception("No file selected");
    }
    return pickedFile;
  }

  static Future<File?> loadImage() async {
    try {
      final pickedFile = await pickImage(ImageSource.gallery);
      if (pickedFile == null) {
        return null;
      }
      final localFile = File(pickedFile.path);
      return localFile;
    } catch (e) {
    }
  }
}

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String message, {Color backgroundColor = const Color.fromARGB(255, 52, 52, 52)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, 
      ),
    );
  }
}

String? validatorEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return "Please write your title at first"; 
  }
  return null;
}

String calculateProgress(List<double> weekData) {
  double totalTasks = weekData.reduce((a, b) => a + b); 
  double maxTasks = 100.0; 
  double progress = (totalTasks / maxTasks) * 100;
  return progress.toStringAsFixed(1); 
}

List<Map<String, dynamic>> getAllOldTasks(List<Map<String, dynamic>> oldList, List<Map<String, dynamic>> list, String todaysDate) {
  oldList.clear();
  oldList.addAll(list.where((task) => task["date"] != todaysDate)); 
  return oldList; 
}


