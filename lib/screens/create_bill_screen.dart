import 'package:flutter/material.dart';
import '/models/menu_item.dart';
import '/services/printer_service.dart'; // Import the PrinterService
import '/services/database_helper.dart'; // Import the DatabaseHelper

class CreateBillScreen extends StatefulWidget {
  final List<MenuItem> items;
  final double totalAmount;

  const CreateBillScreen({super.key, 
    required this.items,
    required this.totalAmount,
  });

  @override
  _CreateBillScreenState createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final PrinterService _printerService = PrinterService('192.168.0.100', 9100); // Replace with your printer's IP and port
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Database helper instance

  // Method to format the bill as a string
  String formatBill() {
  String billContent = "------------------------\n";
  billContent += "       BABA Restaurant\n"; // Restaurant name
  billContent += "------------------------\n";
  billContent += "Receipt\n";
  billContent += "------------------------\n";
  double totalAmount = 0.0;

  for (var item in widget.items) {
    double itemTotal = item.price * item.quantity; // Calculate item total based on quantity
    totalAmount += itemTotal;
    // Format: "(code: 65) Biryani x1 75000 kip"
    billContent += "(code: ${item.code}) ${item.name} x${item.quantity} ${itemTotal.toStringAsFixed(0)} kip\n";
  }

  billContent += "------------------------\n";
  billContent += "Total: ${totalAmount.toStringAsFixed(0)} kip\n"; // Remove .00
  billContent += "Thank you for your purchase!\n";

  // Add phone number at the bottom
  billContent += "Contact us: +8562052449500\n";

  // Add more blank lines at the bottom
  billContent += "\n\n\n\n\n"; // Add 5 blank lines (adjust as needed)

  return billContent;
}

  // Method to print the bill
  Future<void> printBill() async {
  try {
    // Connect to the printer
    await _printerService.connect();

    // Print the bill content
    String bill = formatBill();
    await _printerService.printText(bill);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Printing receipt...")),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to print: $e")),
      );
    }
  } finally {
    // Disconnect from the printer
    try {
      await _printerService.disconnect();
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Bill")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("Quantity: ${item.quantity}"),
                  trailing: Text("${(item.price * item.quantity).toStringAsFixed(0)} kip"), // Remove .00
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: ${widget.totalAmount.toStringAsFixed(0)} kip", // Remove .00
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: printBill, // Call the printBill method
            child: const Text("Print Bill"),
          ),
        ],
      ),
    );
  }
}