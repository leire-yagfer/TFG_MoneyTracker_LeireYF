import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/reusable/categorycard.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';

///Clase que muestra las categorías almacenadas en la base de datos de cada usuario separadas pòr ingresos y gastos
class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categorias = [];
  CategoryDao categoriaDao = CategoryDao();

  @override
  void initState() {
    super.initState();
    _cargarCategorias(); //Cargar categorías
  }

  ///Método para cargar las categorías desde la base de datos
  Future<void> _cargarCategorias() async {
    List<Category> categoriasDB = await categoriaDao.getCategories(context
        .read<ProviderAjustes>()
        .usuario!); //Obtiene las categorías del usuario actual
    //Se ordenan las categorías por tipo (ingreso o gasto)
    categoriasDB.sort((a, b) {
      if (a.categoryIsIncome && !b.categoryIsIncome) {
        return -1; // a es ingreso y b es gasto
      } else if (!a.categoryIsIncome && b.categoryIsIncome) {
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
    List<Category> ingresos =
        categorias.where((categoria) => categoria.categoryIsIncome).toList();
    List<Category> gastos =
        categorias.where((categoria) => !categoria.categoryIsIncome).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (ingresos.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.income,
                categoriesList: ingresos,
                categoryIcon: obtenerIcono,
              ),
            if (gastos.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.expenses,
                categoriesList: gastos,
                categoryIcon: obtenerIcono,
              ),
          ],
        ),
      ),
    );
  }
}
