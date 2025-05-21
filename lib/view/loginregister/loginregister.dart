// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';


///clase que muestra los botones de inicio de sesión y registro
class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with LoginLogoutDialog {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.appName,
            style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(36),
                fontWeight: FontWeight.w900),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          ReusableButton(
              onClick: () {
                showLoginDialog(context);
              },
              textButton: AppLocalizations.of(context)!.signin,
              colorButton: 'buttonWhiteBlack',
              colorTextButton: 'buttonBlackWhite',
              buttonHeight: 0.1,
              buttonWidth: 0.4,
              colorBorderButton: 'buttonBlackWhite',),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ReusableButton(
              onClick: () {
                showRegisterDialog(context);
              },
              textButton: AppLocalizations.of(context)!.register,
              colorButton: 'buttonBlackWhite',
              colorTextButton: 'buttonWhiteBlack',
              buttonHeight: 0.1,
              buttonWidth: 0.4,
              colorBorderButton: 'buttonWhiteBlack',),
        ],
      ),
    ));
  }
}
