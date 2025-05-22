// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
//import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';

///Clase que gestiona el estado global de la app
class ConfigurationProvider extends ChangeNotifier {
  Locale _languaje = Locale('es'); //por defecto español
  Currency _currencyCodeInUse = APIUtils.getFromList('EUR')!; //por defecto en €
  Currency _currencyCodeInUse2 = APIUtils.getFromList('EUR')!; //por defecto en €
  bool _switchUseSecondCurrency = false;
  //bool isWifiConnected = true; //controla si el dispositivo está conectado a internet
  
  //lista de transacciones
  List<TransactionModel> listAllUserTransactions = [];

  ///Cargar las preferencias guardadas al iniciar la app
  ConfigurationProvider(UserModel? u) {
    this.userRegistered = u;
    _loadPreferences();
  }

  //Obtener el idioma actual
  Locale get languaje => _languaje;

  //Obetener la divisa en la que se está trabajando
  Currency get currencyCodeInUse => _currencyCodeInUse;

  //Obetener la segunda divisa en la que se está trabajando
  Currency get currencyCodeInUse2 => _currencyCodeInUse2;

  //Obetener el estado del switch en función de si se quiere trabajar o no con la segunda divisa
  bool get switchUseSecondCurrency => _switchUseSecondCurrency;

  //Obtener el usuario
  UserModel?
      userRegistered; //? pq puede ser nulo (puede que no esté registrado)

  ///Cambiar el idioma y guardar la preferencia
  Future<void> changeLanguaje(String languajeCode) async {
    _languaje = Locale(languajeCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languaje', languajeCode);
  }

  ///Cambiar la divisa y guardar la preferencia
  Future<void> changeCurrency(Currency newCurrencyCode) async {
    _currencyCodeInUse = newCurrencyCode;
    await loadTransactions(); //Recargar las transacciones con la nueva divisa

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCodeInUse', newCurrencyCode.currencyCode);
  }

  ///Cambiar la divisa secundaria y guardar la preferencia
  Future<void> changeCurrency2(Currency newCurrencyCode) async {
    _currencyCodeInUse2 = newCurrencyCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCodeInUse2', newCurrencyCode.currencyCode);
  }

  ///Cambiar el estado del switch y guardar la preferencia
  Future<void> changeSwitchUseSecondCurrency(bool value) async {
    _switchUseSecondCurrency = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchUseSecondCurrency', value);
  }

  ///Cargar las preferencias guardadas en el dispositivo
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _languaje = Locale(prefs.getString('languaje') ?? 'es');
    _currencyCodeInUse =
        APIUtils.getFromList(prefs.getString('currencyCodeInUse') ?? 'EUR')!;
    _currencyCodeInUse2 =
        APIUtils.getFromList(prefs.getString('currencyCodeInUse2') ?? 'EUR')!;
    _switchUseSecondCurrency =
        prefs.getBool('switchUseSecondCurrency') ?? false;

    //Cargar las transacciones desde la base de datos
    await loadTransactions();
    notifyListeners();
  }

  ///Cargar las transacciones desde la base de datos, ordenadas por fecha
  Future<void> loadTransactions() async {
    //Try-catch para ver si tiene internet el usuario al iniciar la app --> pruebo a ver si se consiguen las transacciones de firebase y si no se consigue (no hay internet) salto al catch
    //try {
      listAllUserTransactions = await TransactionDao().getTransactionsByDate(
          userRegistered!,
          currencyCodeInUse.currencyCode,
          currencyCodeInUse2.currencyCode);
      //ordeno por fecha --> la más reciente la primera
      listAllUserTransactions
          .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      for (var t in listAllUserTransactions) {
        if (t.transactionCurrency.currencyCode != currencyCodeInUse.currencyCode) {
          //obtengo las tasas de cambio desde la moneda original de la transacción en el puntero (es decir por la que me llego)
          Map<String, double> changesRates =
              await APIUtils.getChangesBasedOnCurrencyCode(
                  t.transactionCurrency.currencyCode);

          //reemplazo el importe con el convertido a la moneda en uso
          t.transactionImport *= changesRates[currencyCodeInUse.currencyCode]!;
        }
        String secondaryCurrencyCode = t.transactionSecondCurrency.currencyCode;
        Map<String, double> secondaryChangesRates =
            await APIUtils.getChangesBasedOnCurrencyCode(secondaryCurrencyCode);

        t.transactionSecondImport = t.transactionSecondImport *
            secondaryChangesRates[t.transactionSecondCurrency.currencyCode]!;
      }
      notifyListeners();
    /*} catch (e) {
      Logger().e('Error al cargar transacciones: $e');
      isWifiConnected = false;
      notifyListeners();
    }*/
  }

  ///Iniciar sesión
  void logIn(UserModel u) {
    this.userRegistered = u;
    notifyListeners();
  }

  ///Cerrar sesión
  void logOut() {
    this.userRegistered = null;
    notifyListeners();
  }
}
