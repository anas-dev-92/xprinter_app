import 'menu_item.dart';

class Bill {
  List<MenuItem> items;
  double totalAmount;

  Bill({
    required this.items,
    required this.totalAmount,
  });
}
