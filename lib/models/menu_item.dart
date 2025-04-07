import 'package:hive/hive.dart';

part 'menu_item.g.dart';

@HiveType(typeId: 0)
class MenuItem {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  int quantity;

  MenuItem({
    this.id,
    required this.code,
    required this.name,
    required this.price,
    this.quantity = 0,
  });

  double get total => price * quantity;
}