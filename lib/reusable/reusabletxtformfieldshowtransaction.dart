import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

//Clase que crea un TextFormField reutilizable para el formulario de nueva transacción
class ReusableTxtFormFieldShowDetailsTransaction extends StatelessWidget {
  final TextEditingController text;
  final String labelText;

  const ReusableTxtFormFieldShowDetailsTransaction({
    required this.text,
    required this.labelText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: text,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: context.watch<ThemeProvider>().palette()['filledTextField']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
    );
  }
}
