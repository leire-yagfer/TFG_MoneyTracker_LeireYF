// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
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
  CategoryDao categoriaDao = CategoryDao();
  List<TransactionModel> transacciones = []; //creo la lista de transacciones que va a albergar aquellas que sean del usuario logeado
  @override
  void initState() {
    super.initState();
    //llamo a la función que muestra las transacciones de la BD del usuario en el momento en el que se cambia a este página
    _cargarTransacciones();
  }
  bool _isLoading = true;
  ///Eliminar una transacción
  Future<void> _eliminarTransaccion(int index) async {
    await transactionDao.deleteTransaction(
        context.read<ProviderAjustes>().usuario!,
        context.read<ProviderAjustes>().listaTransacciones[index]);
    context.read<ProviderAjustes>().listaTransacciones.removeAt(index);
    context.read<ProviderAjustes>().notifyListeners();
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
      body: (_isLoading)? CircularProgressIndicator() : transacciones.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.noTransactions,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              itemCount: transacciones.length,
              itemBuilder: (context, index) {
                TransactionModel transaccion = transacciones[index];
                Color fechaEImporteColor;
                Icon icono;
                if (transaccion.transactionCategory.categoryIsIncome) {
                  //si es ingreso
                  fechaEImporteColor = context
                      .watch<ThemeProvider>()
                      .palette()['greenButton']!; //Verde
                  icono = Icon(Icons.arrow_upward, color: fechaEImporteColor);
                } else {
                  //si es gasto
                  fechaEImporteColor = context
                      .watch<ThemeProvider>()
                      .palette()['redButton']!; //Rojo
                  icono = Icon(Icons.arrow_downward, color: fechaEImporteColor);
                }
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.012,
                      horizontal: MediaQuery.of(context).size.width * 0.015),
                  color: transaccion.transactionCategory
                      .categoryColor, //Color de fondo de la tarjeta según categoría
                  child: ListTile(
                    //onTap: () => _mostrarDetalleEditable(transaccion, index),
                    contentPadding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    leading: icono, //Flecha hacia arriba o hacia abajo
                    title: Text(
                      transaccion.transactionTittle,
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
                          "${AppLocalizations.of(context)!.category}: ${transaccion.transactionCategory}",
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
                        Text(
                          '${transaccion.transactionImport.toStringAsFixed(2)} ${context.watch<ProviderAjustes>().divisaEnUso.currencySymbol}', //Importe con símbolo de la divisa en uso
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).textScaler.scale(14),
                            color:
                                fechaEImporteColor, //Importe con color según tipo
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: context
                                  .watch<ThemeProvider>()
                                  .palette()['fixedBlack']!),
                          iconSize: MediaQuery.of(context).size.width * 0.05,
                          onPressed: () {
                            _eliminarTransaccion(index);
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
  
  //cargar la stransacciones del usuario registradas en la base de datos ordenadas por fecha para mostrarles en orden
  void _cargarTransacciones() async{
    setState(() {
      _isLoading = true;
    });
    var aux = await transactionDao.getTransactionsByDate(context.read<ProviderAjustes>().usuario!);
    setState(() {
      transacciones = aux;
    });
    setState(() {
      _isLoading = false;
    });
  }
/*
  void _mostrarDetalleEditable(Transaccion transaccion, int index) {
    TextEditingController tituloController =
        TextEditingController(text: transaccion.tituloTransaccion);
    TextEditingController importeController =
        TextEditingController(text: transaccion.importe.toStringAsFixed(2));
    TextEditingController fechaController =
        TextEditingController(text: transaccion.fecha);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editTransaction),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.title),
                ),
                TextField(
                  controller: importeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.amount),
                ),
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.date),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.accept),
              onPressed: () async {
                try {
                  double nuevoImporte = double.parse(importeController.text);
                  Transaccion transaccionModificada = Transaccion(
                    id: transaccion.id,
                    tituloTransaccion: tituloController.text,
                    categoria: transaccion.categoria,
                    importe: nuevoImporte,
                    fecha: fechaController.text,
                    divisaPrincipal: context
                        .read()<ProviderAjustes>()
                        .divisaEnUso
                        .codigo_divisa,
                    idUsuario: 1,
                  );

                  await transaccionCRUD
                      .actualizarTransaccion(transaccionModificada);

                  context.read<ProviderAjustes>().listaTransacciones[index] =
                      transaccionModificada;
                  context.read<ProviderAjustes>().notifyListeners();

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .errorUpdatingTransaction)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }*/
}
