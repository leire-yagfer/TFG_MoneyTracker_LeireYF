import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2eva_budget/view/estadisticas/resumen_balance.dart';
import 'package:proyecto2eva_budget/view/estadisticas/resumen_gastos.dart';
import 'package:proyecto2eva_budget/view/estadisticas/resumen_ingresos.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:proyecto2eva_budget/viewmodel/themeprovider.dart';

///Clase que contiene tres pestañas en las que se ve las estadísticas de ingresos, gastos y balance
class Estadisticas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: context.watch<ThemeProvider>().palette()['selectedItem']!,
            labelColor: context.watch<ThemeProvider>().palette()['selectedItem']!,
            unselectedLabelColor: context.watch<ThemeProvider>().palette()['unselectedItem']!,
            tabs: [
              Tab(icon: const Icon(Icons.attach_money), text: AppLocalizations.of(context)!.income),
              Tab(icon: Icon(Icons.pie_chart), text: AppLocalizations.of(context)!.expenses),
              Tab(icon: Icon(Icons.balance), text: AppLocalizations.of(context)!.balance),
            ],
          ),
        ),
        body: const TabBarView(
          children: [IngresosTab(), GastosTab(),BalanceTab()],
        ),
      ),
      
    );
  }
}
