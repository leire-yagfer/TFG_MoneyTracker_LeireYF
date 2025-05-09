// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:proyecto2eva_budget/view/loginsignup/logindialog.dart';
import 'package:proyecto2eva_budget/view/loginsignup/loginregister.dart';
import 'package:proyecto2eva_budget/view/loginsignup/signupdialog.dart';

mixin LoginLogoutDialog {
  //función para iniciar sesión
  void showLoginDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => LogInDialog());
  }

  //función para registrarse
  void showRegisterDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => SignupDialog());
  }

  
  //función para cerrar sesión
  void showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logoutdialogtitle),
          content: Text(AppLocalizations.of(context)!.logoutdialogcontent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); //sale del diálogo
                Navigator.of(context).pop(); //sale de la página actual
                Navigator.pushReplacement( //vuelve a la página de inicio
                  context,
                  MaterialPageRoute(builder: (context) => LoginSignupPage()),
                );
              },
              child: Text(AppLocalizations.of(context)!.accept),
            ),
          ],
        );
      },
    );
  }
}

