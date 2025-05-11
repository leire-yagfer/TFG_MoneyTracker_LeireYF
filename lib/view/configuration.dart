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
    final ajustesProvider =
        Provider.of<ProviderAjustes>(context); //Obtener los ajustes actuales
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
            child: Column(
          children: [
            //Botón para cambiar entre modo oscuro y modo claro
            IconButton(
              icon: Icon(
                ajustesProvider.modoOscuro
                    ? Icons.nightlight_round //Icono modo oscuro
                    : Icons.wb_sunny, //Icono modo claro
              ),
              onPressed: () {
                context
                    .read<ThemeProvider>()
                    .changeThemeMode(); //cambio modo en ThemeProvider
              },
            ),
            //Dropdown para cambiar el idioma
            DropdownButton<String>(
              value: ajustesProvider.idioma.languageCode, //Idioma actual
              onChanged: (String? nuevoIdioma) {
                if (nuevoIdioma != null) {
                  ajustesProvider
                      .cambiarIdioma(nuevoIdioma); //Cambiar el idioma
                }
              },
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
            //DropDown para cambiar la divisa
            DropdownButton<Currency>(
              value: ajustesProvider.divisaEnUso, //divisa actual
              onChanged: (Currency? nuevaDivisa) {
                if (nuevaDivisa != null) {
                  ajustesProvider
                      .cambiarDivisa(nuevaDivisa); //Cambiar la divisa
                }
              },
              items: List.generate(APIUtils.allDivisas.length, (index) {
                return DropdownMenuItem<Currency>(
                  value: APIUtils.allDivisas[index], //Divisa actual
                  child: Text(
                    "${APIUtils.allDivisas[index].currencyName} (${APIUtils.allDivisas[index].currencySymbol})", //Nombre de la divisa
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }),
            ),
            //Botón para cerrar sesión
            GestureDetector(
              onTap: () {
                showLogOutDialog(context);
              },
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(17),
                    fontWeight: FontWeight.w600,
                    color:
                        context.watch<ThemeProvider>().palette()["fixedRed"]),
              ),
            ),
          ],
        )));
  }
}
