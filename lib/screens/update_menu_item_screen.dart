import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/database_helper.dart';

class UpdateMenuItemScreen extends StatefulWidget {
  final MenuItem item;

  UpdateMenuItemScreen({required this.item});

  @override
  _UpdateMenuItemScreenState createState() => _UpdateMenuItemScreenState();
}

class _UpdateMenuItemScreenState extends State<UpdateMenuItemScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current item values
    _nameController = TextEditingController(text: widget.item.name);
    _codeController = TextEditingController(text: widget.item.code);
    _priceController = TextEditingController(text: widget.item.price.toString());
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Function to update the item
  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      // Create an updated item
      MenuItem updatedItem = MenuItem(
        id: widget.item.id,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        quantity: widget.item.quantity, // Keep the same quantity
      );

      // Update the item in the database
      await DatabaseHelper().updateMenuItem(updatedItem);

      // Navigate back to the previous screen
      Navigator.pop(context, true); // Pass 'true' to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Menu Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Item Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the item name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Item Code"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the item code";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Item Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the item price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid price";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateItem,
                child: Text("Update Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}