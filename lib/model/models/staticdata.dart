//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';

///Clase de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> incomeCategoriesColorMap = {
    "softMint": Color.fromARGB(255, 180, 235, 200), //menta suave
    "earthyOlive": Color.fromARGB(255, 150, 170, 100), //oliva terrosa
    "mutedTeal": Color.fromARGB(255, 100, 180, 170), //verde azulado apagado
    "pastelYellow": Color.fromARGB(255, 245, 230, 140), //amarillo pastel
    "warmBeige": Color.fromARGB(255, 220, 200, 170), //beige cálido
    "foggyGray": Color.fromARGB(255, 190, 195, 190), //gris brumoso
    "calmSky": Color.fromARGB(255, 155, 200, 230), //celeste calmado
    "softLilac": Color.fromARGB(255, 200, 180, 230), //lila suave
  };

  static const Map<String, Color> expenseCategoriesColorMap = {
    "clayOrange": Color.fromARGB(255, 225, 145, 100), //naranja arcilla
    "blushPink": Color.fromARGB(255, 235, 170, 180), //rosado rubor
    "desertSand": Color.fromARGB(255, 230, 200, 180), //arena del desierto
    "warmTaupe": Color.fromARGB(255, 170, 140, 130), //topo cálido
    "mutedLavender": Color.fromARGB(255, 210, 180, 210), //lavanda apagada
    "moodyPlum": Color.fromARGB(255, 140, 100, 130), //ciruela apagada
    "mistyBlue": Color.fromARGB(255, 170, 190, 210), //azul neblinoso
    "softCopper": Color.fromARGB(255, 200, 130, 100), //cobre suave
  };
}
