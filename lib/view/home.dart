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
                  _addIncomeExpenseTransaction(
                      context,
                      AppLocalizations.of(context)!.addIncome,
                      Provider.of<ThemeProvider>(context, listen: false)
                          .palette()['greenButton']!);
                },
                colorButton: 'greenButton',
                textButton: AppLocalizations.of(context)!.addIncome,
                colorTextButton: 'buttonBlackWhite',
                buttonHeight: 0.1,
                buttonWidth: 0.4),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            //Botón para agregar un gasto
            ReusableButton(
                onClick: () {
                  _addIncomeExpenseTransaction(
                      context,
                      AppLocalizations.of(context)!.addExpense,
                      Provider.of<ThemeProvider>(context, listen: false)
                          .palette()['redButton']!);
                },
                colorButton: 'redButton',
                textButton: AppLocalizations.of(context)!.addExpense,
                colorTextButton: 'buttonBlackWhite',
                buttonHeight: 0.1,
                buttonWidth: 0.4),
          ],
        ),
      ),
    );
  }

  //Método para mostrar el overlay del formulario de nueva transacción
  void _addIncomeExpenseTransaction(
      BuildContext context, String title, Color backgroundColor) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _importController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    List<Category> listCategoriesIncomeOrExpense =
        []; //Lista de categorías -> se cargará con las categorías de ingreso o gasto según lo que se haya elegido
    Category? categorySelected; //Categoría seleccionada

    listCategoriesIncomeOrExpense = await CategoryDao().getCategoriesByType(
        context.read<ConfigurationProvider>().userRegistered!,
        backgroundColor !=
            Provider.of<ThemeProvider>(context, listen: false).palette()[
                'redButton']!); //Obtener categorías del usuario en función del color. En este caso le paso el rojo porque si es rojo va a mostrar los que sean de gastos y sino los verdes.

    showDialog(
      context: context,
      barrierDismissible:
          true, //Permitir cerrar el diálogo al hacer clic fuera de él
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: context
                    .watch<ThemeProvider>()
                    .palette()['buttonBlackWhite']!,
                width: 1,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: Center(
                child: Container(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaler.scale(30),
                            fontWeight: FontWeight.w600,
                            color: context
                                .watch<ThemeProvider>()
                                .palette()['textBlackWhite']!,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Campo para el título de la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _titleController,
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
                          controller: _importController,
                          keyboardType: TextInputType.number, //solo números
                          labelText: AppLocalizations.of(context)!.quantity,
                          hintText:
                              "${AppLocalizations.of(context)!.quantityHint} (${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol})",
                          //compruebo si el campo está vacío y si es posible pasarlo a double. Si falla, devuelvo mensaje de error
                          validator: (x) {
                            if (x == null || x.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .quantityError;
                            }
                            if (double.tryParse(x) == null) {
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
                                    .palette()['filledTextField']!,
                                border: OutlineInputBorder(),
                              ),
                              value: categorySelected,
                              onChanged: (Category? cSelected) {
                                setState(() {
                                  categorySelected =
                                      cSelected; //Actualizar categoría seleccionada
                                });
                              },
                              items: listCategoriesIncomeOrExpense
                                  .map((Category categoria) {
                                return DropdownMenuItem<Category>(
                                  value: categoria,
                                  child: Text(categoria
                                      .categoryName), //Nombre de la categoría
                                );
                              }).toList(),
                              //valido si ha sido seleccionada alguna categoría
                              validator: (x) {
                                if (x == null) {
                                  return AppLocalizations.of(context)!
                                      .categoryError;
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
                              initialDate: DateTime.now(), //muestra el inicial
                              firstDate: DateTime(2020, 1, 1), //1 de enero de 2020
                              lastDate: DateTime(2025, 12, 31), //31 de diciembre de 2025
                            );

                            if (pickedDate != null) {
                              _dateController.text = pickedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]; //Mostrar fecha seleccionada
                            }
                          },

                          //valido que no se haya dejado el campo vacío
                          validator: (x) {
                            if (x == null || x.isEmpty) {
                              return AppLocalizations.of(context)!.dateError;
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Campo para la descripción de la transacción
                        ReusableTxtFormFieldNewTransactionCategory(
                          controller: _descriptionController,
                          labelText: AppLocalizations.of(context)!.description,
                          hintText:
                              AppLocalizations.of(context)!.descriptionHint,
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //Botón para agregar la transacción
                        ReusableButton(
                            onClick: () async {
                              //Compruebo si el formulario es válido
                              if (_formKey.currentState!.validate()) {
                                //si es válido --> creo la transacción
                                //Recoger los datos
                                String titulo = _titleController.text;
                                double cantidad =
                                    double.parse(_importController.text);
                                String fecha = _dateController.text;
                                String descripcion =
                                    _descriptionController.text;

                                //Crear la transacción --> no paso el ID porque es autoincremental en el propio FireBase
                                TransactionModel newTransaction =
                                    TransactionModel(
                                        transactionId: "",
                                        transactionTittle: titulo,
                                        transactionDate: DateTime.parse(fecha),
                                        transactionCategory: categorySelected!,
                                        transactionImport: cantidad,
                                        transactionSecondImport: cantidad,
                                        transactionCurrency: context
                                            .read<ConfigurationProvider>()
                                            .currencyCodeInUse,
                                        transactionSecondCurrency: context
                                            .read<ConfigurationProvider>()
                                            .currencyCodeInUse,
                                        transactionDescription: descripcion);

                                //Insertar transacción en la base de datos
                                await TransactionDao().insertTransaction(
                                    context
                                        .read<ConfigurationProvider>()
                                        .userRegistered!,
                                    newTransaction);
                                await context
                                    .read<ConfigurationProvider>()
                                    .loadTransactions();

                                //Cerrar el diálogo
                                Navigator.of(context).pop();

                                //Mostrar SnackBar de confirmación
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .correctTransactionAdding),
                                    duration: Duration(
                                        seconds: 1), //duración del SnackBar
                                  ),
                                );
                              }
                            },
                            colorButton: 'filledTextField',
                            textButton: AppLocalizations.of(context)!.add,
                            colorTextButton: 'textBlackWhite',
                            buttonHeight: 0.075,
                            buttonWidth: 0.3),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ),
                  ),
                ),
              )),
            ));
      },
    );
  }
}
