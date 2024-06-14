import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:terpiez/utils/const.dart';

Future<String> saveImageToLocalFile(
    String imageBase64String, String type, String id) async {
  try {
    // replace the quotes
    imageBase64String = imageBase64String.replaceAll('"', '');

    // Decode  base64 string to bytes
    Uint8List bytes = base64Decode(imageBase64String);

    // save image to local storage
    Directory directory = await getApplicationDocumentsDirectory();

    // create a unique file name
    String filePath = '${directory.path}/terpiez_${type}_$id.png';

    // Write image bytes to file
    if (!(await File(filePath).exists())) {
      File file = File(filePath);
      await file.writeAsBytes(bytes);
    }

    return filePath;
  } catch (e) {
    logger.d(e);
    return '';
  }
}
