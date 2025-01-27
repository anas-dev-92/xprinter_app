import 'package:hive/hive.dart';

part 'menu_item.g.dart'; // This will be generated by Hive

@HiveType(typeId: 0) // Unique typeId for MenuItem
class MenuItem {
  @HiveField(0)
  final String? id; // Make id optional

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  int quantity;

  MenuItem({
    this.id, // id is now optional
    required this.code,
    required this.name,
    required this.price,
    this.quantity = 0,
  });

  // Computed property for total price
  double get total => price * quantity;

  // Optional: Factory constructor for easier object creation
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'], // id is optional
      code: map['code'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'] ?? 0,
    );
  }

  // Optional: Convert MenuItem to a map (if needed for other purposes)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id is included in the map
      'code': code,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Add a copyWith method to easily create a copy of the object with updated fields
  MenuItem copyWith({
    String? id,
    String? code,
    String? name,
    double? price,
    int? quantity,
  }) {
    return MenuItem(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}