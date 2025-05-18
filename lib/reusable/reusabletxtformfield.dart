import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

//Clase que crea un TextFormField reutilizable para el formulario de nueva transacción
class ReusableTxtFormFieldNewTransactionCategory extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool readOnly; //especial para el campo de selección de fecha paraq ue en ese TextFormField no se pueda escribir
  final VoidCallback? onTap; //especial para la selección de fecha
  final String? Function(String?)? validator; //función para validar el campo

  const ReusableTxtFormFieldNewTransactionCategory({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType = TextInputType.text, //por defecto texto, pero para cantidad solo numérico
    this.readOnly = false, //por defecto false, true para la fecha
    this.onTap,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: context.watch<ThemeProvider>().palette()['filledTextField']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }
}
