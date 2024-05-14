import 'package:file_picker/file_picker.dart';
import 'dart:html' as webFile;

import 'package:flutter/foundation.dart';

Future<String?> loadString() async {
  if (kIsWeb) {
    FilePickerResult? result  =
    await FilePicker.platform.pickFiles(
      allowedExtensions: ['txt'],
      type: FileType.custom,
    );
    if(result != null) {
      PlatformFile file = result.files.first;
      if(file.bytes != null) {
        final blob = webFile.Blob([file.bytes]);
        final reader = webFile.FileReader();
        reader.readAsText(blob);
        await reader.onLoad.first;
        return reader.result as String;
      }
    }
  } else {
    return null;
    // User canceled the picker
  }
}