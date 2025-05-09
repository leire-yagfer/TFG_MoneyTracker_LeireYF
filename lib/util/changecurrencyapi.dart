import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto2eva_budget/model/models/divisa.dart';

class APIUtils {
  ///Función para obtener las operaciones de cambio de una moneda (Se pasa por parámetro)
  static Future<Map<String, double>> get_changes(String base) async {
    Uri uri = Uri.https("cdn.jsdelivr.net",
        "npm/@fawazahmed0/currency-api@latest/v1/currencies/${base.toLowerCase()}.json"); //URL a la API buscando TODAS las operaciones de cambio de moneda (Por ejemplo si buscamos euro sale todas las equivalencias a 1 euro)
    var response = await http.get(uri); //Pericion GET
    if (response.statusCode == 200) {
      Map<String, double> cambios = {};
      //Si es correcta
      var mapaCambios =
          jsonDecode(response.body); //JSON de todo lo que devuelve la API
      for (MapEntry<String, dynamic> entry
          in mapaCambios[base.toLowerCase()].entries) {
        cambios[entry.key.toUpperCase()] = double.parse(
            entry.value.toString()); //Guardamos en un mapa los cambios
      }
      ;
      return cambios; //Devolvemos el mapa con los cambiosƒ
    } else {
      return {};
    }
  }

  static late List<Divisa> allDivisas;

  //conseguir la divisa en la que está trabajando el usuario
  static Divisa? getFromList(String divisaUsuario) {
    for (Divisa d in allDivisas) {
      if (divisaUsuario == d.codigo_divisa) {
        return d;
      }
    }
    return null;
  }

  static Future<void> get_all_currencies() async {
    allDivisas = [];
    String json = await rootBundle.loadString("assets/currencies.json");
    var jsonList = jsonDecode(json);
    for (var element in jsonList) {
      String clave = element["nombre_divisa"];
      String value = element["codigo_divisa"];
      String simbolo = element["simbolo_divisa"];

      allDivisas.add(Divisa(
          nombre_divisa: clave, codigo_divisa: value, simbolo_divisa: simbolo));
    }
  }
}
