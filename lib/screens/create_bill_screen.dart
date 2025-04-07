import 'package:flutter/material.dart';
import '/models/menu_item.dart';
import '/services/printer_service.dart';
import '/services/database_helper.dart';

class CreateBillScreen extends StatefulWidget {
  final List<MenuItem> items;
  final double totalAmount;

  const CreateBillScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  _CreateBillScreenState createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final PrinterService _printerService = PrinterService('192.168.100.78', 9100);
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  String formatBill() {
    String billContent = "------------------------\n";
    billContent += "    BABA Biryani House\n";
    billContent += "------------------------\n";
    billContent += "Receipt\n";
    billContent += "------------------------\n";

    // Print items normally
    for (var item in widget.items) {
      double itemTotal = item.price * item.quantity;
      billContent += "(code: ${item.code}) ${item.name} x${item.quantity} ${itemTotal.toStringAsFixed(0)} kip\n";
    }

    billContent += "------------------------\n";

    // Apply bold and double-height for the total
    billContent += "\x1B\x21\x30"; // ESC ! 0x30 (Bold + Double Height)
    billContent += "Total: ${widget.totalAmount.toStringAsFixed(0)} kip\n";
    billContent += "\x1B\x21\x00"; // ESC ! 0x00 (Reset to normal text)

    billContent += "------------------------\n";
    billContent += "Thank you for your purchase!\n";

    // Add minimal paper feed before cutting
    billContent += "\x1B\x64\x02"; // Feed 2 lines (ESC d 2)

    // Send cutter command (if supported)
    billContent += "\x1D\x56\x41\x03"; // Full cut (ESC/POS GS V 41)

    return billContent;
  }

  Future<void> printBill() async {
  try {
    await _printerService.connect();

    // Print the bill text
    String bill = formatBill();
    await _printerService.printText(bill);

    // Comment out the image printing for now
    // await _printerService.printImage('assets/images/qrcode.jpeg');

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
                  trailing: Text("${(item.price * item.quantity).toStringAsFixed(0)} kip"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: ${widget.totalAmount.toStringAsFixed(0)} kip",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/qrcode.jpeg',
              width: 200,
              height: 200,
            ),
          ),
          ElevatedButton(
            onPressed: printBill,
            child: const Text("Print Bill"),
          ),
        ],
      ),
    );
  }
}
