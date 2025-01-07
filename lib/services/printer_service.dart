import 'dart:convert';
import 'dart:io';

class PrinterService {
  final String host;
  final int port;
  late Socket _socket;
  bool _isConnected = false; // Connection state

  PrinterService(this.host, this.port);

  // Connect to the printer
  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 5)); // Add timeout
      _isConnected = true; // Set connection state to true
      print('Connected to the printer at $host:$port');
    } catch (e) {
      _isConnected = false; // Set connection state to false on error
      print('Failed to connect: $e');
      rethrow;
    }
  }

  // Send text to the printer with ESC/POS commands
  Future<void> printText(String text) async {
    if (!_isConnected) {
      print('Printer connection is not open, reconnecting...');
      await connect(); // Reconnect if not connected
    }

    try {
      // ESC/POS commands: initialize printer, line feed, and text alignment
      List<int> escPosCommands = [
        27, 97, 1, // Center align text (ESC a 1)
        27, 33, 0, // Reset text formatting (ESC ! 0)
        10, // Line feed
      ];

      // Add your text in byte form (ensure the encoding is correct)
      escPosCommands.addAll(utf8.encode(text));

      // Send the command to the printer
      _socket.add(escPosCommands);
      await _socket.flush();
      print('Sending to printer: $text');
    } catch (e) {
      _isConnected = false; // Set connection state to false on error
      print('Failed to print: $e');
      rethrow;
    }
  }

  // Print an image (ESC/POS command for image printing)
  Future<void> printImage(String imagePath) async {
    if (!_isConnected) {
      print('Printer connection is not open, reconnecting...');
      await connect(); // Reconnect if not connected
    }

    try {
      // Load the image file
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();

      // ESC/POS command to print an image
      // Note: You need to implement the correct ESC/POS command for your printer model
      // This is a placeholder for the image printing logic
      List<int> escPosImageCommands = [
        29, 118, 48, 0, // ESC/POS command for image printing (example)
        ...imageBytes, // Add the image bytes
      ];

      // Send the command to the printer
      _socket.add(escPosImageCommands);
      await _socket.flush();
      print('Sending image to printer: $imagePath');
    } catch (e) {
      _isConnected = false; // Set connection state to false on error
      print('Failed to print image: $e');
      rethrow;
    }
  }

  // Disconnect from the printer
  Future<void> disconnect() async {
    try {
      await _socket.flush(); // Flush any remaining data
      await _socket.close(); // Close the socket
      _isConnected = false; // Set connection state to false
      print('Disconnected from the printer');
    } catch (e) {
      print('Failed to disconnect: $e');
      rethrow;
    }
  }
}