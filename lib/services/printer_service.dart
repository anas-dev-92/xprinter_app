import 'dart:convert';
import 'dart:io';

class PrinterService {
  final String host;
  final int port;
  Socket? _socket; // Make _socket nullable
  bool _isConnected = false; // Connection state

  PrinterService(this.host, this.port);

  // Connect to the printer
  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5)); // Add timeout
      _isConnected = true; // Set connection state to true
      print('Connected to the printer at $host:$port');
    } catch (e) {
      _isConnected = false; // Set connection state to false on error
      _socket = null; // Reset _socket to null
      print('Failed to connect: $e');
      rethrow;
    }
  }

  // Send text to the printer with ESC/POS commands
  Future<void> printText(String text) async {
    if (!_isConnected || _socket == null) {
      print('Printer connection is not open, reconnecting...');
      await connect(); // Reconnect if not connected
    }

    try {
      // ESC/POS commands: initialize printer, line feed, and text alignment
      List<int> escPosCommands = [
        27, 64, // Initialize printer
        27, 97, 1, // Center align text (ESC a 1)
        27, 33, 0, // Reset text formatting (ESC ! 0)
        10, // Line feed
      ];

      // Add your text in byte form (ensure the encoding is correct)
      escPosCommands.addAll(utf8.encode(text));

      // Add paper feed command (feed 5 lines)
      escPosCommands.addAll([27, 100, 5]); // ESC d n (feed n lines)

      // Send the command to the printer
      _socket!.add(escPosCommands);
      await _socket!.flush();
      print('Sending to printer: $text');
    } catch (e) {
      _isConnected = false; // Set connection state to false on error
      _socket = null; // Reset _socket to null
      print('Failed to print: $e');
      rethrow;
    }
  }

  // Disconnect from the printer
  Future<void> disconnect() async {
    if (_socket != null) {
      try {
        await _socket!.flush(); // Flush any remaining data
        await Future.delayed(const Duration(seconds: 1)); // Add a delay
        await _socket!.close(); // Close the socket
        _isConnected = false; // Set connection state to false
        _socket = null; // Reset _socket to null
        print('Disconnected from the printer');
      } catch (e) {
        print('Failed to disconnect: $e');
        rethrow;
      }
    }
  }
}