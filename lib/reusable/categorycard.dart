// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/staticdata.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusabletxtformfield.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///Clase reutilizable para mostrar todas las actegorías en su pantalla en función del tipo para dividirlas en ingreso y gasto
class CategoryCard extends StatefulWidget {
  String title; //Título que se muestra arriba de la lista -> Ingresos/Gastos
  List<Category> categoriesList; //Lista de categorías a mostrar
  bool newCategoryIsIncome;
  Map<String, Color> categoriesColorMap;

  //Constructor de la clase
  CategoryCard({
    required this.title,
    required this.categoriesList,
    required this.newCategoryIsIncome,
    required this.categoriesColorMap,
  });

  @override
  State<StatefulWidget> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newCategoryNameController =
      TextEditingController();

  Color categoryColorSelected = StaticData.categoriesColorMap.values
      .first; //Color seleccionado por el usuario para la categoría --> lo inicializo en el primer valor del mapa de colores para categorías

  //crear una variable que va a almacenar el mapa de los iconos de las categorías, y voy a eliminar de la variable (mapa2) aquellos elementos que ya estén en uso
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Row para el titulo y el icono de añadir categoría
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).textScaler.scale(20),
                  fontWeight: FontWeight.w600),
            ),
            //he puesto que máximo puede haber 6 categorías por tipo y si es inferior se muestra un icono de añadir y si no, un icono de info que informa sobre que no se pueden añadir nuevas categorías pq se ha superado el límite
            (widget.categoriesList.length < 6)
                ? IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      //Dialog para añadir una nueva categoría en funión del tipo
                      showDialog(
                        barrierDismissible:
                            true, //Permitir cerrar el diálogo al hacer clic fuera de él
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.01,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.01),
                                child: Center(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        ReusableTxtFormFieldNewTransactionCategory(
                                          controller:
                                              _newCategoryNameController,
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .newCategoryNameLabel,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .newCategoryNameLabelHint,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .newCategoryNameLabelError;
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.008),
                                        //color picker para seleccionar el color de la categorí
                                        GestureDetector(
                                          onTap: () {
                                            //obtengo los colores ya usados por otras categorías
                                            final usedColors = widget
                                                .categoriesList
                                                .map((c) => c.categoryColor)
                                                .toList();

                                            //excluyo los colores usados para quedarme solo con los disponibles
                                            final availableColors = widget
                                                .categoriesColorMap.values
                                                .where((c) =>
                                                    !usedColors.contains(c))
                                                .toList();

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(AppLocalizations
                                                          .of(context)!
                                                      .newCategoryColorTitle),
                                                  //si hay colores disponibles, les muestro, sino muestra mensaje de que no hay colores disponibles. Es útil para que si se sambia el número de categorías permitidas, pues no haya errores --> Control de error
                                                  content: availableColors
                                                          .isNotEmpty
                                                      ? SingleChildScrollView(
                                                          child: BlockPicker(
                                                            pickerColor:
                                                                categoryColorSelected,
                                                            availableColors:
                                                                availableColors,
                                                            onColorChanged:
                                                                (Color color) {
                                                              setState(() {
                                                                categoryColorSelected =
                                                                    color;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        )
                                                      : Text(AppLocalizations
                                                              .of(context)!
                                                          .noColorsAvailable),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.02,
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.025,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        categoryColorSelected,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(AppLocalizations.of(
                                                        context)!
                                                    .newCategoryColorLabel),
                                                Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.008),
                                        //Botón para agregar la categoría
                                        ReusableButton(
                                            onClick: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                //Si el formulario es válido, procedo a añadir la categoría
                                                //Recoger los datos
                                                String newCategoryName =
                                                    _newCategoryNameController
                                                        .text;
                                                //Crear la categoría --> el id es el nombre
                                                Category newCategory = Category(
                                                    categoryName:
                                                        newCategoryName,
                                                    categoryIsIncome: widget
                                                        .newCategoryIsIncome,
                                                    categoryColor:
                                                        categoryColorSelected);

                                                //Insertar la nueva categoría en la base de datos
                                                await CategoryDao()
                                                    .insertCategory(
                                                        context
                                                            .read<
                                                                ConfigurationProvider>()
                                                            .userRegistered!,
                                                        newCategory);
                                                //Cerrar el diálogo
                                                Navigator.of(context).pop();
                                                //añado la categoría a la lista de la interfaz
                                                setState(() {
                                                  widget.categoriesList.add(newCategory);
                                                });
                                                //Mostrar SnackBar de confirmación
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations
                                                            .of(context)!
                                                        .correctCategoryAdding),
                                                    duration: Duration(
                                                        seconds:
                                                            3), //duración del SnackBar
                                                  ),
                                                );
                                              }
                                            },
                                            colorButton: 'fixedWhite',
                                            textButton:
                                                AppLocalizations.of(context)!
                                                    .add,
                                            colorTextButton: 'buttonBlackWhite',
                                            buttonHeight: 0.09,
                                            buttonWidth: 0.5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : IconButton(
                    //si las categorías de los tipos superan el máximo, 6, no se permite añadir nuevas categorías por loq ue se muestra un mensaje informativo
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible:
                            true, //Permitir cerrar el diálogo al hacer clic fuera de él
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                AppLocalizations.of(context)!.maxLimitExceeded),
                            content: Text(AppLocalizations.of(context)!
                                .maxLimitExceededLabel),
                            actions: <Widget>[
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.accept),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    })
          ],
        ),
        ListView.builder(
          shrinkWrap: true, //Permite que la lista ocupe el espacio necesario
          physics:
              const NeverScrollableScrollPhysics(), //Desactiva el scroll para que no se superponga con el scroll del dialog
          itemCount: widget.categoriesList.length,
          itemBuilder: (context, index) {
            var categoryPointer = widget.categoriesList[index];
            return Card(
              color: categoryPointer.categoryColor,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.008,
                  horizontal: MediaQuery.of(context).size.width * 0.015),
              child: ListTile(
                contentPadding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                title: Text(
                  categoryPointer.categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        context.watch<ThemeProvider>().palette()['fixedBlack']!,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete,
                      color: context
                          .watch<ThemeProvider>()
                          .palette()['fixedBlack']!),
                  iconSize: MediaQuery.of(context).size.width * 0.1,
                  onPressed: () async {
                    //llamo al método del DAO para eliminar la categoría de Firestore
                    await CategoryDao().deleteCategory(
                      context.read<ConfigurationProvider>().userRegistered!,
                      categoryPointer,
                    );
                    //elimino la categoría también de la lista local
                    setState(() {
                      widget.categoriesList.removeAt(index);
                    });

                    //muestro un mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .correctCategoryDeleting),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
