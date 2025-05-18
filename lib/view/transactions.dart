// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusabletxtformfieldshowtransaction.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///Clase que muestra todos los movimientos/transacciones que se han almacenado en la base de datos
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  TransactionDao transactionDao = TransactionDao();
  CategoryDao categoryDao = CategoryDao();
  List<TransactionModel> userTransactions =
      []; //creo la lista de transacciones que va a albergar aquellas que sean del usuario logeado
  @override
  void initState() {
    super.initState();
    //llamo a la función que muestra las transacciones de la BD del usuario en el momento en el que se cambia a este página
    _cargarTransacciones();

    //escucho cambios en la configuración para detectar cuando se cambia la moneda
    context.read<ConfigurationProvider>().addListener(_onConfigurationChanged);
  }

  //función que se ejecuta automáticamente al cambiar la configuración, tras haberle añadido el listener
  void _onConfigurationChanged() {
    _cargarTransacciones(); //recargo las transacciones con la nueva moneda
  }

  @override
  void dispose() {
    context
        .read<ConfigurationProvider>()
        .removeListener(_onConfigurationChanged);
    super.dispose();
  }

  bool _isLoading = true;

  ///Eliminar una transacción desde la interfaz de usuario
  Future<void> _deleteUITransaction(int index) async {
    //llamo al DAO para eliminar la transacción de Firestore
    await transactionDao.deleteTransaction(
        context.read<ConfigurationProvider>().userRegistered!,
        context.read<ConfigurationProvider>().listAllUserTransactions[index]);
    context.read<ConfigurationProvider>().listAllUserTransactions.removeAt(
        index); //elimino la transacción de la lista local del Provider
    context
        .read<ConfigurationProvider>()
        .notifyListeners(); //notifico a los listeners para que se actualice la interfaz
  }

  ///Formatear la fecha para mostrarla de forma legible
  String _formatearFecha(DateTime fecha) {
    try {
      return DateFormat('dd/MM/yyyy').format(fecha); // Formato: 07/02/2025
    } catch (e) {
      return fecha
          .toIso8601String(); // Si no se puede formatear, mostrar la fecha original
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Cargando transacciones")
                ],
              ),
            )
          : userTransactions.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noTransactions,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(18),
                        fontWeight: FontWeight.w600),
                  ),
                )
              : ListView.builder(
                  itemCount: context
                      .watch<ConfigurationProvider>()
                      .listAllUserTransactions
                      .length,
                  itemBuilder: (context, index) {
                    TransactionModel transaccion = userTransactions[index];

                    //obtengo el color de fondo sobre el que voy a ajustar el color rojo y verde para que se vean de manera correcta
                    Color transationCardBackgroundColor =
                        transaccion.transactionCategory.categoryColor;

                    Color rowAndImportColor;
                    Icon icono;

                    //obtengo la luminosidad del fondo de la card
                    double luminance =
                        transationCardBackgroundColor.computeLuminance();

                    if (transaccion.transactionCategory.categoryIsIncome) {
                      //si es ingreso --> verde. En función del color de la card será en un tono u otro
                      rowAndImportColor = luminance > 0.5
                          ? context
                              .watch<ThemeProvider>()
                              .palette()['greenButton']!
                          : context
                              .watch<ThemeProvider>()
                              .palette()['greenButtonIsDark']!;
                      icono = Icon(Icons.arrow_upward,
                          color: luminance > 0.5
                              ? context
                                  .watch<ThemeProvider>()
                                  .palette()['greenButton']!
                              : context
                                  .watch<ThemeProvider>()
                                  .palette()['greenButtonIsDark']!);
                    } else {
                      //si es gasto --> rojo. En función del color de la card será en un tono u otro
                      rowAndImportColor = luminance > 0.5
                          ? context
                              .watch<ThemeProvider>()
                              .palette()['redButtonIsDark']!
                          : context
                              .watch<ThemeProvider>()
                              .palette()['redButton']!;
                      icono = Icon(Icons.arrow_upward,
                          color: luminance > 0.5
                              ? context
                                  .watch<ThemeProvider>()
                                  .palette()['redButtonIsDark']!
                              : context
                                  .watch<ThemeProvider>()
                                  .palette()['redButton']!);
                    }
                    return Card(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal:
                              MediaQuery.of(context).size.width * 0.015),
                      color: transaccion.transactionCategory
                          .categoryColor, //Color de fondo de la tarjeta según categoría
                      child: ListTile(
                        onTap: () => _showTransactionDetail(transaccion, index),
                        contentPadding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.01),
                        leading: icono, //Flecha hacia arriba o hacia abajo
                        title: Text(
                          transaccion.transactionTittle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context
                                .watch<ThemeProvider>()
                                .palette()['fixedBlack']!,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.date}: ${_formatearFecha(transaccion.transactionDate)}",
                              style: TextStyle(
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['fixedBlack']!),
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.category}: ${transaccion.transactionCategory.categoryName}",
                              style: TextStyle(
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['fixedBlack']!),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    '${transaccion.transactionImport.toStringAsFixed(2)} ${context.watch<ConfigurationProvider>().currencyCodeInUse.currencySymbol}', //Importe con símbolo de la divisa en uso
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(14),
                                      color:
                                          rowAndImportColor, //Importe con color según tipo
                                    )),
                                Text(
                                    '${transaccion.transactionSecondImport.toStringAsFixed(2)} ${context.watch<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}', //Importe con símbolo de la divisa secundaria en uso
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(14),
                                      color:
                                          rowAndImportColor, //Importe con color según tipo
                                    )),
                              ],
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.01),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['fixedBlack']!),
                              iconSize: MediaQuery.of(context).size.width * 0.1,
                              onPressed: () {
                                _deleteUITransaction(index);
                                //Muestro SnackBar indicando que se ha eliminado correctamente
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Transacción eliminada correctamente"),
                                    duration: Duration(
                                        seconds: 3), //duración del SnackBar
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  //cargar las transacciones del usuario registradas en la base de datos ordenadas por fecha para mostrarles en orden
  void _cargarTransacciones() async {
    setState(() {
      _isLoading = true;
    });
    var aux = await transactionDao.getTransactionsByDate(
        context.read<ConfigurationProvider>().userRegistered!,
        context.read<ConfigurationProvider>().currencyCodeInUse.currencyCode,
        context.read<ConfigurationProvider>().currencyCodeInUse2.currencyCode);
    setState(() {
      userTransactions = aux;
      _isLoading = false;
    });
  }

  void _showTransactionDetail(TransactionModel transaccion, int index) {
    String tituloController = transaccion.transactionTittle;
    TextEditingController importeController = TextEditingController(
        text: transaccion.transactionImport.toStringAsFixed(2));
    TextEditingController fechaController = TextEditingController(
        text: _formatearFecha(transaccion.transactionDate));
    TextEditingController categoriaController = TextEditingController(
        text: transaccion.transactionCategory.categoryName);
    TextEditingController? descripcionController =
        TextEditingController(text: transaccion.transactionDescription);

    showDialog(
      barrierDismissible: true, //permitir cerrar el diálogo al hacer clic fuera
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tituloController),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ReusableTxtFormFieldShowDetailsTransaction(
                  text: importeController,
                  labelText: "Importe",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ReusableTxtFormFieldShowDetailsTransaction(
                  text: fechaController,
                  labelText: "Fecha",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ReusableTxtFormFieldShowDetailsTransaction(
                  text: categoriaController,
                  labelText: "Categoría",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                if (descripcionController.text.isNotEmpty)
                  ReusableTxtFormFieldShowDetailsTransaction(
                    text: descripcionController,
                    labelText: "Descripción",
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("cerrar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
