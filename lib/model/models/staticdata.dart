import 'package:flutter/material.dart';

///Clase estática de colores disponibles para el color único representativo de las categorías
class StaticData {
  static const Map<String, Color> incomeCategoriesColorMap = {
    "warmClay":
        Color.fromARGB(255, 202, 160, 130), // terracota suave pero con peso
    "graphiteMist":
        Color.fromARGB(255, 150, 160, 170), // gris azulado con carácter
    "mutedIndigo": Color.fromARGB(
        255, 140, 150, 190), // índigo apagado, complementa bien el verde
    "blushTerracotta":
        Color.fromARGB(255, 210, 150, 140), // mezcla entre coral y barro rosado
    "cinnamonDust":
        Color.fromARGB(255, 190, 140, 100), // canela empolvada, cálida y otoñal
    "dustyLilac":
        Color.fromARGB(255, 190, 160, 190), // lila empolvado más profundo
    "stormyBlue": Color.fromARGB(255, 135, 160, 185), // azul tormentoso apagado
    "smokyRose":
        Color.fromARGB(255, 200, 150, 155), // rosa apagado grisáceo, elegante
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
