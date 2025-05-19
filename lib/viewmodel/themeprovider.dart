import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isLightModeActive = true;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isLightModeActive = prefs.getBool('isLightModeActive') ?? true;
    notifyListeners();
  }

  //Los sigueintes colores es siguiendo el modo claro de la app (isLightModeActive == true). Controlo desde esta clase el modo claro/oscuro
  Map<String, Color> palette() => {
        //General
        "scaffoldBackground": (isLightModeActive)
            ? Color.fromARGB(255, 242, 242, 247)
            : Color.fromARGB(255, 28, 28, 30),
        "textBlackWhite": (isLightModeActive)
            ? Color.fromARGB(222, 0, 0, 0)
            : Color.fromARGB(255, 229, 229, 234),
        "textWhiteBlack": (isLightModeActive)
            ? Color.fromARGB(255, 229, 229, 234)
            : Color.fromARGB(222, 0, 0, 0),
        "buttonBlackWhite": (isLightModeActive)
            ? Color.fromARGB(222, 0, 0, 0)
            : Color.fromARGB(255, 229, 229, 234),
        "buttonWhiteBlack": (isLightModeActive)
            ? Color.fromARGB(255, 229, 229, 234)
            : Color.fromARGB(222, 0, 0, 0),
        "fixedBlack": Color.fromARGB(222, 0, 0, 0),
        "fixedWhite": Color.fromARGB(255, 229, 229, 234),
        "backgroundDialog": (isLightModeActive)
            ? Color.fromARGB(255, 242, 242, 247)
            : Color.fromARGB(255, 28, 28, 30),
        "filledTextField": (isLightModeActive)
            ? Color.fromARGB(255, 229, 229, 234)
            : Color.fromARGB(255, 22, 28, 33),
        "fixedRed": Color.fromARGB(255, 255, 59, 48),
        //Navegación inferior y pestañas
        "selectedItem": Colors.pink,
        "unselectedItem": (isLightModeActive)
            ? Color.fromARGB(222, 0, 0, 0)
            : Color.fromARGB(255, 229, 229, 234),
        "labelColor": Colors.pink,
        //Botones
        "greenButton": Color.fromARGB(255, 116, 212, 148),
        "greenButtonIsDark": Color.fromARGB(255, 60, 130, 80),
        "redButton": Color.fromARGB(255, 212, 103, 103),
        "redButtonIsDark": Color.fromARGB(255, 130, 60, 60),
      };

  //cambiar modo claro/oscuro
  void changeThemeMode() {
    isLightModeActive = !isLightModeActive;
    notifyListeners();
    final prefs = SharedPreferences.getInstance();
    prefs.then((value) => value.setBool('isLightModeActive', isLightModeActive));
  }
}
