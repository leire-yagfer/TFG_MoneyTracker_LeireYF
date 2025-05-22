// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/view/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/view/reusable/reusabletxtformfield.dart';
import 'package:tfg_monetracker_leireyafer/view/reusable/reusabletxtformfieldshowtransaction.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///Clase reutilizable para mostrar todas las actegorías en su pantalla en función del tipo para dividirlas en ingreso y gasto
class CategoryCard extends StatefulWidget {
  String title; //Título que se muestra arriba de la lista -> Ingresos/Gastos
  List<Category> categoriesList; //Lista de categorías a mostrar
  bool newCategoryIsIncome;
  Map<String, Color> categoriesColorMap;
  List<Category>
      listAllCategories; //lista que almacena todas las categorías que se muestran en la página

  //Constructor de la clase
  CategoryCard({
    required this.title,
    required this.categoriesList,
    required this.newCategoryIsIncome,
    required this.categoriesColorMap,
    required this.listAllCategories,
  });

  @override
  State<StatefulWidget> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newCategoryNameController =
      TextEditingController();

  bool isCtegoryUpdatingOrCreating = false;

  List<Category> categoriesList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      categoriesList = widget.categoriesList;
    });
  }

  //variables declaradas como "funciones getter" que me permiten cuando las llame tener los colores actualizados
  //colores ya usados por categorías de un tipo (va en función del + seleccionado que coge si es ingreso o gasto)
  Set<Color> usedColorsByType() => widget.listAllCategories
      .where((c) => c.categoryIsIncome == widget.newCategoryIsIncome)
      .map((c) => c.categoryColor)
      .toSet();

  //colores disponibles para el tipo actual (el elegido para añadir nueva categoría)
  List<Color> availableColors() => widget.categoriesColorMap.values
      .where((color) => !usedColorsByType().contains(color))
      .toList();

  @override
  Widget build(BuildContext context) {
    Color categoryColorSelected = availableColors()
        .first; //Color seleccionado por el usuario para la categoría --> lo inicializo en el primer color libre disponible del mapa de colores del tipo seleccionado

    return Column(children: [
      //Row para el titulo y el icono de añadir categoría
      Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.w600),
              ),
              //he puesto que máximo puede haber 6 categorías por tipo y si es inferior se muestra un icono de añadir y si no, un icono de info que informa sobre que no se pueden añadir nuevas categorías pq se ha superado el límite
              (categoriesList.length < 6)
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['backgroundDialog']!,
                                ),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.height *
                                          0.02),
                                  child: Center(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .newcategoryTitle,
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02),
                                          ReusableTxtFormFieldNewTransactionCategory(
                                            controller:
                                                _newCategoryNameController,
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .newCategoryNameLabel,
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .newCategoryNameLabelHint,
                                            //compruebo que no se haya dejado vacío el campo
                                            validator: (x) {
                                              if (x == null || x.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .newCategoryNameLabelError;
                                              }
                                              if (checkNameUniqueness(x.trim(),
                                                  widget.listAllCategories)) {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .categoryNameAlreadyExists;
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02),
                                          //color picker para seleccionar el color de la categoría
                                          SizedBox(
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .newCategoryColorTitle,
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis)),
                                                      content: availableColors()
                                                              .isNotEmpty
                                                          ? SingleChildScrollView(
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  //restrinjo el ancho del selector de colores
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  maxHeight: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4,
                                                                ),
                                                                child:
                                                                    ConstrainedBox(
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          //restrinjo el ancho del selector de colores
                                                                          maxWidth:
                                                                              MediaQuery.of(context).size.width * 0.8,
                                                                          maxHeight:
                                                                              MediaQuery.of(context).size.width * 0.4,
                                                                        ),
                                                                        child:
                                                                            BlockPicker(
                                                                          pickerColor:
                                                                              categoryColorSelected,
                                                                          availableColors:
                                                                              availableColors(),
                                                                          onColorChanged:
                                                                              (Color color) {
                                                                            setState(() {
                                                                              categoryColorSelected = color;
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        )),
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.02,
                                                  vertical:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: context
                                                            .watch<ThemeProvider>()
                                                            .palette()[
                                                        'textBlackWhite']!,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.025,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            categoryColorSelected,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.02),
                                                    Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .newCategoryColorLabel,
                                                        style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01),
                                                    Icon(Icons.arrow_drop_down),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02),
                                          //Botón para agregar la categoría
                                          ReusableButton(
                                            onClick: () async {
                                              setState(() {
                                                isCtegoryUpdatingOrCreating =
                                                    true;
                                              });
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                //Si el formulario es válido, procedo a añadir la categoría
                                                //Recoger los datos
                                                String newCategoryName =
                                                    _newCategoryNameController
                                                        .text
                                                        .trim();
                                                //Crear la categoría --> el id es el nombre
                                                Category newCategory = Category(
                                                    categoryName:
                                                        newCategoryName,
                                                    categoryIsIncome: widget
                                                        .newCategoryIsIncome,
                                                    categoryColor:
                                                        categoryColorSelected);

                                                //Insertar la nueva categoría en la base de datos
                                                await CategoryDao().insertCategory(
                                                    context
                                                        .read<
                                                            ConfigurationProvider>()
                                                        .userRegistered!,
                                                    newCategory);
                                                //Borro lo escrito en el controller
                                                _newCategoryNameController
                                                    .clear();
                                                setState(() {
                                                  isCtegoryUpdatingOrCreating =
                                                      true;
                                                });
                                                //Cerrar el diálogo
                                                Navigator.of(context).pop();
                                                //añado la categoría a la lista de la interfaz
                                                setState(() {
                                                  categoriesList.add(
                                                      newCategory); //añado la nueva categoría a la UI
                                                  widget.listAllCategories.add(
                                                      newCategory); //añado la nueva categoría a la lista de todas las categorías para que se actualicen los colores
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
                                                            1), //duración del SnackBar
                                                  ),
                                                );
                                              }
                                              setState(() {
                                                isCtegoryUpdatingOrCreating =
                                                    false;
                                              });
                                            },
                                            colorButton: 'buttonWhiteBlack',
                                            textButton:
                                                isCtegoryUpdatingOrCreating
                                                    ? null
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .add,
                                            colorTextButton: 'buttonBlackWhite',
                                            buttonHeight: 0.075,
                                            buttonWidth: 0.3,
                                            colorBorderButton:
                                                'buttonBlackWhite',
                                            child: isCtegoryUpdatingOrCreating
                                                ? CircularProgressIndicator(
                                                    color: context
                                                            .watch<ThemeProvider>()
                                                            .palette()[
                                                        'textBlackWhite']!)
                                                : null,
                                          ),
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
                              title: Text(AppLocalizations.of(context)!
                                  .maxLimitExceeded),
                              content: Text(AppLocalizations.of(context)!
                                  .maxLimitExceededLabel),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                      AppLocalizations.of(context)!.accept),
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
          )),
      (categoriesList.isEmpty)
          ? SizedBox()
          : ListView.builder(
              shrinkWrap:
                  true, //Permite que la lista ocupe el espacio necesario
              physics:
                  const NeverScrollableScrollPhysics(), //Desactiva el scroll para que no se superponga con el scroll del dialog
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                var categoryPointer = categoriesList[index];
                return Card(
                  elevation: 0,
                  color: categoryPointer.categoryColor,
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.008,
                      horizontal: MediaQuery.of(context).size.width * 0.015),
                  child: ListTile(
                    onTap: () async {
                      //controlador con el nombre actual
                      TextEditingController editCategoryNameController =
                          TextEditingController(
                              text: categoryPointer.categoryName);
                      //color actual
                      Color updatedColor = categoryPointer.categoryColor;

                      //abrir diálogo para editar
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context
                                        .watch<ThemeProvider>()
                                        .palette()['backgroundDialog']!,
                                  ),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    child: Center(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(AppLocalizations.of(context)!
                                                .editCategory),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            ReusableTxtFormFieldShowDetailsTransactionAndEditCategory(
                                                text:
                                                    editCategoryNameController,
                                                labelText: AppLocalizations.of(
                                                        context)!
                                                    .changeCategoryName,
                                                readOnly: false,
                                                validator: (x) {
                                                  //no se pued edejar vacío
                                                  if (x == null || x.isEmpty) {
                                                    return AppLocalizations.of(
                                                            context)!
                                                        .newCategoryNameLabelError;
                                                  }
                                                  //no puede tener el mismo nombre que otra categoría ya existente
                                                  if (x !=
                                                          categoryPointer
                                                              .categoryName &&
                                                      checkNameUniqueness(
                                                          x.trim(),
                                                          widget
                                                              .listAllCategories)) {
                                                    return AppLocalizations.of(
                                                            context)!
                                                        .categoryNameAlreadyExists;
                                                  }
                                                  return null;
                                                }),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            SizedBox(
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .newCategoryColorTitle,
                                                            style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis)),
                                                        content: availableColors()
                                                                .isNotEmpty
                                                            ? SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.2,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      BlockPicker(
                                                                    pickerColor:
                                                                        categoryColorSelected =
                                                                            categoryPointer.categoryColor,
                                                                    availableColors:
                                                                        availableColors() +
                                                                            [
                                                                              categoryPointer.categoryColor
                                                                            ],
                                                                    onColorChanged:
                                                                        (Color
                                                                            color) {
                                                                      setStateDialog(
                                                                          () {
                                                                        updatedColor =
                                                                            color;
                                                                        categoryColorSelected =
                                                                            color;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                    vertical:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.02,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: context
                                                              .watch<
                                                                  ThemeProvider>()
                                                              .palette()[
                                                          'textBlackWhite']!,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: categoryColorSelected =
                                                              categoryPointer
                                                                  .categoryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .newCategoryColorLabel,
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis)),
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.01),
                                                      Icon(Icons
                                                          .arrow_drop_down),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            ReusableButton(
                                              onClick: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setStateDialog(() {
                                                    isCtegoryUpdatingOrCreating =
                                                        true;
                                                  });
                                                  //Si el formulario es válido, llevo a cabo la edición
                                                  String updatedName =
                                                      editCategoryNameController
                                                          .text;

                                                  if (updatedName.isNotEmpty) {
                                                    //crear nueva categoría con los datos actualizados
                                                    Category updatedCategory =
                                                        Category(
                                                      categoryName: updatedName,
                                                      categoryIsIncome:
                                                          categoryPointer
                                                              .categoryIsIncome,
                                                      categoryColor:
                                                          updatedColor,
                                                    );

                                                    //actualizar en la base de datos
                                                    await CategoryDao()
                                                        .updateCategory(
                                                      u: context
                                                          .read<
                                                              ConfigurationProvider>()
                                                          .userRegistered!,
                                                      oldCategory:
                                                          categoryPointer,
                                                      newCategory:
                                                          updatedCategory,
                                                    );

                                                    //actualizar en la UI
                                                    setState(() {
                                                      categoriesList[
                                                              index] =
                                                          updatedCategory;
                                                      //opcionalmente también actualizar listAllCategories si la usas
                                                      int allIndex = widget
                                                          .listAllCategories
                                                          .indexWhere(
                                                        (cat) =>
                                                            cat.categoryName ==
                                                            categoryPointer
                                                                .categoryName,
                                                      );
                                                      if (allIndex != -1) {
                                                        widget.listAllCategories[
                                                                allIndex] =
                                                            updatedCategory;
                                                      }
                                                    });

                                                    Navigator.of(context)
                                                        .pop(); //cerrar el diálogo
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .correctEditingCategory),
                                                        duration: Duration(
                                                            seconds: 1),
                                                      ),
                                                    );
                                                  }
                                                }
                                                setStateDialog(() {
                                                  isCtegoryUpdatingOrCreating =
                                                      false;
                                                });
                                              },
                                              colorButton: 'buttonWhiteBlack',
                                              textButton:
                                                  isCtegoryUpdatingOrCreating
                                                      ? null
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .saveChanges,
                                              colorTextButton:
                                                  'buttonBlackWhite',
                                              buttonHeight: 0.075,
                                              buttonWidth: 0.3,
                                              colorBorderButton:
                                                  'buttonBlackWhite',
                                              child: isCtegoryUpdatingOrCreating
                                                  ? CircularProgressIndicator(
                                                      color: context
                                                              .watch<
                                                                  ThemeProvider>()
                                                              .palette()[
                                                          'textBlackWhite']!)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    contentPadding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    title: Text(
                      categoryPointer.categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context
                            .watch<ThemeProvider>()
                            .palette()['fixedBlack']!,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color: context
                              .watch<ThemeProvider>()
                              .palette()['fixedBlack']!),
                      iconSize: MediaQuery.of(context).size.width * 0.1,
                      onPressed: () async {
                        //SOLO QUIERO QUE SE BORRE LA CATEGORÍA SI LA LISTA DE INGRESOS/GASTOS NO ES INFERIOR A 1. ES DECIR QUE SI SOLO HAY UNA CATEGORÍA Y SE QUIERE ELIMINAR QUE NO SE PUEDA
                        bool canDelete =
                            true; //comprueba si se permite la eliminación o no
                        //comprueba de que tipo de categoría es (ingreso o gasto) y mira ela longitud de la lista --> si es superior a 1 no hay problema, sino muetsro Scaffold con mensaje
                        if (categoryPointer.categoryIsIncome) {
                          canDelete = categoriesList
                                  .where((cat) => cat.categoryIsIncome)
                                  .length >
                              1;
                        } else {
                          canDelete = categoriesList
                                  .where((cat) => !cat.categoryIsIncome)
                                  .length >
                              1;
                        }

                        if (canDelete) {
                          //llamo al método del DAO para eliminar la categoría de Firestore
                          await CategoryDao().deleteCategory(
                            context
                                .read<ConfigurationProvider>()
                                .userRegistered!,
                            categoryPointer,
                          );
                          //muestro un mensaje de confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .correctCategoryDeleting),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          //elimino la categoría también de la lista local
                          setState(() {
                            categoriesList.removeAt(index);
                          });
                        } else {
                          //Si no se puede eliminar, mostrar mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .cannotDeleteCategory),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            )
    ]);
  }

  //Comprobar si el nombre de la categoría ya existe, ya que el nombre d ela categoría en FireBase es el id
  bool checkNameUniqueness(String cname, List categorieslist) {
    return (categorieslist
        .where((c) => c.categoryName.toLowerCase() == cname.toLowerCase())
        .isNotEmpty);
  }
}
