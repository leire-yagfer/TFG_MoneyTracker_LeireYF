import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2eva_budget/model/models/categoria.dart';
import 'package:proyecto2eva_budget/viewmodel/themeprovider.dart';

///Clase reutilizable para mostrar todas las actegorías en función del tipo
class CategoryCard extends StatelessWidget {
  final String
      title; //Título que se muestra arriba de la lista -> Ingresos/Gastos
  final List<Categoria> categorias; //Lista de categorías a mostrar
  
  final IconData Function(String)
      categoryIcon; //Función para obtener el icono de la categoría

  const CategoryCard({
    Key? key,
    required this.title,
    required this.categorias,
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            var categoria = categorias[index];
            return Card(
              color: categoria.colorCategoria,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.008,
                  horizontal: MediaQuery.of(context).size.width * 0.015),
              child: ListTile(
                contentPadding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                title: Text(
                  categoria.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        context.watch<ThemeProvider>().palette()['fixedBlack']!,
                  ),
                ),
                trailing: Icon(
                  categoryIcon(categoria.icono),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
