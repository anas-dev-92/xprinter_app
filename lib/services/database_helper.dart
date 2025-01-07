import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/menu_item.dart';

class DatabaseHelper {
  // Initialize Hive
  Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path); // Initialize Hive with the app's document directory
    Hive.registerAdapter(MenuItemAdapter()); // Register the MenuItem adapter
  }

  // Opening the menu box and returning it
  Future<Box<MenuItem>> openMenuBox() async {
    return await Hive.openBox<MenuItem>('menu');
  }

  // Insert a menu item into the box
  Future<void> insertMenuItem(MenuItem menuItem) async {
    final menuBox = await openMenuBox();

    // Ensure the key is a valid string or integer
    final key = menuItem.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    await menuBox.put(key, menuItem.copyWith(id: key)); // Update the id if it was null
  }

  // Update a menu item in the box
  Future<void> updateMenuItem(MenuItem menuItem) async {
    final menuBox = await openMenuBox();

    if (menuItem.id == null) {
      throw Exception("Cannot update item without an id");
    }

    await menuBox.put(menuItem.id, menuItem);
  }

  // Delete a menu item from the box
  Future<void> deleteMenuItem(MenuItem menuItem) async {
    final menuBox = await openMenuBox();

    if (menuItem.id == null) {
      throw Exception("Cannot delete item without an id");
    }

    await menuBox.delete(menuItem.id);
  }

  // Fetch all menu items from the box
  Future<List<MenuItem>> fetchMenuItems() async {
    final menuBox = await openMenuBox();
    final menuItems = menuBox.values.toList();
    return menuItems;
  }
}