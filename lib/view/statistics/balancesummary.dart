// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/transactiondao.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablecircleprogressindicator.dart';
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
  double totalIncome = 0;
  double totalIncomeSecondaryCurrency = 0;
  double totalExpense = 0;
  double totalExpenseSecondaryCurrency = 0;
  String? selectedYear;
  String selectedFilter = 'all';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadData(); //Cargo los datos según se inicia la pantalla
    //escucho cambios en la configuración para detectar cuando se cambia la moneda
    context.read<ConfigurationProvider>().addListener(_onConfigurationChanged);
  }

  //función que se ejecuta automáticamente al cambiar la configuración, tras haberle añadido el listener
  void _onConfigurationChanged() {
    _loadData(); //recargo las transacciones con la nueva moneda
  }

  @override
  void dispose() {
    context
        .read<ConfigurationProvider>()
        .removeListener(_onConfigurationChanged);
    super.dispose();
  }

  ///Cargar los datos desde la base de datos
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final totalIncomeResult = await transaccionDao.getTotalByType(
      isIncome: true,
      u: context.read<ConfigurationProvider>().userRegistered!,
      filter: selectedFilter,
      year: selectedYear,
      actualCurrency:
          context.read<ConfigurationProvider>().currencyCodeInUse.currencyCode,
    );
    final totalExpenseResult = await transaccionDao.getTotalByType(
      isIncome: false,
      u: context.read<ConfigurationProvider>().userRegistered!,
      filter: selectedFilter,
      year: selectedYear,
      actualCurrency:
          context.read<ConfigurationProvider>().currencyCodeInUse.currencyCode,
    );
    if (context.read<ConfigurationProvider>().switchUseSecondCurrency) {
      final totalIncomeSecondaryCurrencRes =
          await transaccionDao.getTotalByType(
        isIncome: true,
        u: context.read<ConfigurationProvider>().userRegistered!,
        filter: selectedFilter,
        year: selectedYear,
        actualCurrency: context
            .read<ConfigurationProvider>()
            .currencyCodeInUse2
            .currencyCode,
      );
      final totalExpenseSecondaryCurrencyRes =
          await transaccionDao.getTotalByType(
        isIncome: false,
        u: context.read<ConfigurationProvider>().userRegistered!,
        filter: selectedFilter,
        year: selectedYear,
        actualCurrency: context
            .read<ConfigurationProvider>()
            .currencyCodeInUse2
            .currencyCode,
      );
      setState(() {
        totalIncomeSecondaryCurrency = totalIncomeSecondaryCurrencRes;
        totalExpenseSecondaryCurrency = totalExpenseSecondaryCurrencyRes;
      });
    }

    setState(() {
      totalIncome = totalIncomeResult; //Actualizo el total de ingresos
      totalExpense = totalExpenseResult; //Actualizo el total de gastos

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Evito que la gráfica desaparezca si los valores son 0
    double showIncome = totalIncome; //> 0 ? totalIncome : 0.01;
    double showExpense = totalExpense; //> 0 ? totalExpense : 0.01;

    double showIncomeSecondaryCurrency = totalIncomeSecondaryCurrency;
    double showExpenseSecondaryCurrency = totalExpenseSecondaryCurrency;

    //Compruebo si todos los valores de las transacciones de las categorías es 0 para mostrar que no hay transacciones
    bool allZero = showExpense == 0 && showIncome == 0;

    //balance final
    double balance = showIncome - showExpense;

    double balanceSecondCurrency =
        showIncomeSecondaryCurrency - showExpenseSecondaryCurrency;

    return _isLoading
        ? ReusableCircleProgressIndicator(
            text: AppLocalizations.of(context)!.loadingData)
        : SingleChildScrollView(
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  allZero
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.05),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.noTransactions,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).textScaler.scale(30),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : //Gráfica circular --> no está en un método pq es única
                      Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.05),
                                  child: PieChart(
                                    PieChartData(
                                      //Solo cuenta con dos secciones: Ingresos y Gastos
                                      sections: [
                                        PieChartSectionData(
                                          value: showIncome,
                                          title: (context
                                                  .read<ConfigurationProvider>()
                                                  .switchUseSecondCurrency)
                                              ? "${totalIncome.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol} \n ${totalIncomeSecondaryCurrency.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}"
                                              : "${totalIncome.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol}",
                                          color: context
                                              .watch<ThemeProvider>()
                                              .palette()['greenButton']!,
                                          radius: 80, //ancho de la línea
                                          titleStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .textScaler
                                                .scale(16),
                                            fontWeight: FontWeight.w600,
                                            color: context
                                                .watch<ThemeProvider>()
                                                .palette()['textBlackWhite']!,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: showExpense,
                                          title: (context
                                                  .read<ConfigurationProvider>()
                                                  .switchUseSecondCurrency)
                                              ? "${totalExpense.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol} \n ${totalExpenseSecondaryCurrency.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}"
                                              : "${totalExpense.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol}",
                                          color: context
                                              .watch<ThemeProvider>()
                                              .palette()['redButton']!,
                                          radius: 80,
                                          titleStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .textScaler
                                                .scale(16),
                                            fontWeight: FontWeight.w600,
                                            color: context
                                                .watch<ThemeProvider>()
                                                .palette()['textBlackWhite']!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.025),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: context
                                      .watch<ThemeProvider>()
                                      .palette()['scaffoldBackground']!,
                                  border: Border.all(
                                    color: context
                                        .watch<ThemeProvider>()
                                        .palette()['textBlackWhite']!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          "${AppLocalizations.of(context)!.balance}: ",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                  .textScaler
                                                  .scale(20),
                                              fontWeight: FontWeight.w600,
                                              color: balance < 0
                                                  ? context
                                                      .watch<ThemeProvider>()
                                                      .palette()['redButton']!
                                                  : context
                                                          .watch<ThemeProvider>()
                                                          .palette()[
                                                      'greenButton']!)),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05),
                                      (context
                                              .read<ConfigurationProvider>()
                                              .switchUseSecondCurrency)
                                          ? Text((balance < 0 && balanceSecondCurrency < 0) ? "${balance.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol} \n ${balanceSecondCurrency.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}" : "+${balance.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol} \n +${balanceSecondCurrency.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse2.currencySymbol}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context)
                                                      .textScaler
                                                      .scale(20),
                                                  fontWeight: FontWeight.w600,
                                                  color: balance < 0
                                                      ? context.watch<ThemeProvider>().palette()[
                                                          'redButton']!
                                                      : context.watch<ThemeProvider>().palette()[
                                                          'greenButton']!))
                                          : Text("${balance.toStringAsFixed(2)} ${context.read<ConfigurationProvider>().currencyCodeInUse.currencySymbol}",
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context)
                                                      .textScaler
                                                      .scale(20),
                                                  fontWeight: FontWeight.w600,
                                                  color: balance < 0
                                                      ? context
                                                          .watch<ThemeProvider>()
                                                          .palette()['redButton']!
                                                      : context.watch<ThemeProvider>().palette()['greenButton']!))
                                    ])),

                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            // Leyenda --> diferente a las otras porque solo cuenta con dos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                    AppLocalizations.of(context)!.income,
                                    context
                                        .watch<ThemeProvider>()
                                        .palette()['greenButton']!),
                                SizedBox(
                                    width: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildLegendItem(
                                    AppLocalizations.of(context)!.expenses,
                                    context
                                        .watch<ThemeProvider>()
                                        .palette()['redButton']!),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                          ],
                        ),
                ])),
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

  ///Método para generar los elementos de leyenda porque hay más de una leyenda
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
