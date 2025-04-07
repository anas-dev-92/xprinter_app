import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img; // Ensure you have 'image' package added in pubspec.yaml

class PrinterService {
  final String host;
  final int port;
  Socket? _socket;
  bool _isConnected = false;

  PrinterService(this.host, this.port);

  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _isConnected = true;
      print('Connected to the printer at $host:$port');
    } catch (e) {
      _isConnected = false;
      _socket = null;
      print('Failed to connect: $e');
      rethrow;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected || _socket == null) {
      print('Printer connection is not open, reconnecting...');
      await connect();
    }

    try {
      List<int> escPosCommands = [
        27, 64,
        27, 97, 1, 
        27, 33, 0, 
        10, 
      ];

      escPosCommands.addAll(utf8.encode(text));
      escPosCommands.addAll([27, 100, 5]);

      _socket!.add(escPosCommands);
      await _socket!.flush();
      print('Sending to printer: $text');
    } catch (e) {
      _isConnected = false;
      _socket = null;
      print('Failed to print: $e');
      rethrow;
    }
  }

Future<void> printImage(String imagePath) async {
  try {
    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List();

    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image != null) {
      // Resize the image to fit the printer's width (e.g., 384 pixels)
      img.Image resizedImage = img.copyResize(image, width: 384);

      // Convert the image to grayscale
      img.Image grayscaleImage = img.grayscale(resizedImage);

      // Convert the image to a bitmap (1-bit depth)
      List<int> bitmap = _imageToBitmap(grayscaleImage);

      // Send ESC/POS commands to print the bitmap
      _socket!.add([27, 51, 24]); // Set line spacing to 24 dots
      _socket!.add([27, 42, 33, 384 ~/ 8, 0]); // ESC/POS command for bitmap
      _socket!.add(bitmap);
      _socket!.add([10]); // Line feed

      await _socket!.flush();
      print('Sending image to printer');
    }
  } catch (e) {
    print("Error printing image: $e");
  }
}

List<int> _imageToBitmap(img.Image image) {
  List<int> bitmap = [];
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x += 8) {
      int byte = 0;
      for (int i = 0; i < 8; i++) {
        if (x + i < image.width) {
          int pixel = image.getPixel(x + i, y);
          int luminance = img.getLuminance(pixel);
          if (luminance < 128) {
            byte |= 1 << (7 - i); // Set the bit for black pixels
          }
        }
      }
      bitmap.add(byte);
    }
  }
  return bitmap;
}

  Future<void> disconnect() async {
    if (_socket != null) {
      try {
        await _socket!.flush();
        await Future.delayed(const Duration(seconds: 1));
        await _socket!.close();
        _isConnected = false;
        _socket = null;
        print('Disconnected from the printer');
      } catch (e) {
        print('Failed to disconnect: $e');
        rethrow;
      }
    }
  }
}
