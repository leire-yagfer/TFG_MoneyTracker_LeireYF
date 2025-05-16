// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/logindialog.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/loginregister.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/registerdialog.dart';

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
                //cerrar sesión de la app --> cuando se vuelva a iniciar la app pedirá las credenciales
                await FirebaseAuth.instance.signOut(); //hace el cierre de sesión
                await AuthService().clearSavedCredentials(); //elimina las credenciales guardadas
              },
              child: Text(AppLocalizations.of(context)!.accept),
            ),
          ],
        );
      },
    );
  }
}

