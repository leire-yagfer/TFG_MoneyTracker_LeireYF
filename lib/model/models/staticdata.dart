//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';

///Clase de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> incomeCategoriesColorMap = {
    "peachBlush": Color.fromARGB(255, 255, 221, 204), // melocotón suave cálido
    "coolLavender": Color.fromARGB(255, 214, 202, 255), // lavanda fría elegante
    "skyMistMedium": Color.fromARGB(255, 189, 224, 252) // celeste equilibrado
,
    "mintFog": Color.fromARGB(
        255, 210, 250, 235), // verde menta muy claro, no compite con el tuyo
    "butteryCream":
        Color.fromARGB(255, 255, 245, 204), // crema amarillento claro
    "paleCoral": Color.fromARGB(255, 255, 204, 204), // coral pálido amigable
    "teaRose": Color.fromARGB(255, 245, 215, 220), // rosa té elegante
    "softDenim":
        Color.fromARGB(255, 190, 210, 245), // azul jeans suave y tranquilo
  };

  static const Map<String, Color> expenseCategoriesColorMap = {
    "desertRose":
        Color.fromARGB(255, 240, 200, 195), // rosado terroso muy suave
    "softAmber":
        Color.fromARGB(255, 255, 235, 200), // ámbar claro apagado, muy usable
    "powderBlue": Color.fromARGB(255, 195, 215, 235), // azul empolvado claro
    "mossGray":
        Color.fromARGB(255, 185, 200, 185), // gris verdoso neutro, elegante
    "chalkLilac": Color.fromARGB(255, 225, 210, 235), // lila pastel desaturado
    "paleMint": Color.fromARGB(
        255, 215, 250, 230), // verde casi blanco, compatible con rojo
    "sunBleachedApricot":
        Color.fromARGB(255, 255, 220, 190), // albaricoque blanqueado, suave
    "silkenBlue": Color.fromARGB(
        255, 180, 205, 230), // azul grisáceo sedoso, muy elegante
  };
}
