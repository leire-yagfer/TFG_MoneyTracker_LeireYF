import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

//clase que crea un TextFormField reutilizable para login y registro
class ReusableTxtFormFieldLoginRegister extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText; //para determinar si es un campo de contraseña
  final TextInputType keyboardType;
  final bool passwordIcon; //para mostrar el icono de visibilidad
  final String? Function(String?)? validator;

  ReusableTxtFormFieldLoginRegister({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.passwordIcon = false,
  });

  @override
  State<ReusableTxtFormFieldLoginRegister> createState() =>
      ReusableTxtFormFieldLoginRegisterState();
}

class ReusableTxtFormFieldLoginRegisterState
    extends State<ReusableTxtFormFieldLoginRegister> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    //Inicializo la visibilidad de la contraseña con el valor recibido desde el widget padre (desde la clase desde donde se le llama)
    _isPasswordVisible = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      obscureText: widget.passwordIcon ? _isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        filled: true,
        fillColor: context.watch<ThemeProvider>().palette()['fixedLightGrey']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.passwordIcon
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: context
                      .watch<ThemeProvider>()
                      .palette()['buttonBlackWhite']!,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}