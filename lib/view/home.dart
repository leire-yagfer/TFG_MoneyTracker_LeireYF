// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusabletxtformfield.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que se muestra al iniciar la app y que incluye la inserción de nuevos ingresos o gastos
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Botón para agregar un ingreso
            ReusableButton(
                onClick: () {
                  _showOverlay(
                      context,
                      AppLocalizations.of(context)!.addIncome,
                      Provider.of<ThemeProvider>(context, listen: false)
                          .palette()['greenButton']!);
                },
                colorButton: 'greenButton',
                textButton: AppLocalizations.of(context)!.addIncome,
                colorTextButton: 'buttonBlackWhite',
                buttonHeight: 0.1,
                buttonWidth: 0.6),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            //Botón para agregar un gasto
            ReusableButton(
                onClick: () {
                  _showOverlay(
                      context,
                      AppLocalizations.of(context)!.addExpense,
                      Provider.of<ThemeProvider>(context, listen: false)
                          .palette()['redButton']!);
                },
                colorButton: 'redButton',
                textButton: AppLocalizations.of(context)!.addExpense,
                colorTextButton: 'buttonBlackWhite',
                buttonHeight: 0.1,
                buttonWidth: 0.6),
          ],
        ),
      ),
    );
  }

  //Método para mostrar el overlay del formulario de nueva transacción
  void _showOverlay(BuildContext context, String title, Color color) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _tituloController = TextEditingController();
    final TextEditingController _cantidadController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _descripcionController =
        TextEditingController();
    List<Category> categorias =
        []; //Lista de categorías -> se cargará con las categorías de ingreso o gasto según lo que se haya elegido
    Category? selectedCategoria; //Categoría seleccionada

    categorias = await CategoryDao().getCategoriesByType(
        context.read<ProviderAjustes>().usuario!,
        color !=
            Provider.of<ThemeProvider>(context, listen: false).palette()[
                'redButton']!); //Obtener categorías del usuario en función del color. EN este caso le paso el rojo porque si es rojo va a mostrar los que sean de gatsos y sino los verdes.

    showDialog(
      context: context,
      barrierDismissible:
          true, //Permitir cerrar el diálogo al hacer clic fuera de él
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaler.scale(30),
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Campo para el título de la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _tituloController,
                          labelText: AppLocalizations.of(context)!.title,
                          hintText: AppLocalizations.of(context)!.titleHint,
                          validator: (x) {
                            if (x == null || x.isEmpty) {
                              return AppLocalizations.of(context)!.titleError;
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Campo para la cantidad de la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _cantidadController,
                          keyboardType: TextInputType.number, //solo números
                          labelText: AppLocalizations.of(context)!.quantity,
                          hintText: "${AppLocalizations.of(context)!.quantityHint} (${context.read<ProviderAjustes>().divisaEnUso.currencySymbol})",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .quantityError;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(context)!
                                  .quantityError;
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Selección de categoría (solo se muestran las categorías del tipo elegido)
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DropdownButtonFormField<Category>(
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.categories,
                                filled: true,
                                fillColor: context
                                    .watch<ThemeProvider>()
                                    .palette()['fixedLightGrey']!,
                                border: OutlineInputBorder(),
                              ),
                              value: selectedCategoria,
                              onChanged: (Category? newValue) {
                                setState(() {
                                  selectedCategoria =
                                      newValue; //Actualizar categoría seleccionada
                                });
                              },
                              items: categorias.map((Category categoria) {
                                return DropdownMenuItem<Category>(
                                  value: categoria,
                                  child: Text(categoria
                                      .categoryName), //Nombre de la categoría
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(context)!
                                      .categoryError; //Validación para categoría
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        // Selector de fecha para la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _dateController,
                          labelText: AppLocalizations.of(context)!.date,
                          hintText: AppLocalizations.of(context)!.dateHint,
                          readOnly: true,
                          onTap: () async {
                            //Mostrar el selector de fecha
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null) {
                              _dateController.text = pickedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]; //Mostrar fecha seleccionada
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .dateError; // Validación para fecha
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        // Campo para la descripción de la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _descripcionController,
                          labelText: AppLocalizations.of(context)!.description,
                          hintText:
                              AppLocalizations.of(context)!.descriptionHint,
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Botón para agregar la transacción
                        ReusableButton(
                            onClick: () async {
                              if (_formKey.currentState!.validate()) {
                                //Si el formulario es válido, proceder con la transacción
                                //Recoger los datos
                                String titulo = _tituloController.text;
                                double cantidad =
                                    double.parse(_cantidadController.text);
                                String fecha = _dateController.text;
                                String descripcion =
                                    _descripcionController.text;

                                //Crear la transacción
                                //no paso el ID porque es autoincremental en el propio FireBase
                                TransactionModel transaccion = TransactionModel(
                                    transactionId: "",
                                    transactionTittle: titulo,
                                    transactionDate: DateTime.parse(fecha),
                                    transactionCategory: selectedCategoria!,
                                    transactionImport: cantidad,
                                    transactionCurrency: context
                                        .read<ProviderAjustes>()
                                        .divisaEnUso,
                                    transactionDescription: descripcion);

                                //Insertar transacción en la base de datos
                                await TransactionDao().insertTransaction(
                                    context.read<ProviderAjustes>().usuario!,
                                    transaccion);
                                await context
                                    .read<ProviderAjustes>()
                                    .cargarTransacciones();

                                //Cerrar el diálogo
                                Navigator.of(context).pop();

                                //Mostrar SnackBar de confirmación
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .correctTransactionAdding),
                                    duration: Duration(
                                        seconds: 3), //duración del SnackBar
                                  ),
                                );
                              }
                            },
                            colorButton: 'fixedWhite',
                            textButton: AppLocalizations.of(context)!.add,
                            colorTextButton: 'buttonBlackWhite',
                            buttonHeight: 0.09,
                            buttonWidth: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            )));
      },
    );
  }
}
