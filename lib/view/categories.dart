import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/staticdata.dart';
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

  @override
  Widget build(BuildContext context) {
    //Se separan las categorías en dos listas: una para ingresos y otra para gastos
    List<Category> listIncomes =
        categorias.where((categoria) => categoria.categoryIsIncome).toList();
    List<Category> listExpenses =
        categorias.where((categoria) => !categoria.categoryIsIncome).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (listIncomes.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.income,
                categoriesList: listIncomes,
                categoryMap: StaticData.incomeIcon,
              ),
            if (listExpenses.isNotEmpty)
              CategoryCard(
                title: AppLocalizations.of(context)!.expenses,
                categoriesList: listExpenses,
                categoryMap: StaticData.expenseIcon,
              ),
          ],
        ),
      ),
    );
  }
}