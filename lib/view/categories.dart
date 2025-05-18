import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/staticdata.dart';
import 'package:tfg_monetracker_leireyafer/reusable/categorycard.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablecircleprogressindicator.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';

///Clase que muestra las categorías almacenadas en la base de datos de cada usuario separadas pòr ingresos y gastos
class CategoriesPage extends StatefulWidget {
  @override
  //Key? key = GlobalKey<CategoriesPageState>(); --> HACER _CategoriesPageState PÚBLICO SI SE DESCOMENTA

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categorias = [];
  CategoryDao categoriaDao = CategoryDao();

  List<Category> listIncomes = [];
  List<Category> listExpenses = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    cargarCategorias(); //Cargar categorías
  }

  ///Método para cargar las categoríaspor tipo desde la base de datos
  Future<void> cargarCategorias() async {
    setState(() {
      _isLoading = true;
    });

    final user = context.read<ConfigurationProvider>().userRegistered!;

    //Obtengo las categorías de tipo ingreso (type = true)
    List<Category> incomes = await categoriaDao.getCategoriesByType(user, true);

    //Obtengo las categorías de tipo gasto (type = false)
    List<Category> expenses =
        await categoriaDao.getCategoriesByType(user, false);

    //actualizo el estado con las listas ya ordenadas y filtradas
    setState(() {
      listIncomes = incomes;
      listExpenses = expenses;
      _isLoading = false;
    });

    
  }

  @override
  Widget build(BuildContext context) {
    //Se separan las categorías en dos listas: una para ingresos y otra para gastos

    return _isLoading
        ? ReusableCircleProgressIndicator(text: AppLocalizations.of(context)!.loadingCategories)  
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (listIncomes.isNotEmpty)
                    CategoryCard(
                      title: AppLocalizations.of(context)!.income,
                      categoriesList: listIncomes,
                      newCategoryIsIncome: true,
                      categoriesColorMap: StaticData
                          .incomeCategoriesColorMap, //paso la clase de colores disponibles para las categorías de tipo ingreso
                      listAllCategories: listExpenses + listIncomes,
                    ),
                  if (listExpenses.isNotEmpty)
                    CategoryCard(
                      title: AppLocalizations.of(context)!.expenses,
                      categoriesList: listExpenses,
                      newCategoryIsIncome: false,
                      categoriesColorMap: StaticData
                          .expenseCategoriesColorMap, //paso la clase de colores disponibles para las categorías de tipo gasto
                      listAllCategories: listExpenses + listIncomes,
                    ),
                ],
              ),
            ),
          );
  }
}
