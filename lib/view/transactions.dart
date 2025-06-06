// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/view/reusable/reusablecircleprogressindicator.dart';
import 'package:tfg_monetracker_leireyafer/view/reusable/reusabletxtformfieldshowtransaction.dart';
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
    _loadTransactions();

    //escucho cambios en la configuración para detectar cuando se cambia la moneda
    context.read<ConfigurationProvider>().addListener(_onConfigurationChanged);
  }

  //función que se ejecuta automáticamente al cambiar la configuración, tras haberle añadido el listener
  void _onConfigurationChanged() {
    _loadTransactions(); //recargo las transacciones con la nueva moneda
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
  Future<void> _deleteUITransaction(TransactionModel transaction) async {
    //llamo al DAO para eliminar la transacción de Firestore
    await transactionDao.deleteTransaction(
        context.read<ConfigurationProvider>().userRegistered!,
        transaction);
    context.read<ConfigurationProvider>().listAllUserTransactions.remove(
        transaction); //elimino la transacción de la lista local del Provider
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
          ? ReusableCircleProgressIndicator(
              text: AppLocalizations.of(context)!.loadingTransactions,
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
                  itemCount: userTransactions
                      .length,
                  itemBuilder: (context, index) {
                    TransactionModel transactionPointer = userTransactions[index];

                    //obtengo el color de fondo de la card sobre el que voy a ajustar el color rojo y verde para que se vean de manera correcta
                    Color transationCardBackgroundColor =
                        transactionPointer.transactionCategory.categoryColor;

                    Color rowAndImportColor;
                    Icon icono;

                    //obtengo la luminosidad del fondo de la card
                    double luminance =
                        transationCardBackgroundColor.computeLuminance();

                    if (transactionPointer.transactionCategory.categoryIsIncome) {
                      //si es ingreso --> verde. En función del color de la card será en un tono u otro
                      rowAndImportColor = luminance > 0.3
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
                      icono = Icon(Icons.arrow_downward,
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
                      color: transactionPointer.transactionCategory
                          .categoryColor, //Color de fondo de la tarjeta según categoría
                      child: ListTile(
                        onTap: () => _showTransactionDetail(transactionPointer, index),
                        contentPadding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.01),
                        leading: icono, //Flecha hacia arriba o hacia abajo
                        title: Text(
                          transactionPointer.transactionTittle,
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
                              "${AppLocalizations.of(context)!.date}: ${_formatearFecha(transactionPointer.transactionDate)}",
                              style: TextStyle(
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['fixedBlack']!),
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.category}: ${transactionPointer.transactionCategory.categoryName}",
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
                            //si el usuario quiere usar la segunda divisa (en función del switch de ajustes), los datos de la segunda divisa se muestran en una columna con los dos importes y sino únicamnete el de la divisa en uso
                            context
                                    .read<ConfigurationProvider>()
                                    .switchUseSecondCurrency
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          '${transactionPointer.transactionImport.toStringAsFixed(2)} ${context.watch<ConfigurationProvider>().currencyCodeInUse.currencySymbol}', //Importe con símbolo de la divisa en uso
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context)
                                                .textScaler
                                                .scale(14),
                                            color:
                                                rowAndImportColor, //Importe con color según tipo
                                          )),
                                      Text(
                                          '${transactionPointer.transactionSecondImport.toStringAsFixed(2)} ${context.watch<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}', //Importe con símbolo de la divisa secundaria en uso
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context)
                                                .textScaler
                                                .scale(14),
                                            color:
                                                rowAndImportColor, //Importe con color según tipo
                                          )),
                                    ],
                                  )
                                : Text(
                                    '${transactionPointer.transactionImport.toStringAsFixed(2)} ${context.watch<ConfigurationProvider>().currencyCodeInUse.currencySymbol}', //Importe con símbolo de la divisa en uso
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(14),
                                      color:
                                          rowAndImportColor, //Importe con color según tipo
                                    )),
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
                                _deleteUITransaction(transactionPointer);
                                //Muestro SnackBar indicando que se ha eliminado correctamente
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .correctTransactionDeleting),
                                    duration: Duration(
                                        seconds: 1), //duración del SnackBar
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
  void _loadTransactions() async {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  context.watch<ThemeProvider>().palette()['backgroundDialog']!,
            ),
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tituloController, style: TextStyle(fontSize: MediaQuery.of(context).textScaler.scale(20), fontWeight: FontWeight.w600)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  ReusableTxtFormFieldShowDetailsTransactionAndEditCategory(
                    text: importeController,
                    labelText: AppLocalizations.of(context)!.amount,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  ReusableTxtFormFieldShowDetailsTransactionAndEditCategory(
                    text: fechaController,
                    labelText: AppLocalizations.of(context)!.date,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  ReusableTxtFormFieldShowDetailsTransactionAndEditCategory(
                    text: categoriaController,
                    labelText: AppLocalizations.of(context)!.category,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  if (descripcionController.text.isNotEmpty)
                    ReusableTxtFormFieldShowDetailsTransactionAndEditCategory(
                      text: descripcionController,
                      labelText: AppLocalizations.of(context)!.description,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
