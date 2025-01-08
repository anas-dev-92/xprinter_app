import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/database_helper.dart';
import 'create_bill_screen.dart';
import 'add_menu_item_screen.dart';
import 'update_menu_item_screen.dart'; // Import the new screen

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  _MenuListScreenState createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late Future<List<MenuItem>> _menuItems;

  @override
  void initState() {
    super.initState();
    _refreshMenu(); // Initialize the menu items list.
  }

  // Function to refresh the menu items and reset quantities
  void _refreshMenu() async {
    try {
      // Reset quantities to 0
      await DatabaseHelper().resetQuantities();

      // Fetch the updated menu items
      setState(() {
        _menuItems = DatabaseHelper().fetchMenuItems();
      });
    } catch (e) {
      print("Error refreshing menu: $e");
    }
  }

  void navigateToBillScreen() async {
    try {
      List<MenuItem> selectedItems = await DatabaseHelper().fetchMenuItems();
      selectedItems = selectedItems.where((item) => item.quantity > 0).toList();
      double totalAmount = selectedItems.fold(0.0, (sum, item) => sum + item.total);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateBillScreen(
            items: selectedItems,
            totalAmount: totalAmount,
          ),
        ),
      );
    } catch (e) {
      print("Error navigating to bill screen: $e");
    }
  }

  void navigateToAddMenuItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemScreen(
          onItemAdded: _refreshMenu, // Pass the callback to refresh the menu
        ),
      ),
    );
  }

  // Function to navigate to the update screen
  void _navigateToUpdateScreen(MenuItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateMenuItemScreen(item: item),
      ),
    );

    // Refresh the menu items if the item was updated
    if (result == true) {
      _refreshMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center( // Center the title in the AppBar
          child: Text("Restaurant Menu"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: _refreshMenu, // Refresh the menu items and reset quantities
          ),
        ],
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching menu items: ${snapshot.error}");
            return const Center(child: Text("Error loading menu items"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add the logo above the "Restaurant" text
                Image.asset(
                  'assets/images/logo.jpeg', // Replace with your logo path
                  width: 100, // Adjust the width as needed
                  height: 100, // Adjust the height as needed
                ),
                const SizedBox(height: 20), // Add some spacing
                const Text(
                  "Restaurant",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }

          final menuItems = snapshot.data!;
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text("Code: ${item.code} | Price: ${item.price.toStringAsFixed(0)} kip"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (item.quantity > 0) item.quantity--;
                            DatabaseHelper().updateMenuItem(item);
                          });
                        },
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            item.quantity++;
                            DatabaseHelper().updateMenuItem(item);
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _navigateToUpdateScreen(item); // Navigate to the update screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToBillScreen,
        child: const Icon(Icons.shopping_cart),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: navigateToAddMenuItemScreen,
          child: const Text("Add Menu Item"),
        ),
      ],
    );
  }
}