// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';

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
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          ReusableButton(
              onClick: () {
                showLoginDialog(context);
              },
              textButton: AppLocalizations.of(context)!.signin,
              colorButton: 'buttonWhiteBlack',
              colorTextButton: 'buttonBlackWhite',
              buttonHeight: 0.1,
              buttonWidth: 0.6),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ReusableButton(
              onClick: () {
                showRegisterDialog(context);
              },
              textButton: AppLocalizations.of(context)!.register,
              colorButton: 'buttonBlackWhite',
              colorTextButton: 'buttonWhiteBlack',
              buttonHeight: 0.1,
              buttonWidth: 0.6),
        ],
      ),
    ));
  }
}
