import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/util/changecurrencyapi.dart';

///Clase que gestiona el estado global de la app
class ProviderAjustes extends ChangeNotifier {
  bool _modoOscuro = false;
  Locale _idioma = Locale('es');
  Currency _codigoDivisaEnUso = APIUtils.getFromList('EUR')!;
  //lista de transacciones
  List<TransactionModel> listaTransacciones = [];

  ///Cargar las preferencias guardadas al iniciar la app
  ProviderAjustes(UserModel? usuario) {
    this.usuario = usuario;
    _cargarPreferencias();
  }

  //Obtener el estado actual del modo oscuro
  bool get modoOscuro => _modoOscuro;

  //Obtener el idioma actual
  Locale get idioma => _idioma;

  //Obetener la divisa en la que se está trabajando
  Currency get divisaEnUso => _codigoDivisaEnUso;

  //Obtener el usuario
  UserModel? usuario; //? pq puede ser nulo (puede que no esté registrado)

  ///Cambiar el modo oscuro y guardar la preferencia
  Future<void> cambiarModoOscuro(bool valor) async {
    _modoOscuro = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', valor);
  }

  ///Cambiar el idioma y guardar la preferencia
  Future<void> cambiarIdioma(String codigoIdioma) async {
    _idioma = Locale(codigoIdioma);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', codigoIdioma);
  }

  ///Cambiar la divisa y guardar la preferencia
  Future<void> cambiarDivisa(Currency nuevoCodigoDivisa) async {
    _codigoDivisaEnUso = nuevoCodigoDivisa;
    await cargarTransacciones(); //Recargar las transacciones con la nueva divisa

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('divisaEnUso', nuevoCodigoDivisa.currencyCode);
  }

  ///Cargar las preferencias guardadas en el dispositivo
  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _modoOscuro = prefs.getBool('modoOscuro') ?? false;
    _idioma = Locale(prefs.getString('idioma') ?? 'es');
    _codigoDivisaEnUso =
        APIUtils.getFromList(prefs.getString('divisaEnUso') ?? 'EUR')!;
    //Cargar las transacciones desde la base de datos
    await cargarTransacciones();
    notifyListeners();
  }

  ///Cargar las transacciones desde la base de datos, ordenadas por fecha
  Future<void> cargarTransacciones() async {
    listaTransacciones =
        await TransactionDao().getTransactionsByDate(usuario!);
    listaTransacciones.sort((a, b) => -a.transactionDate.compareTo(b.transactionDate));

    //Cambiar cada importe en función de la divisa que se esté usando --> en esta clase para que sea accesible y recargable desde todo el contexto (la app)
    for (var element in listaTransacciones) {
      if (element.transactionCurrency != divisaEnUso) {
        Map<String, double> cambios =
            await APIUtils.getChangesBasedOnCurrencyCode(element.transactionCurrency.currencyCode);
        element.transactionImport = element.transactionImport * cambios[divisaEnUso.currencyCode]!;
      }
    }
    notifyListeners();
  }

  ///Iniciar sesión
  void inicioSesion(UserModel u) {
    this.usuario = u;
    notifyListeners();
  }

  ///Cerrar sesión
  void cerrarSesion() {
    this.usuario = null;
    notifyListeners();
  }
}
