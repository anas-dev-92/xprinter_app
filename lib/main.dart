import 'package:flutter/material.dart';
import 'screens/menu_list_screen.dart'; // Import MenuListScreen
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  try {
    print("Initializing Hive...");
    await DatabaseHelper().initialize(); // Initialize Hive
    print("Hive initialized successfully.");

    runApp(MyApp());
  } catch (e) {
    print("Error during initialization: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MenuListScreen(), // Use MenuListScreen from its own file
    );
  }
}