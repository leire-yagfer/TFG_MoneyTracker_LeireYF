//Clase estática para almacenar un mapa de iconos y colores

import 'package:flutter/material.dart';
///Clase de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> categoriesColorMap = {
    "vibrantOrange": Color.fromARGB(255, 255, 140, 0), //naranja vivo
    "brightYellow": Color.fromARGB(255, 255, 223, 0), //amarillo intenso
    "deepPurple": Color.fromARGB(255, 102, 51, 153), //púrpura vivo
    "electricBlue": Color.fromARGB(255, 0, 120, 215), //azul eléctrico
    "hotPink": Color.fromARGB(255, 255, 20, 147), //rosa fuerte
    "turquoise": Color.fromARGB(255, 64, 224, 208), //turquesa vibrante
    "brightCyan": Color.fromARGB(255, 0, 255, 255), //cian puro
    "magenta": Color.fromARGB(255, 255, 0, 255), //magenta vivo
    "lime": Color.fromARGB(
        255, 191, 255, 0), //lime vibrante (pero distinto al verde base)
    "goldenRod": Color.fromARGB(255, 218, 165, 32), //amarillo dorado
    "coral": Color.fromARGB(255, 255, 127, 80), //coral fuerte
    "royalBlue": Color.fromARGB(255, 65, 105, 225), //azul real
    "orchid": Color.fromARGB(255, 218, 112, 214), //orquídea
    "salmon": Color.fromARGB(255, 250, 128, 114), //salmón
    "sandyBrown": Color.fromARGB(255, 244, 164, 96), //arena marrón claro
  };
}
