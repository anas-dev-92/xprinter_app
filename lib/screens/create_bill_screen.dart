import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart'; // Add this package
import '/models/menu_item.dart';

class CreateBillScreen extends StatefulWidget {
  final List<MenuItem> items;
  final double totalAmount;

  CreateBillScreen({
    required this.items,
    required this.totalAmount,
  });

  @override
  _CreateBillScreenState createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance; // Printer instance

  // Method to format the bill as a string
  String formatBill() {
    String billContent = "------------------------\n";
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
    return billContent;
  }

  // Method to print the bill
  Future<void> printBill() async {
    try {
      // Check if the printer is connected
      bool? isConnected = await _printer.isConnected;
      if (isConnected != true) {
        // Connect to the printer (you can list available devices and let the user select one)
        List<BluetoothDevice> devices = await _printer.getBondedDevices();
        if (devices.isNotEmpty) {
          await _printer.connect(devices[0]); // Connect to the first paired device
        } else {
          throw Exception("No paired Bluetooth devices found.");
        }
      }

      // Print the logo (replace 'assets/images/logo.jpeg' with your logo path)
      await _printer.printImage("assets/images/logo.jpeg"); // Ensure the image is in your assets folder

      // Print the bill content
      String bill = formatBill();
      await _printer.write(bill);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Printing receipt...")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to print: $e")),
      );
    } finally {
      await _printer.disconnect(); // Disconnect after printing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Bill")),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: printBill, // Call the printBill method
            child: Text("Print Bill"),
          ),
        ],
      ),
    );
  }
}