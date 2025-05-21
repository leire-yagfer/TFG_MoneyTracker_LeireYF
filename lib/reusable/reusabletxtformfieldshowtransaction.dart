import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que crea un TextFormField reutilizable para el formulario de nueva transacción
class ReusableTxtFormFieldShowDetailsTransactionAndEditCategory extends StatelessWidget {
  final TextEditingController text;
  final String labelText;
  final bool readOnly;
  final String? Function(String?)? validator;
  


  const ReusableTxtFormFieldShowDetailsTransactionAndEditCategory({
    required this.text,
    required this.labelText,
    this.readOnly = true,
    this.validator,
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
      readOnly: readOnly,
      validator: validator,
    );
  }
}
