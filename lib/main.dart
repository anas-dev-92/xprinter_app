import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/menu_item.dart';
import 'screens/menu_list_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive with path
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(MenuItemAdapter());

    // Initialize database
    print("Initializing database...");
    await DatabaseHelper().initialize();

    runApp(const MyApp());
  } catch (e) {
    print("Failed to initialize app: $e");
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text("Failed to initialize app"),
                Text(e.toString()),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MenuListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}