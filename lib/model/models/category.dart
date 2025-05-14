import 'package:flutter/services.dart';

///Clase que representa una categoría
class Category {
  String categoryName; //es el id de la categoria en la propia BD
  String categoryIcon;
  bool categoryIsIncome;
  Color
      categoryColor; //se juntarán los colores en un solo campo. En la BD se almacenará por partes como rgb, guardando en variables cr, cg y cb
    
  Category(
      {required this.categoryName,
      required this.categoryIcon,
      required this.categoryIsIncome,
      required this.categoryColor});

  //a partir de un mapa creo una categoría
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      categoryName: map['id'],
      categoryIcon: map['icon'],
      categoryIsIncome: map['isincome'],
      categoryColor: Color.fromARGB(
        255, //siempre opaco
        map['cr'],
        map['cg'],
        map['cb'],
      ),
    );
  }
}
