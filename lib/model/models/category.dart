import 'package:flutter/services.dart';

///Clase que representa una categoría
class Categoria {
  final String nombre;
  final String icono;
  final bool esingreso;
  final Color
      colorCategoria; //se juntarán los colores en un solo campo. En la BD se almacenará por partes como rgb, guardando en variables cr, cg y cb

  Categoria(
      {required this.nombre,
      required this.icono,
      required this.esingreso,
      required this.colorCategoria});

  //a partir de un mapa creo una categoría
  static Categoria fromMap(Map<String, dynamic> map) {
    return Categoria(
      nombre: map['id'],
      icono: map['icon'],
      esingreso: map['isincome'],
      colorCategoria: Color.fromARGB(
        255, //siempre opaco
        map['cr'],
        map['cg'],
        map['cb'],
      ),
    );
  }
}
