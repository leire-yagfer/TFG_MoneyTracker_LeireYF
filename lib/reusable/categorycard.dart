import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase reutilizable para mostrar todas las actegorías en su pantalla en función del tipo para dividirlas en ingreso y gasto
class CategoryCard extends StatelessWidget {
  final String
      title; //Título que se muestra arriba de la lista -> Ingresos/Gastos
  final List<Category> categoriesList; //Lista de categorías a mostrar
  
  final IconData Function(String)
      categoryIcon; //Función para obtener el icono de la categoría

  const CategoryCard({
    Key? key,
    required this.title,
    required this.categoriesList,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              fontWeight: FontWeight.w600),
        ),
        ListView.builder(
          shrinkWrap: true, //Permite que la lista ocupe el espacio necesario
          physics: const NeverScrollableScrollPhysics(), //Desactiva el scroll para que no se superponga con el scroll del dialog
          itemCount: categoriesList.length,
          itemBuilder: (context, index) {
            var categoryPointer = categoriesList[index];
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
                  categoryIcon(categoryPointer.categoryIcon),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
