import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2eva_budget/model/models/dao/categoriadao.dart';
import 'package:proyecto2eva_budget/reusable/categorycard.dart';
import 'package:proyecto2eva_budget/viewmodel/provider_ajustes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:proyecto2eva_budget/model/models/categoria.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///Clase que muestra las categorías almacenadas en la base de datos de cada usuario separadas pòr ingresos y gastos
class Categorias extends StatefulWidget {
  @override
  _CategoriasState createState() => _CategoriasState();
}

class _CategoriasState extends State<Categorias> {
  late Database db;
  List<Categoria> categorias = [];
  CategoriaDao categoriaDao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    _cargarCategorias(); //Cargar categorías
  }

  ///Método para cargar las categorías desde la base de datos
  Future<void> _cargarCategorias() async {
    List<Categoria> categoriasDB = await categoriaDao.obtenerCategorias(context
        .read<ProviderAjustes>()
        .usuario!); //Obtiene las categorías del usuario actual
    //Se ordenan las categorías por tipo (ingreso o gasto)
    categoriasDB.sort((a, b) {
      if (a.esingreso && !b.esingreso) {
        return -1; // a es ingreso y b es gasto
      } else if (!a.esingreso && b.esingreso) {
        return 1; // a es gasto y b es ingreso
      } else {
        return 0; // ambos son ingresos o ambos son gastos
      }
    });
    setState(() {
      categorias = categoriasDB; //Actualiza la lista con los objetos Categoria
    });
  }

  ///Método para obtener el icono correspondiente según el nombre del icono -> alamcenado en la BD con nombre concretos de iconos accesibles
  IconData obtenerIcono(String iconName) {
    switch (iconName) {
      //GASTOS
      case 'house':
        return Icons.house;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'directions_car':
        return Icons.directions_car;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'book':
        return Icons.book;

      //INGRESOS
      case 'money':
        return Icons.money;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.help_outline; //Icono por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    //Se separan las categorías en dos listas: una para ingresos y otra para gastos
    List<Categoria> ingresos =
        categorias.where((categoria) => categoria.esingreso).toList();
    List<Categoria> gastos =
        categorias.where((categoria) => !categoria.esingreso).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (ingresos.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.income,
                categorias: ingresos,
                categoryIcon: obtenerIcono,
              ),
            if (gastos.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.expenses,
                categorias: gastos,
                categoryIcon: obtenerIcono,
              ),
          ],
        ),
      ),
    );
  }
}
