// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/util/changecurrencyapi.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

//Clase que define la distribución de la app
class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage>
    with LoginLogoutDialog {
  @override
  Widget build(BuildContext context) {
    //Instancia de la clase ProviderAjustes que contiene los ajustes de la app
    final ajustesProvider = Provider.of<ConfigurationProvider>(
        context); //Obtener los ajustes actuales
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'MONEYTRACKER',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: MediaQuery.of(context).size.height *
                        0.1), //margen exterior
                child: Column(children: [
                  Text(
                    context
                        .watch<ConfigurationProvider>()
                        .userRegistered!
                        .userEmail,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(18),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Table(
                    border: TableBorder.all(
                        color: context
                            .watch<ThemeProvider>()
                            .palette()['buttonBlackWhite']!),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          //Botón para cambiar entre modo oscuro y modo claro
                          Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.05),
                            child: Row(children: [
                              Text(context
                                      .watch<ThemeProvider>()
                                      .isLightModeActive
                                  ? AppLocalizations.of(context)!.darkMode
                                  : AppLocalizations.of(context)!.lightMode),
                              IconButton(
                                icon: Icon(
                                  context
                                          .watch<ThemeProvider>()
                                          .isLightModeActive
                                      ? Icons
                                          .nightlight_round //Icono modo oscuro
                                      : Icons.wb_sunny, //Icono modo claro
                                ),
                                onPressed: () {
                                  context
                                      .read<ThemeProvider>()
                                      .changeThemeMode(); //cambio modo en ThemeProvider
                                },
                              ),
                            ]),
                          )
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          //Dropdown para cambiar el idioma
                          Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.05),
                              child: Row(children: [
                                Icon(Icons.translate),
                                DropdownButton<String>(
                                  value: ajustesProvider
                                      .languaje.languageCode, //Idioma actual
                                  onChanged: (String? nuevoIdioma) {
                                    if (nuevoIdioma != null) {
                                      ajustesProvider.changeLanguaje(
                                          nuevoIdioma); //Cambiar el idioma
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'es', child: Text('Español')),
                                    DropdownMenuItem(
                                        value: 'en', child: Text('English')),
                                  ],
                                ),
                              ]))
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          //DropDown para cambiar la divisa
                          Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.05),
                              child: Column(children: [
                                Text(AppLocalizations.of(context)!
                                    .selectCurrency),

                                //Text(ajustesProvider.currency),
                                SizedBox(
                                  width: double
                                      .infinity, //ocupamos todo el ancho disponible
                                  child: DropdownButton<Currency>(
                                    value: ajustesProvider
                                        .currencyCodeInUse, //divisa actual
                                    isExpanded:
                                        true, //permite que el botón use todo el ancho disponible
                                    onChanged: (Currency? nuevaDivisa) {
                                      if (nuevaDivisa != null) {
                                        ajustesProvider.changeCurrency(
                                            nuevaDivisa); //cambiar divisa
                                      }
                                    },
                                    items: List.generate(
                                        APIUtils.allDivisas.length, (index) {
                                      return DropdownMenuItem<Currency>(
                                        value: APIUtils.allDivisas[index],
                                        child: Text(
                                          "${APIUtils.allDivisas[index].currencyName} (${APIUtils.allDivisas[index].currencySymbol})", //lista de monedas junto con su símbolo
                                          overflow: TextOverflow
                                              .ellipsis, //puntos suspensivos si se desborda
                                          maxLines: 1, //solo una línea
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ]))
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.05),
                              child: Container(
                                child: Text("LA OTRA MONEDA SECUNDARIA"),
                              )),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          //Botón para cerrar sesión
                          Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.05),
                              child: Row(children: [
                                Icon(Icons.logout),
                                GestureDetector(
                                  onTap: () {
                                    showLogOutDialog(context);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.logout,
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                            .textScaler
                                            .scale(16),
                                        color: context
                                            .watch<ThemeProvider>()
                                            .palette()["fixedRed"]),
                                  ),
                                ),
                              ]))
                        ],
                      ),
                    ],
                  )
                ]))));
  }
}
