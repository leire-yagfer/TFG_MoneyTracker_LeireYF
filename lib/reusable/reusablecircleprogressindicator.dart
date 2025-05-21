import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///clase reutilizable para cuando se quiera utilizar un CircularProgressIndicator en una pantalla completa
class ReusableCircleProgressIndicator extends StatelessWidget {
  final String text;

  const ReusableCircleProgressIndicator({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            child: CircularProgressIndicator(
              strokeWidth: 6,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.05),
          Text(
            text, textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().palette()['textBlackWhite']!),
          ),
        ],
      ),
    );
  }
}
