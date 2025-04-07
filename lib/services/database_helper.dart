import 'package:hive/hive.dart';
import '../models/menu_item.dart';

class DatabaseHelper {
  static const String _boxName = 'menu';

  Future<void> initialize() async {
    try {
      // First ensure the box is closed if it was open
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.close();
      }

      // Register adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MenuItemAdapter());
      }

      // Open the box with crash recovery
      await Hive.openBox<MenuItem>(_boxName, crashRecovery: false);

      // Force reload default items
      await _loadDefaultMenuIfEmpty(forceReload: true);
      print("Database initialized successfully");
    } catch (e) {
      print("Failed to initialize database: $e");
      rethrow;
    }
  }

  Future<void> _loadDefaultMenuIfEmpty({bool forceReload = false}) async {
    final box = await openMenuBox();

    if (forceReload || box.isEmpty) {
      print("Loading default menu items...");
      await box.clear(); // Clear existing items first
      await _insertDefaultMenuItems();
    }
    print("Database contains ${box.length} items");
  }

  Future<void> _insertDefaultMenuItems() async {
    try {
      final box = await openMenuBox();
      await box.clear();
    final defaultMenuItems = [
      // Food Items
      MenuItem(
        code: "01",
        name: "Samosa",
        price: 35000,
      ),
      MenuItem(
        code: "02",
        name: "Samosa Masala",
        price: 45000,
      ),
      MenuItem(
        code: "03",
        name: "Aloo Tikki",
        price: 35000,
      ),

      // Drinks
      MenuItem(
        code: "04",
        name: "Aloo Tikki Masala",
        price: 45000,
      ),
      MenuItem(
        code: "05",
        name: "Veg Pakora",
        price: 35000,
      ),
      MenuItem(
        code: "06",
        name: "Onion Pakora",
        price: 35000,
      ),

      // Desserts
      MenuItem(
        code: "07",
        name: "French Fries",
        price: 35000,
      ),
      MenuItem(
        code: "08",
        name: "French Fries Masala",
        price: 45000,
      ),
      MenuItem(
        code: "12",
        name: "Palak Panner",
        price: 35000,
      ),
      MenuItem(
        code: "13",
        name: "Aloo Gobi",
        price: 40000,
      ),
      MenuItem(
        code: "14",
        name: "Panner Butter Masala",
        price: 35000,
      ),
      MenuItem(
        code: "15",
        name: "Zerra Aloo",
        price: 35000,
      ),
      MenuItem(
        code: "16",
        name: "Aloo Curry",
        price: 35000,
      ),
      MenuItem(
        code: "17",
        name: "Channa Masala",
        price: 35000,
      ),
      MenuItem(
        code: "18",
        name: "Dal Fry",
        price: 35000,
      ),
      MenuItem(
        code: "19",
        name: "Dal Tarka",
        price: 35000,
      ),
      MenuItem(
        code: "20",
        name: "Dal Makhani",
        price: 35000,
      ),
      MenuItem(
        code: "21",
        name: "Aloo Palak",
        price: 35000,
      ),
      MenuItem(
        code: "22",
        name: "Mix Veg Curry",
        price: 35000,
      ),
      MenuItem(
        code: "23",
        name: "Mix Veg Dal",
        price: 40000,
      ),
      MenuItem(
        code: "24",
        name: "Channa Puri",
        price: 60000,
      ),
      MenuItem(
        code: "25",
        name: "Baingan Bharta",
        price: 35000,
      ),
      MenuItem(
        code: "26",
        name: "Dal Massor",
        price: 40000,
      ),
      MenuItem(
        code: "27",
        name: "Egg Masala",
        price: 35000,
      ),
      MenuItem(
        code: "28",
        name: "Egg Channa",
        price: 40000,
      ),
      MenuItem(
        code: "55",
        name: "Egg Dal",
        price: 35000,
      ),
      MenuItem(
        code: "56",
        name: "Egg Palak",
        price: 35000,
      ),
      MenuItem(
        code: "30",
        name: "Omlet",
        price: 30000,
      ),
      MenuItem(
        code: "31",
        name: "Egg Burji",
        price: 35000,
      ),
      MenuItem(
        code: "32",
        name: "Chicken Curry",
        price: 50000,
      ),
      MenuItem(
        code: "33",
        name: "Chicken Chola",
        price: 55000,
      ),
      MenuItem(
        code: "34",
        name: "Chicken Aloo",
        price: 55000,
      ),
      MenuItem(
        code: "35",
        name: "Chicken Butter Masala",
        price: 55000,
      ),
      MenuItem(
        code: "36",
        name: "Chicken Masala",
        price: 50000,
      ),
      MenuItem(
        code: "37",
        name: "Chicken Tikka Masala",
        price: 55000,
      ),
      MenuItem(
        code: "38",
        name: "Chicken Palak",
        price: 55000,
      ),
      MenuItem(
        code: "39",
        name: "Chicken Qorma",
        price: 55000,
      ),
      MenuItem(
        code: "40",
        name: "Mutton Curry",
        price: 85000,
      ),
      MenuItem(
        code: "41",
        name: "Mutton Masala",
        price: 85000,
      ),
      MenuItem(
        code: "42",
        name: "Mutton Rogan Josh",
        price: 85000,
      ),MenuItem(
        code: "43",
        name: "Mutton Kolhapuri",
        price: 85000,
      ),
      MenuItem(
        code: "44",
        name: "Mutton Aloo",
        price: 90000,
      ),
      MenuItem(
        code: "45",
        name: "Fish Masala",
        price: 50000,
      ),
      MenuItem(
        code: "46",
        name: "Mutton Palak",
        price: 90000,
      ),
      MenuItem(
        code: "47",
        name: "Mutton Qorma",
        price: 90000,
      ),
      MenuItem(
        code: "49",
        name: "Chicken Kharai 1KG",
        price: 240000,
      ),
      MenuItem(
        code: "50",
        name: "Chicken Kharai 1/2KG",
        price: 120000,
      ),
      MenuItem(
        code: "51",
        name: "Chicken Kharai Plate",
        price: 60000,
      ),
      MenuItem(
        code: "52",
        name: "Mutton Kharai 1KG",
        price: 360000,
      ),
      MenuItem(
        code: "53",
        name: "Mutton Kharai 1/2 KG",
        price: 180000,
      ),
      MenuItem(
        code: "54",
        name: "Mutton Kharai Plate",
        price: 90000,
      ),
      MenuItem(
        code: "58",
        name: "Chicken Tandori",
        price: 45000,
      ),
      MenuItem(
        code: "59",
        name: "Chicken Tikka",
        price: 55000,
      ),
      MenuItem(
        code: "63",
        name: "Plain Rice",
        price: 30000,
      ),
      MenuItem(
        code: "64",
        name: "Safforn Rice",
        price: 35000,
      ),
      MenuItem(
        code: "65",
        name: "Zerra Rice",
        price: 35000,
      ),
      MenuItem(
        code: "66",
        name: "Egg Fried Rice",
        price: 40000,
      ),
      MenuItem(
        code: "67",
        name: "Veg Biryani",
        price: 65000,
      ),
      MenuItem(
        code: "68",
        name: "Egg Biryani",
        price: 65000,
      ),
      MenuItem(
        code: "69",
        name: "Mutton Biryani",
        price: 120000,
      ),
      MenuItem(
        code: "70",
        name: "Chicken Biryani",
        price: 75000,
      ),
      MenuItem(
        code: "71",
        name: "Chicken Tikka Biryani",
        price: 80000,
      ),
      MenuItem(
        code: "72",
        name: "Chicken Tandori Biryani",
        price: 80000,
      ),
      MenuItem(
        code: "76",
        name: "yogurt",
        price: 25000,
      ),
      MenuItem(
        code: "77",
        name: "Mix Veg Rita",
        price: 30000,
      ),
      MenuItem(
        code: "78",
        name: "Fresh Salad",
        price: 25000,
      ),
      MenuItem(
        code: "82",
        name: "Plain Paratha",
        price: 22000,
      ),
      MenuItem(
        code: "83",
        name: "Chapati",
        price: 14000,
      ),
      MenuItem(
        code: "84",
        name: "Lacha Paratha",
        price: 25000,
      ),
      MenuItem(
        code: "85",
        name: "Tandori Roti",
        price: 15000,
      ),
      MenuItem(
        code: "86",
        name: "Plain Naan",
        price: 15000,
      ),
      MenuItem(
        code: "87",
        name: "Garlic Naan",
        price: 18000,
      ),
      MenuItem(
        code: "88",
        name: "Butter Naan",
        price: 18000,
      ),
      MenuItem(
        code: "89",
        name: "Onion Naan",
        price: 18000,
      ),
      MenuItem(
        code: "90",
        name: "Cheese Garlic Nann",
        price: 25000,
      ),
      MenuItem(
        code: "91",
        name: "Aloo Paratha",
        price: 30000,
      ),
      MenuItem(
        code: "92",
        name: "Cheese Nann",
        price: 25000,
      ),
      MenuItem(
        code: "96",
        name: "Plain Tea",
        price: 20000,
      ),
      MenuItem(
        code: "97",
        name: "Masala Tea",
        price: 25000,
      ),
      MenuItem(
        code: "98",
        name: "Salt Lassi",
        price: 25000,
      ),
      MenuItem(
        code: "99",
        name: "Sweet Lassi",
        price: 25000,
      ),
      MenuItem(
        code: "100",
        name: "Mango Lassi",
        price: 30000,
      ),
      MenuItem(
        code: "101",
        name: "Cold Drink",
        price: 15000,
      ),
      MenuItem(
        code: "102",
        name: "Water Big Bottel",
        price: 13000,
      ),
      MenuItem(
        code: "103",
        name: "Water 600ml",
        price: 7000,
      ),
      MenuItem(
        code: "104",
        name: "Water small",
        price: 3000,
      ),
      MenuItem(
        code: "105",
        name: "Beer Lao Big",
        price: 30000,
      ),
      MenuItem(
        code: "106",
        name: "Sting",
        price: 15000,
      ),
    ];
      await box.putAll({
        for (var item in defaultMenuItems)
          item.code: item // Using code as key for easier access
      });

      print("Inserted ${defaultMenuItems.length} default items");
    } catch (e) {
      print("Failed to insert default items: $e");
      rethrow;
    }
  }

  // ========================
  // CRUD OPERATIONS
  // ========================
  Future<Box<MenuItem>> openMenuBox() async {
    try {
      return await Hive.openBox<MenuItem>(_boxName);
    } catch (e) {
      print("Error opening box: $e");
      rethrow;
    }
  }

  Future<void> insertMenuItem(MenuItem menuItem) async {
    try {
      final box = await openMenuBox();
      await box.add(menuItem); // Using add() for auto-generated keys
    } catch (e) {
      print("Error inserting item: $e");
      rethrow;
    }
  }

  Future<void> updateMenuItem(MenuItem menuItem) async {
    try {
      final box = await openMenuBox();
      // Use code instead of id
      if (menuItem.code.isEmpty) {
        throw Exception("Cannot update item without a code");
      }
      await box.put(menuItem.code, menuItem);
    } catch (e) {
      print("Error updating item: $e");
      rethrow;
    }
  }

  Future<void> deleteMenuItem(MenuItem menuItem) async {
    try {
      final box = await openMenuBox();
      // Use code instead of id
      if (menuItem.code.isEmpty) {
        throw Exception("Cannot delete item without a code");
      }
      await box.delete(menuItem.code);
    } catch (e) {
      print("Error deleting item: $e");
      rethrow;
    }
  }

  Future<void> resetQuantities() async {
    try {
      final box = await openMenuBox();
      for (var item in box.values) {
        item.quantity = 0;
        await box.put(item.id, item); // Using id instead of key
      }
    } catch (e) {
      print("Error resetting quantities: $e");
      rethrow;
    }
  }

  Future<List<MenuItem>> fetchMenuItems() async {
    try {
      final box = await openMenuBox();
      final items = box.values.toList();

      if (items.isEmpty) {
        print("No items found, reloading default menu...");
        await _loadDefaultMenuIfEmpty(forceReload: true);
        return box.values.toList();
      }

      print("Fetched ${items.length} items from database");
      for (var item in items) {
        print("Item: ${item.name} (Code: ${item.code}, ID: ${item.id})");
      }
      return items;
    } catch (e) {
      print("Error fetching items: $e");
      rethrow;
    }
  }

  // ========================
  // UTILITY METHODS
  // ========================
  Future<void> clearDatabase() async {
    try {
      await Hive.deleteBoxFromDisk(_boxName);
    } catch (e) {
      print("Error clearing database: $e");
      rethrow;
    }
  }

  Future<void> reloadDefaultMenu() async {
    try {
      await clearDatabase();
      await initialize();
    } catch (e) {
      print("Error reloading default menu: $e");
      rethrow;
    }
  }
}
