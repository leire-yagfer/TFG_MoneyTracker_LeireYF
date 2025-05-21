// ignore_for_file: annotate_overrides, overridden_fields, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/main.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusableTxtFormFieldLoginRegister.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablecircleprogressindicator.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablerowloginregister.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/appbottomnavigationbar.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

///Clase que muestra el cuadro de dialogo de registro
class SignupDialog extends StatefulWidget {
  @override
  _SignupDialogState createState() => _SignupDialogState();
}

class _SignupDialogState extends State<SignupDialog> with LoginLogoutDialog {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatedpasswordController =
      TextEditingController();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _repeatedPasswordKey = GlobalKey<FormFieldState>();
  String? _passwordMismatchError;

  String? _errorMessage;

  final _authService = AuthService();

  bool _isLoading = false;

  bool isRegistering = false;

  //añado listeners a los controller de los campos de contraseñas para comprobar en tiempo real que coincidan --> para ello llamo al método que comprueba que se cumpla
  @override
  void initState() {
    super.initState();

    _repeatedpasswordController.addListener(() {
      if (_repeatedpasswordController.text != _passwordController.text) {
        setState(() {
          _passwordMismatchError =
              AppLocalizations.of(context)!.nocoincidencedpasswords;
        });
      } else {
        setState(() {
          _passwordMismatchError = null;
        });
      }
    });

    _passwordController.addListener(() {
      if (_repeatedpasswordController.text != _passwordController.text) {
        setState(() {
          _passwordMismatchError =
              AppLocalizations.of(context)!.nocoincidencedpasswords;
        });
      } else {
        setState(() {
          _passwordMismatchError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _repeatedpasswordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _repeatedpasswordController.dispose();
    super.dispose();
  }

  //método para comprobar en tiempo real si las contraseñas introducidas al registrarse coinciden
  void _onPasswordChanged() {
    if (_repeatedPasswordKey.currentState != null) {
      _repeatedPasswordKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
                child: ReusableCircleProgressIndicator(
                    text: AppLocalizations.of(context)!.signingIn)),
          )
        : Dialog(
            child: _isLoading
                ? ReusableCircleProgressIndicator(
                    text: AppLocalizations.of(context)!.signingIn,
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context
                          .watch<ThemeProvider>()
                          .palette()['backgroundDialog']!,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.02),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReusableTxtFormFieldLoginRegister(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              labelText: AppLocalizations.of(context)!.email,
                              hintText: AppLocalizations.of(context)!.emailhint,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value != _passwordController.text) {
                                  return AppLocalizations.of(context)!
                                      .nocoincidencedpasswords;
                                }
                                return null;
                              },
                            ),

                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            //EL KEY LO USO PARA VALIDAR EL CAMPO Y QUE SEAN IGUALES LAS CONSTRASEÑAS --> MIRAR CÓMO HACER PARA QUE NO DE ERROR EN EL REUSABLE
                            ReusableTxtFormFieldLoginRegister(
                              key: _passwordKey,
                              controller: _passwordController,
                              labelText:
                                  AppLocalizations.of(context)!.passwordr,
                              hintText:
                                  AppLocalizations.of(context)!.passwordhintr,
                              obscureText: true, // empieza oculto
                              passwordIcon:
                                  true, // muestra el icono para ver/ocultar
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            ReusableTxtFormFieldLoginRegister(
                              key: _repeatedPasswordKey,
                              controller: _repeatedpasswordController,
                              labelText:
                                  AppLocalizations.of(context)!.repeatpassword,
                              hintText: AppLocalizations.of(context)!
                                  .repeatpasswordhint,
                              obscureText: true,
                              passwordIcon: true,
                            ),
                            if (_passwordMismatchError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _passwordMismatchError!,
                                  style: TextStyle(
                                      color: context.watch<ThemeProvider>().palette()['fixedRed']!, fontSize: 12),
                                ),
                              ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            ReusableRowLoginSignup(
                              text1:
                                  AppLocalizations.of(context)!.signininsignup1,
                              text2:
                                  AppLocalizations.of(context)!.signininsignup2,
                              onClick: () {
                                Navigator.pop(context);
                                showLoginDialog(context);
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            ReusableButton(
                              onClick: () async {
                                setState(() {
                                  isRegistering = true;
                                });
                                await _register();
                                if (_errorMessage == null) {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainApp()));
                                } else {
                                  setState(() {
                                    isRegistering = false;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(_errorMessage!),
                                      content: Text(_errorMessage!),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .accept),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              textButton: isRegistering
                                  ? null
                                  : AppLocalizations.of(context)!.register,
                              colorButton: 'buttonWhiteBlack',
                              colorTextButton: 'buttonBlackWhite',
                              buttonHeight: 0.08,
                              buttonWidth: 0.5,
                              colorBorderButton: 'buttonBlackWhite',
                              child: isRegistering
                                  ? CircularProgressIndicator(
                                      color: context
                                          .watch<ThemeProvider>()
                                          .palette()['textBlackWhite']!)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    )),
          );
  }

  Future<void> _register() async {
    //verificar que el formulario sea válido antes de continuar
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        //verificar si firestore está correctamente inicializado
        if (firestore == null) {
          throw Exception(AppLocalizations.of(context)!.firebaseNotInitialized);
        }

        //registrar al usuario con email y contraseña usando firebase auth
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //guardar credenciales para el inicio automático
        await _authService.saveCredentials(_emailController.text.trim(),
            _passwordController.text.trim(), false);

        //obtener el uid del usuario recién creado
        final String uid = userCredential.user!.uid;

        //crear un documento de usuario en firestore
        try {
          await firestore!.collection('users').doc(uid).set({
            'email': _emailController.text.trim(),
          });
          //realizar login en el provider de configuración y crear categorías
          context.read<ConfigurationProvider>().logIn(
              UserModel(userId: uid, userEmail: _emailController.text.trim()));
          await CategoryDao().categoriesInRegistration(uid);
        } catch (firestoreError) {
          Logger().e(firestoreError);
          //continuar el registro aunque falle firestore
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = AppLocalizations.of(context)!.registrationFailed;

        //errores de firebase auth más corrientes
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = AppLocalizations.of(context)!.emailalreadyused;
            break;
          case 'invalid-email':
            errorMsg = AppLocalizations.of(context)!.invalidemail;
            break;
          case 'weak-password':
            errorMsg = AppLocalizations.of(context)!.weakPassword;
            break;
          default:
            errorMsg =
                e.message ?? AppLocalizations.of(context)!.registrationFailed;
        }
        //actualizar estado con el mensaje de error
        setState(() {
          _errorMessage = errorMsg;
        });
      } catch (e) {
        //manejar cualquier otro tipo de error inesperado
        setState(() {
          _errorMessage =
              '${AppLocalizations.of(context)!.errorRegistering} $e';
        });
      } finally {
        //desactivar el indicador de carga si el widget está montado
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        //mostrar error si hay campos vacíos
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.blankSpace;
        });
      });
    }
  }
}
