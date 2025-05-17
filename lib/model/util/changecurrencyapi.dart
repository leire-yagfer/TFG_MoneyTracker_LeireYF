import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';

//Clase que contiene las funciones para obtener los cambios de divisas y la lista de divisas, tanto del archivo interno, como de la API
class APIUtils {
  ///Función para obtener las operaciones de cambio de una moneda (Se pasa por parámetro el código de la moneda de la que quiero conseguir el cambio)
  static Future<Map<String, double>> getChangesBasedOnCurrencyCode(
      String actualCurrencyCode) async {
    //link: https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/eur.json
    Uri uri = Uri.https("cdn.jsdelivr.net",
        "npm/@fawazahmed0/currency-api@latest/v1/currencies/${actualCurrencyCode.toLowerCase()}.json"); //URL a la API buscando TODAS las operaciones de cambio de moneda (Por ejemplo si busco euro sale todas las equivalencias a 1 euro)
    var response = await http.get(uri); //Peticion GET
    if (response.statusCode == 200) {
      Map<String, double> currencyChanges = {};
      //Si es correcta --> JSON de todo lo que devuelve la API
      var changesJSON =
          jsonDecode(response.body); 
      //Guardo en un mapa los cambios iterando sobre todos los cambios que se han encontrado
      for (MapEntry<String, dynamic> entry
          in changesJSON[actualCurrencyCode.toLowerCase()].entries) {
        //convierto el código de moneda a mayúsculas (key) y la tasa de cambio la paso a double
        currencyChanges[entry.key.toUpperCase()] = double.parse(
            entry.value.toString()); 
      }
      return currencyChanges; //Devuelvo el mapa con los cambios
    } else {
      return {};
    }
  }

  //lista que va a almacenar todas las divisas disponibles en la app
  static late List<Currency> allCurrenciesList;

  //conseguir la divisa en la que está trabajando el usuario --> la que tiene guardada en su sesión
  //se busca en la lista de divisas que se ha cargado desde el archivo interno
  static Currency? getFromList(String userCurrency) {
    for (Currency d in allCurrenciesList) {
      if (userCurrency == d.currencyCode) {
        return d;
      }
    }
    return null;
  }

  //cargar la lista de divisas desde el archivo interno al iniciar la app para sabes cuales son las divisas disponibles para usar
  static Future<void> getAllCurrencies() async {
    allCurrenciesList = [];
    //obtengo la ruta del json y extraigo todo su interior para luego tener accedo a ello
    String json = await rootBundle.loadString("assets/currencies.json");
    var jsonList = jsonDecode(json);
    for (var element in jsonList) {
      String key = element["nombre_divisa"];
      String value = element["codigo_divisa"];
      String simbol = element["simbolo_divisa"];

      allCurrenciesList.add(Currency(
          currencyName: key, currencyCode: value, currencySymbol: simbol));
    }
  }
}
