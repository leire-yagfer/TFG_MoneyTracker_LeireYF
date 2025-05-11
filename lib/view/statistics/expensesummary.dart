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
  final TransactionDao transaccionDao = TransactionDao();
  Map<String, double> dataMap = {}; //Almacena las categorías
  Map<String, Color> colorMap = {}; //Almacena los colores de las categorías
  String? selectedYear; //Almacena el año seleccionado en el DropDownButton
  String selectedFilter =
      'all'; //Filtro por defecto -> se muestra el resumen de todos los movimeintos

  @override
  void initState() {
    super.initState();
    _cargarDatos(); //Cargo los datos según se inicia la pantalla
  }

  ///Cargar los datos desde la base de datos por filtros -> o mostrar todos o por año (seleccionado en un DropDownButton)
  Future<void> _cargarDatos() async {
    if (selectedFilter == 'year' && selectedYear == null) {
      return;
    }

    final result = await transaccionDao.obtenerIngresosGastosPorCategoria(
      filter: selectedFilter,
      year: selectedYear,
      u: context.read<ProviderAjustes>().usuario!,
      actualCode: context.read<ProviderAjustes>().divisaEnUso.currencyCode,
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
      dataMap = tempData;
      colorMap = tempColor;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  _cargarDatos();
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
                  _cargarDatos();
                },
              ),
              Text(AppLocalizations.of(context)!.year),
            ],
          ),
          if (selectedFilter == 'year') _buildYearPicker(),
          dataMap.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.05),
                  child: Text(
                    AppLocalizations.of(context)!.noTransactions,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaler.scale(30),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(
                  child: ExpenseChart(dataMap: dataMap, colorMap: colorMap),
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
        _cargarDatos();
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
                      "${entry.key}\n${entry.value.toStringAsFixed(2)} ${context.read<ProviderAjustes>().divisaEnUso.currencySymbol}",
                  color: colorMap[entry.key],
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(30),
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
          children: dataMap.keys.map((categoria) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.height * 0.015,
                  height: MediaQuery.of(context).size.height * 0.015,
                  color: colorMap[categoria],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Text(
                  categoria,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
