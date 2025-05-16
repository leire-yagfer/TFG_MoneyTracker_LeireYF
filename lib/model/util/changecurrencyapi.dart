import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';

//Clase que contiene las funciones para obtener los cambios de divisas y la lista de divisas, tanto del archivo interno, como de la API
class APIUtils {
  ///Función para obtener las operaciones de cambio de una moneda (Se pasa por parámetro el código de la moneda)
  static Future<Map<String, double>> getChangesBasedOnCurrencyCode(
      String actualCurrencyCode) async {
    Uri uri = Uri.https("cdn.jsdelivr.net",
        "npm/@fawazahmed0/currency-api@latest/v1/currencies/${actualCurrencyCode.toLowerCase()}.json"); //URL a la API buscando TODAS las operaciones de cambio de moneda (Por ejemplo si busco euro sale todas las equivalencias a 1 euro)
    var response = await http.get(uri); //Peticion GET
    if (response.statusCode == 200) {
      Map<String, double> currencyChanges = {};
      //Si es correcta
      var changesMap =
          jsonDecode(response.body); //JSON de todo lo que devuelve la API
      for (MapEntry<String, dynamic> entry
          in changesMap[actualCurrencyCode.toLowerCase()].entries) {
        currencyChanges[entry.key.toUpperCase()] = double.parse(
            entry.value.toString()); //Guardo en un mapa los cambios
      }
      return currencyChanges; //Devuelvo el mapa con los cambios
    } else {
      return {};
    }
  }

  static late List<Currency> allDivisas;

  //conseguir la divisa en la que está trabajando el usuario --> la que tiene guardada en su sesión
  //se busca en la lista de divisas que se ha cargado desde el archivo interno
  static Currency? getFromList(String userCurrency) {
    for (Currency d in allDivisas) {
      if (userCurrency == d.currencyCode) {
        return d;
      }
    }
    return null;
  }

  //cargar la lista de divisas desde el archivo interno al iniciar la app
  static Future<void> getAllCurrencies() async {
    allDivisas = [];
    String json = await rootBundle.loadString("assets/currencies.json");
    var jsonList = jsonDecode(json);
    for (var element in jsonList) {
      String clave = element["nombre_divisa"];
      String value = element["codigo_divisa"];
      String simbolo = element["simbolo_divisa"];

      allDivisas.add(Currency(
          currencyName: clave, currencyCode: value, currencySymbol: simbolo));
    }
  }
}
