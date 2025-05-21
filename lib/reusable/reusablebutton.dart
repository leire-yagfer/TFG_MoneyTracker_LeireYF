// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///clase reutilizable para los botones de inicio de sesión y registro, al igual que para los de agregar ingreso/gasto
class ReusableButton extends StatelessWidget {
  final VoidCallback onClick;
  String?
      textButton; //porque si está cargando quiero que salga el icono de cargando
  String colorButton;
  String colorTextButton;
  double buttonHeight;
  double buttonWidth;
  String colorBorderButton;
  Widget? child;

  ReusableButton(
      {super.key,
      required this.onClick,
      this.textButton,
      required this.colorButton,
      required this.colorTextButton,
      required this.buttonHeight,
      required this.buttonWidth,
      required this.colorBorderButton,
      this.child});

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width <
        200; //si la pantalla es < 200, se pondrá el texto en 2 líneas

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.height * buttonWidth,
              MediaQuery.of(context).size.height * buttonHeight),
          backgroundColor:
              context.watch<ThemeProvider>().palette()[colorButton]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: context
                  .watch<ThemeProvider>()
                  .palette()[colorBorderButton]!,
            )
          ),
        ),
        onPressed: onClick,
        child: (textButton != null)
            ? Text(
                textButton!,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    color: context
                        .watch<ThemeProvider>()
                        .palette()[colorTextButton]!,
                    fontWeight: FontWeight.w500),
                maxLines: isSmallScreen ? 2 : null,
              )
            : child);
  }
}
