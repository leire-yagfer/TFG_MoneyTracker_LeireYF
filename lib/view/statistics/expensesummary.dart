import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que muestra los movimientos cuyo tipo es gastos en la base de datos en un gráfico circular divido con los colores de las categorías a las que pertenece
class ExpenseTab extends StatefulWidget {
  const ExpenseTab({super.key});

  @override
  _ExpenseTabState createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  final TransactionDao transactionDao = TransactionDao();
  Map<String, double> categoryTotalMap =
      {}; //Almacena las categorías como clave y como valor el total por categoría
  Map<String, Color> categoryColorMap =
      {}; //Almacena los colores de las categorías, como clave la categoría y como valor el color
  String? selectedYear; //Almacena el año seleccionado en el DropDownButton
  String selectedFilter =
      'all'; //Filtro por defecto -> se muestra el resumen de todos los movimeintos

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData(); //Cargo los datos según se inicia la pantalla
  }

  ///Cargar los datos desde la base de datos por filtros -> o mostrar todos o por año (seleccionado en un DropDownButton)
  Future<void> _loadData() async {
    if (selectedFilter == 'year' && selectedYear == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await transactionDao.getIncomeExpensesByCategory(
      filter: selectedFilter,
      year: selectedYear,
      u: context.read<ConfigurationProvider>().userRegistered!,
      actualCode:
          context.read<ConfigurationProvider>().currencyCodeInUse.currencyCode,
      isIncome: false,
    );

    Map<String, double> tempData = {};
    Map<String, Color> tempColor = {};

    for (var row in result.entries) {
      String categoria = row.key.categoryName;
      double total = 0;
      row.value.forEach((transaccion) {
        total += transaccion.transactionImport;
      });
      Color color = row.key.categoryColor;

      tempData[categoria] = total;
      tempColor[categoria] = color;
    }

    setState(() {
      categoryTotalMap = tempData;
      categoryColorMap = tempColor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Compruebo si todos los valores de las transacciones de las categorías es 0 para mostrar que no hay transacciones
    bool allZero = categoryTotalMap.values.every((value) => value == 0);

    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Cargando datos"),
              ],
            ),
          )
        : (allZero || categoryTotalMap.isEmpty)
            ? Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.05),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noTransactions,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaler.scale(30),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //Filtros (ubicados en la parte superior)
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'all',
                          groupValue: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                              selectedYear = null;
                            });
                            _loadData();
                          },
                        ),
                        Text(AppLocalizations.of(context)!.all),
                        Radio<String>(
                          value: 'year',
                          groupValue: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                            });
                            _loadData();
                          },
                        ),
                        Text(AppLocalizations.of(context)!.year),
                      ],
                    ),
                    if (selectedFilter == 'year') _buildYearPicker(),
                    SizedBox(
                      child: ExpenseChart(
                        dataMap: categoryTotalMap,
                        colorMap: categoryColorMap,
                      ),
                    ),
                  ],
                ),
              );
  }

  ///Construir el selector de año
  Widget _buildYearPicker() {
    return DropdownButton<String>(
      hint: Text(AppLocalizations.of(context)!.yearHint),
      value: selectedYear,
      items: List.generate(5, (index) {
        int year = DateTime.now().year - index;
        return DropdownMenuItem(
          value: year.toString(),
          child: Text(year.toString()),
        );
      }),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
        });
        _loadData();
      },
    );
  }
}

///Gráfico circular de transacciones de tipo gastos
class ExpenseChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final Map<String, Color> colorMap;

  const ExpenseChart({
    super.key,
    required this.dataMap,
    required this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: PieChart(
            PieChartData(
              sections: dataMap.entries.map((entry) {
                return PieChartSectionData(
                  value: entry.value,
                  title:
                      "${entry.value.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol}",
                  color: colorMap[entry.key],
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600,
                    color:
                        context.watch<ThemeProvider>().palette()['fixedBlack']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Wrap(
          spacing: MediaQuery.of(context).size.width * 0.02,
          children: dataMap.keys.map((category) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.height * 0.015,
                  height: MediaQuery.of(context).size.height * 0.015,
                  color: colorMap[category],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Text(
                  category,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
