// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';
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
    final ajustesProvider = Provider.of<ConfigurationProvider>(context);

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
        ),
        body: SingleChildScrollView(
            child: Center(
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
                            fontSize:
                                MediaQuery.of(context).textScaler.scale(18),
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Table(
                        border: TableBorder.all(
                            color: context
                                .watch<ThemeProvider>()
                                .palette()['buttonBlackWhite']!),
                        children: <TableRow>[
                          TableRow(
                            children: <Widget>[
                              //Botón para cambiar entre modo oscuro y modo claro
                              Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.height * 0.025),
                                child: Row(children: [
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
                                  Text(context
                                          .watch<ThemeProvider>()
                                          .isLightModeActive
                                      ? AppLocalizations.of(context)!.darkMode
                                      : AppLocalizations.of(context)!
                                          .lightMode),
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
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    DropdownButton<String>(
                                      value: ajustesProvider.languaje
                                          .languageCode, //Idioma actual
                                      onChanged: (String? nuevoIdioma) {
                                        if (nuevoIdioma != null) {
                                          ajustesProvider.changeLanguaje(
                                              nuevoIdioma); //Cambiar el idioma
                                        }
                                      },
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'es',
                                            child: Text('Español')),
                                        DropdownMenuItem(
                                            value: 'en',
                                            child: Text('English')),
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
                                            APIUtils.allCurrenciesList.length,
                                            (index) {
                                          return DropdownMenuItem<Currency>(
                                            value: APIUtils
                                                .allCurrenciesList[index],
                                            child: Text(
                                              "${APIUtils.allCurrenciesList[index].currencyName} (${APIUtils.allCurrenciesList[index].currencySymbol})", //lista de monedas junto con su símbolo
                                              overflow: TextOverflow
                                                  .ellipsis, //puntos suspensivos si se desborda
                                              maxLines: 1, //solo una línea
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ]))
                            ],
                          ),
                          //DropDown para cambiar la divisa secundaria
                          TableRow(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.05),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .wantToUseSecondCurrency,
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                        // switch que le permite al usuario trabajar con una segunda divisa
                                        Switch(
                                          value: ajustesProvider
                                              .switchUseSecondCurrency,
                                          onChanged: (bool value) {
                                            ajustesProvider
                                                .changeSwitchUseSecondCurrency(
                                                    value);
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    ajustesProvider.switchUseSecondCurrency
                                        ? Column(
                                            children: [
                                              Text(AppLocalizations.of(context)!
                                                  .selectSecondaryCurrency),
                                              SizedBox(
                                                width: double.infinity,
                                                child: DropdownButton<Currency>(
                                                  value: ajustesProvider
                                                      .currencyCodeInUse2,
                                                  isExpanded: true,
                                                  onChanged: (Currency?
                                                      nuevaDivisaSecundaria) {
                                                    if (nuevaDivisaSecundaria !=
                                                        null) {
                                                      ajustesProvider
                                                          .changeCurrency2(
                                                              nuevaDivisaSecundaria);
                                                    }
                                                  },
                                                  items: List.generate(
                                                    APIUtils.allCurrenciesList
                                                        .length,
                                                    (index) {
                                                      return DropdownMenuItem<
                                                          Currency>(
                                                        value: APIUtils
                                                                .allCurrenciesList[
                                                            index],
                                                        child: Text(
                                                          "${APIUtils.allCurrenciesList[index].currencyName} (${APIUtils.allCurrenciesList[index].currencySymbol})",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
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
                    ])))));
  }
}
