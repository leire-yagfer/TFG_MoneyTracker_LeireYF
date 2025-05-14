// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase reutilizable para mostrar todas las actegorías en su pantalla en función del tipo para dividirlas en ingreso y gasto
class CategoryCard extends StatefulWidget {
  String title; //Título que se muestra arriba de la lista -> Ingresos/Gastos
  List<Category> categoriesList; //Lista de categorías a mostrar

  Map<String, IconData>
      categoryMap; //Función para obtener el icono de la categoría

  //Constructor de la clase
  CategoryCard({
    required this.title,
    required this.categoriesList,
    required this.categoryMap,
  });
  @override
  State<StatefulWidget> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late Map<String, IconData>
      categoryMap; //Función para obtener el icono de la categoría
  final _formKey = GlobalKey<FormState>();

  late Map<String, Color> colorMap;
  Color colorPicker = Colors.red; //Color por defecto del color picker
  late Color
      categoryColorSelected; //Color seleccionado por el usuario para la categoría

  //crear una variable que va a almacenar el mapa de los iconos de las categorías, y voy a eliminar de la variable (mapa2) aquellos elementos que ya estén en uso
  @override
  void initState() {
    super.initState();
    setState(() {
      categoryMap = widget.categoryMap;
    });
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
            IconButton(
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
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01),
                          child: Center(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Nombre de la categoría',
                                    ),
                                  ),

                                  //mostrar un dropdown con los iconos disponibles de la lista creada en la clase staticdata
                                  DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Icono de la categoría',
                                      hintText: 'Seleccione un icono',
                                    ),
                                    //mostrar los iconos que no estén ya en uso
                                    items: categoryMap
                                        .keys.skipWhile((iconInUse){ //si se cumple la condición, se "salta" el elemnto de la lista
                                          return widget.categoriesList.map((e)=>e.categoryIcon).contains(iconInUse); //lambda que devuelve un boolean --> si se cumple que está se lsalta, sino se mantiene
                                        }) //acceder a las claves pq es lo que me da el icono y lo que guardo en la BD
                                        .map((categoryKeyMap) =>
                                            DropdownMenuItem(
                                                value: categoryKeyMap,
                                                child: Icon(categoryMap[
                                                    categoryKeyMap])))
                                        .toList(), //accedo al valor del mapa a través de su nombre pq Icon(almacena el valor)
                                    onChanged: (value) {
                                      //Lógica para seleccionar el icono
                                    },
                                  ),
/*
                                  //color picker para seleccionar el color de la categoría
                                  DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Color de la categoría',
                                      hintText:
                                          'Seleccione un color',
                                    ),
                                    items: categoryMap.keys //acceder a las claves pq es lo que me da el icono y lo que guardo en la BD
                                        .map((categoryKeyMap) => DropdownMenuItem(
                                              value: categoryKeyMap,
                                              child: Icon(categoryMap[categoryKeyMap]))).toList(), //accedo al valor del mapa a través de su nombre pq Icon(almacena el valor)
                                    onChanged: (value) {
                                      //Lógica para seleccionar el icono
                                    },
                                  ),*/
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
            ),
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
                trailing: Icon(
                  categoryMap[(categoryPointer.categoryIcon)],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
