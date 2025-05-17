//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';

///Clase de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> categoriesColorMap = {
    "warmOrange": Color.fromARGB(255, 235, 135, 70), // naranja cálido
    "sunnyYellow": Color.fromARGB(255, 240, 200, 70), // amarillo suave y alegre
    "royalPurple": Color.fromARGB(255, 125, 75, 180), // púrpura elegante
    "deepBlue": Color.fromARGB(255, 40, 100, 180), // azul profundo y sereno
    "coralPink": Color.fromARGB(255, 235, 110, 130), // rosa coral vivo
    "tealGreen": Color.fromARGB(255, 45, 140, 130), // verde azulado fresco
    "skyBlue": Color.fromARGB(255, 90, 180, 230), // azul cielo luminoso
    "plum": Color.fromARGB(255, 160, 70, 150), // ciruela vibrante
    "limeGreen": Color.fromARGB(255, 165, 210, 70), // lima natural
    "amber": Color.fromARGB(255, 220, 160, 40), // ámbar dorado
    "salmon": Color.fromARGB(255, 240, 130, 100), // salmón suave
    "lavender": Color.fromARGB(255, 180, 160, 210), // lavanda delicada
    "peach": Color.fromARGB(255, 255, 165, 110), // melocotón cálido
    "mint": Color.fromARGB(255, 120, 200, 140), // menta fresca
    "cerulean": Color.fromARGB(255, 70, 150, 220), // cerúleo brillante
  };
}
