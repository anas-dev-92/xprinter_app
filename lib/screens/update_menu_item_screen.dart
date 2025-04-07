import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/database_helper.dart';

class UpdateMenuItemScreen extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onItemUpdated;

  const UpdateMenuItemScreen({
    super.key,
    required this.item,
    this.onItemUpdated,
  });

  @override
  _UpdateMenuItemScreenState createState() => _UpdateMenuItemScreenState();
}

class _UpdateMenuItemScreenState extends State<UpdateMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _codeController = TextEditingController(text: widget.item.code);
    _priceController = TextEditingController(text: widget.item.price.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedItem = MenuItem(
          id: widget.item.id,
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          quantity: widget.item.quantity,
        );

        await DatabaseHelper().updateMenuItem(updatedItem);

        widget.onItemUpdated?.call();

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Update failed: ${e.toString()}")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Menu Item"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.isEmpty ?? true ? "Please enter the item name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: "Item Code",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.isEmpty ?? true ? "Please enter the item code" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Item Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return "Please enter the item price";
                  if (double.tryParse(value!) == null) return "Please enter a valid price";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("UPDATE ITEM"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}