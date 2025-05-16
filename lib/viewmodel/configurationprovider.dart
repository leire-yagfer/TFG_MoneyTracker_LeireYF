import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';

///Clase que gestiona el estado global de la app
class ConfigurationProvider extends ChangeNotifier {
  Locale _languaje = Locale('es');
  Currency _currencyCodeInUse = APIUtils.getFromList('EUR')!;
  //lista de transacciones
  List<TransactionModel> listAllTransactions = [];

  ///Cargar las preferencias guardadas al iniciar la app
  ConfigurationProvider(UserModel? u) {
    this.userRegistered = u;
    _loadPreferences();
  }

  //Obtener el idioma actual
  Locale get languaje => _languaje;

  //Obetener la divisa en la que se está trabajando
  Currency get currencyCodeInUse => _currencyCodeInUse;

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

  ///Cargar las preferencias guardadas en el dispositivo
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _languaje = Locale(prefs.getString('languaje') ?? 'es');
    _currencyCodeInUse =
        APIUtils.getFromList(prefs.getString('codeCurrencyInUse') ?? 'EUR')!;
    //Cargar las transacciones desde la base de datos
    await loadTransactions();
    notifyListeners();
  }

  ///Cargar las transacciones desde la base de datos, ordenadas por fecha
  Future<void> loadTransactions() async {
    listAllTransactions =
        await TransactionDao().getTransactionsByDate(userRegistered!);
    listAllTransactions
        .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    //Cambiar cada importe en función de la divisa que se esté usando --> en esta clase para que sea accesible y recargable desde todo el contexto (la app)
    for (var element in listAllTransactions) {
      if (element.transactionCurrency != currencyCodeInUse) {
        Map<String, double> cambios =
            await APIUtils.getChangesBasedOnCurrencyCode(
                element.transactionCurrency.currencyCode);
        element.transactionImport = element.transactionImport *
            cambios[currencyCodeInUse.currencyCode]!;
      }
    }
    notifyListeners();
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
