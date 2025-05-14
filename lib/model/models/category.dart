import 'package:flutter/services.dart';

///Clase que representa una categoría
class Category {
  String categoryName; //es el id de la categoria en la propia BD
  bool categoryIsIncome;
  Color
      categoryColor; //se juntarán los colores en un solo campo. En la BD se almacenará por partes como rgb, guardando en variables cr, cg y cb
    
  Category(
      {required this.categoryName,
      required this.categoryIsIncome,
      required this.categoryColor});

  //a partir de un mapa creo una categoría
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      categoryName: map['id'],
      categoryIsIncome: map['isincome'],
      categoryColor: Color.fromARGB(
        255, //siempre opaco
        map['cr'],
        map['cg'],
        map['cb'],
      ),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': categoryName,
      'isincome': categoryIsIncome,
      //cojo los datos del color que equivalen a cada valor
      'cr': categoryColor.red,
      'cg': categoryColor.green,
      'cb': categoryColor.blue,
    };
  }
}
