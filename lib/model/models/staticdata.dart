//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';

class StaticData {
  static const Map<String, IconData> expenseIcon = {
    'house': Icons.house,
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'directions_car': Icons.directions_car,
    'self_improvement': Icons.self_improvement,
    'book': Icons.book
  };

  static const Map<String, IconData> incomeIcon = {
    'money': Icons.money,
    'card_giftcard': Icons.card_giftcard,
    'attach_money': Icons.attach_money,
    'monetization_on': Icons.monetization_on,
    'more_horiz': Icons.more_horiz,
  };

  static const Map<String, Color> colores = {
    'red': Color(0xFFFF0000),
    'green': Color(0xFF00FF00),
    'blue': Color(0xFF0000FF),
    'yellow': Color(0xFFFFFF00),
  };
}