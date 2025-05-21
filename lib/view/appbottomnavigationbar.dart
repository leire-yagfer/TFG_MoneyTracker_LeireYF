// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/view/categories.dart';
import 'package:tfg_monetracker_leireyafer/view/configuration.dart';
import 'package:tfg_monetracker_leireyafer/view/home.dart';
import 'package:tfg_monetracker_leireyafer/view/statistics/statistics.dart';
import 'package:tfg_monetracker_leireyafer/view/transactions.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que define la distribución de la app con el bottomNavigation y con la barra de navegación
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  //Lista de pantallas para la barra de navegación
  final List<Widget> _screens = [
    HomePage(),
    TransactionsPage(),
    StatisticsPage(),
    CategoriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency:
            true, //evita que se cambie de color del appBar cuando s ehace scroll
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: TextStyle(
            fontSize: MediaQuery.of(context).textScaler.scale(26),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          //Botón para acceder a la página de ajustes
          IconButton(
            icon: Icon(
              Icons.settings,
              color:
                  context.watch<ThemeProvider>().palette()['buttonBlackWhite']!,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfigurationPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: context
            .watch<ThemeProvider>()
            .palette()['selectedItem']!, //Color del ítem seleccionado
        unselectedItemColor: context
            .watch<ThemeProvider>()
            .palette()['unselectedItem']!, //Color de los ítems no seleccionados
        backgroundColor: Theme.of(context)
            .bottomNavigationBarTheme
            .backgroundColor, //Color de fondo de la barra de navegación
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.home), //Pantalla principal
          BottomNavigationBarItem(
              icon: const Icon(Icons.swap_horiz),
              label: AppLocalizations.of(context)!
                  .movements), //Pantalla de movimientos
          BottomNavigationBarItem(
              icon: Icon(Icons.equalizer),
              label: AppLocalizations.of(context)!
                  .stadistics), //Pantalla de estadísticas
          BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: AppLocalizations.of(context)!
                  .categories), //Pantalla de categorías
        ],
      ),
    );
  }
}
