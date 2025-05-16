//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';

///Clase de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> categoriesColorMap = {
    "mutedOrange": Color.fromARGB(255, 242, 153, 74), //naranja moderado
    "softYellow": Color.fromARGB(255, 245, 210, 85), //amarillo suave
    "dustyPurple": Color.fromARGB(255, 155, 118, 188), //púrpura apagado
    "mediumBlue": Color.fromARGB(255, 100, 149, 237), //azul medio
    "warmPink": Color.fromARGB(255, 241, 143, 164), //rosa cálido
    "calmTurquoise": Color.fromARGB(255, 102, 205, 170), //turquesa medio
    "fadedCyan": Color.fromARGB(255, 102, 204, 204), //cian medio
    "mutedMagenta": Color.fromARGB(255, 216, 112, 214), //magenta moderado
    "softLime": Color.fromARGB(255, 218, 230, 101), //lime menos chillón
    "amberTone": Color.fromARGB(255, 240, 180, 83), //ámbar medio
    "rosyCoral": Color.fromARGB(255, 244, 154, 132), //coral rosado
    "duskyLavender": Color.fromARGB(255, 180, 167, 214), //lavanda grisácea
    "peachTone": Color.fromARGB(255, 255, 183, 131), //melocotón medio
    "mintTone": Color.fromARGB(255, 170, 220, 160), //menta medio
    "skyTone": Color.fromARGB(255, 135, 206, 250), //cielo moderado
  };
}
