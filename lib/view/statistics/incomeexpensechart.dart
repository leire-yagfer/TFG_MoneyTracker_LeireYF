import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Gráfico circular ara ingresos/gastos
class IncomeExpenseChart extends StatelessWidget {
  final Map<String, List<double>> dataMap;
  final Map<String, Color> colorMap;

  const IncomeExpenseChart({
    super.key,
    required this.dataMap,
    required this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSecondaryCurrencyInUse =
        context.read<ConfigurationProvider>().switchUseSecondCurrency;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: PieChart(
                PieChartData(
                  //tiene el número de secciones igual al número de categorías
                  sections: dataMap.entries.map((categoryPointer) {
                    return PieChartSectionData(
                      value: categoryPointer.value[
                          0], //claculo el valor de la representación d ela categoría con la moneda prinicpal
                      title: !isSecondaryCurrencyInUse
                          ? "${categoryPointer.value[0].toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol}"
                          : "${categoryPointer.value[0].toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol} \n ${categoryPointer.value[1].toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}",
                      color: colorMap[categoryPointer.key],
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        fontWeight: FontWeight.w600,
                        color: context
                            .watch<ThemeProvider>()
                            .palette()['textBlackGrey']!,
                      ),
                    );
                  }).toList(),
                ),
              ),
            )),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        //Leyenda
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width *
                  0.1), // margen lateral para que no se aproxime al margen la leyenda
          child: Wrap(
            spacing: MediaQuery.of(context).size.height *
                0.02, //espacio horizontal entre las categorías
            //saco el nombre de las categorías que se encuentran en la clave del mapa
            children: dataMap.keys.map((categoryName) {
              //cada fila representa una categoría con su color y nombre
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.015,
                    height: MediaQuery.of(context).size.height * 0.015,
                    color: colorMap[categoryName],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.005),
                  Text(
                    categoryName,
                  ),
                ],
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
