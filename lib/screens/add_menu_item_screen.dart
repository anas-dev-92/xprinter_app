import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/database_helper.dart';

class AddMenuItemScreen extends StatefulWidget {
  final Function onItemAdded;

  AddMenuItemScreen({required this.onItemAdded});

  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _addMenuItem() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (name.isEmpty || code.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid input. Please check the fields")),
      );
      return;
    }

    final newItem = MenuItem(code: code, name: name, price: price);
    await DatabaseHelper().insertMenuItem(newItem);
    widget.onItemAdded(); // Refresh menu list
    Navigator.pop(context); // Close screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Menu Item")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: "Item Code"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Item Price"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMenuItem,
              child: Text("Add Item"),
            ),
          ],
        ),
      ),
    );
  }
}