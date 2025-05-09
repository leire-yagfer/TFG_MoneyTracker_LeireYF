import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2eva_budget/viewmodel/themeprovider.dart';

//clase reutilizable para el inicio sesión o registro en el inicio
class ReusableRowLoginSignup extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onClick;

  const ReusableRowLoginSignup(
      {super.key,
      required this.text1,
      required this.text2,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$text1 ",
            style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: onClick,
            child: Text(
              text2,
              style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: context
                    .watch<ThemeProvider>()
                    .palette()['fixedLightGrey']!,
              ),
            ),
          ),
        ]);
  }
}