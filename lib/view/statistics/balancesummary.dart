import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que muestra el balance entre ingresos y gastos en un gráfico circular
class BalanceTab extends StatefulWidget {
  const BalanceTab({super.key});

  @override
  _BalanceTabState createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab> {
  final TransactionDao transaccionDao = TransactionDao();
  double ingresos = 0;
  double gastos = 0;
  String? selectedYear;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    if(mounted){
    _cargarDatos(); //Cargo los datos según se inicia la pantalla
    }
  }
  ///Cargar los datos desde la base de datos
  Future<void> _cargarDatos() async {
    final ingresosResult = await transaccionDao.obtenerTotalPorTipo(
      isIncome: true,
      u: context.read<ProviderAjustes>().usuario!,
      filter: selectedFilter,
      year: selectedYear,
      //actualCode: context.read<ProviderAjustes>().divisaEnUso.codigo_divisa,
    );
    final gastosResult = await transaccionDao.obtenerTotalPorTipo(
      isIncome: false,
      u: context.read<ProviderAjustes>().usuario!,
      filter: selectedFilter,
      year: selectedYear,
      //actualCode: context.read<ProviderAjustes>().divisaEnUso.codigo_divisa,
    );

    setState(() {
      ingresos = ingresosResult; //Actualizo el total de ingresos
      gastos = gastosResult; //Actualizo el total de gastos
    });
  }

  @override
  Widget build(BuildContext context) {
    //Evita que la gráfica desaparezca si los valores son 0
    double ingresosMostrar = ingresos > 0 ? ingresos : 0.01;
    double gastosMostrar = gastos > 0 ? gastos : 0.01;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Filtros (ubicados en la parte superior)
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
            SizedBox(height: 20),
            //Gráfica circular
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: ingresosMostrar,
                      title: "${ingresos.toStringAsFixed(2)} ${context.read<ProviderAjustes>().divisaEnUso.currencySymbol}",
                      color: context
                          .watch<ThemeProvider>()
                          .palette()['greenButton']!,
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        fontWeight: FontWeight.w600,
                        color: context
                            .watch<ThemeProvider>()
                            .palette()['fixedBlack']!,
                      ),
                    ),
                    PieChartSectionData(
                      value: gastosMostrar,
                      title: "${gastos.toStringAsFixed(2)} ${context.read<ProviderAjustes>().divisaEnUso.currencySymbol}",
                      color: context
                          .watch<ThemeProvider>()
                          .palette()['redButton']!,
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        fontWeight: FontWeight.w600,
                        color: context
                            .watch<ThemeProvider>()
                            .palette()['fixedBlack']!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppLocalizations.of(context)!.income,
                    context.watch<ThemeProvider>().palette()['greenButton']!),
                SizedBox(width: MediaQuery.of(context).size.height * 0.02),
                _buildLegendItem(AppLocalizations.of(context)!.expenses,
                    context.watch<ThemeProvider>().palette()['redButton']!),
              ],
            ),
          ],
        ),
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

  ///Método para generar los elementos de leyenda
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.015,
          height: MediaQuery.of(context).size.height * 0.015,
          color: color,
        ),
        SizedBox(width: MediaQuery.of(context).size.height * 0.005),
        Text(label),
      ],
    );
  }
}
