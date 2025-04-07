import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/database_helper.dart';
import 'create_bill_screen.dart';
import 'add_menu_item_screen.dart';
import 'update_menu_item_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  _MenuListScreenState createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late final DatabaseHelper _dbHelper;
  late Future<List<MenuItem>> _menuItemsFuture;
  List<MenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _menuItemsFuture = Future.value([]);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print("Initializing database...");
      await _dbHelper.initialize();
      print("Database initialized, refreshing menu...");
      await _refreshMenu();
      print("Menu refreshed, current item count: ${_menuItems.length}");
    } catch (e) {
      print("Initialization error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to initialize: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _refreshMenu() async {
    try {
      final items = await _dbHelper.fetchMenuItems();
      setState(() {
        _menuItems = items;
        _menuItemsFuture = Future.value(items);
      });
    } catch (e) {
      print("Error loading menu: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading menu: ${e.toString()}")),
        );
      }
    }
  }

  void _navigateToBillScreen() {
    final selectedItems = _menuItems.where((item) => item.quantity > 0).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one item")),
      );
      return;
    }

    final totalAmount = selectedItems.fold(0.0, (sum, item) => sum + item.total);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBillScreen(
          items: selectedItems,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  void _updateItemQuantity(MenuItem item, int delta) {
    setState(() {
      item.quantity += delta;
      if (item.quantity < 0) item.quantity = 0;
      _dbHelper.updateMenuItem(item);
    });
  }

  Future<void> _deleteMenuItem(MenuItem item) async {
    try {
      await _dbHelper.deleteMenuItem(item);
      _refreshMenu();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item.name} deleted")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Menu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMenu,
            tooltip: 'Refresh Menu',
          ),
        ],
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading menu",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: _refreshMenu,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Menu Items Found",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMenuItemScreen(
                          onItemAdded: _refreshMenu,
                        ),
                      ),
                    ),
                    child: const Text("Add Your First Item"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Dismissible(
                key: Key(item.code),
                background: Container(color: Colors.red),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: Text("Delete ${item.name}?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _deleteMenuItem(item),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Code: ${item.code}"),
                        Text("Price: ${item.price.toStringAsFixed(0)} kip"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: () => _updateItemQuantity(item, -1),
                        ),
                        Text(
                          item.quantity.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green,
                          onPressed: () => _updateItemQuantity(item, 1),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateMenuItemScreen(
                          item: item,
                          onItemUpdated: _refreshMenu,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToBillScreen,
        icon: const Icon(Icons.receipt),
        label: const Text("Create Bill"),
        backgroundColor: Colors.green,
      ),
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: () async {
            await _dbHelper.clearDatabase();
            await _dbHelper.initialize();
            _refreshMenu();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Database completely reset")),
              );
            }
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text("Full Reset"),
        ),
      ],
    );
  }
}
