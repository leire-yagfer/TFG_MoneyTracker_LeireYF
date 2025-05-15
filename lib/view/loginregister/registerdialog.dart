// ignore_for_file: annotate_overrides, overridden_fields, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/main.dart';
import 'package:tfg_monetracker_leireyafer/model/dao/categorydao.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusableTxtFormFieldLoginRegister.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablerowloginregister.dart';
import 'package:tfg_monetracker_leireyafer/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/appbottomnavigationbar.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

//clase que implementa el dopDownButton de selección de país, ya que es de tipo stateful
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
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _repeatedPasswordKey = GlobalKey<FormFieldState>();

  String? _errorMessage;

  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatedpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReusableTxtFormFieldLoginRegister(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.emailhint,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.invalidemail;
                      }
                      String emailPattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      RegExp regex = RegExp(emailPattern);
                      if (!regex.hasMatch(value)) {
                        return AppLocalizations.of(context)!.invalidemail;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  //EL KEY LO USO PARA VALIDAR EL CAMPO Y QUE SEAN IGUALES LAS CONSTRASEÑAS --> MIRAR CÓMO HACER PARA QUE NO DE ERROR EN EL REUSABLE
                  ReusableTxtFormFieldLoginRegister(
                    key: _passwordKey,
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context)!.passwordr,
                    hintText: AppLocalizations.of(context)!.passwordhintr,
                    obscureText: true, // empieza oculto
                    passwordIcon: true, // muestra el icono para ver/ocultar
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return AppLocalizations.of(context)!.newpassworderror;
                      }
                      return null;
                    },
                  ),

                  /*TextFormField(
                    key: _passwordKey,
                    obscureText: !_isPasswordVisible,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordr,
                      hintText: AppLocalizations.of(context)!.passwordhintr,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: context
                              .watch<ThemeProvider>()
                              .palette()['buttonBlackWhite']!,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          _passwordController.text.length < 6) {
                        return AppLocalizations.of(context)!.newpassworderror;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _passwordKey.currentState!.validate();
                    },
                  ),*/
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ReusableTxtFormFieldLoginRegister(
                    key: _repeatedPasswordKey,
                    controller: _repeatedpasswordController,
                    labelText: AppLocalizations.of(context)!.repeatpassword,
                    hintText: AppLocalizations.of(context)!.repeatpasswordhint,
                    obscureText: true,
                    passwordIcon: true,
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

                  /*TextFormField(
                    key: _repeatedPasswordKey,
                    obscureText: !_isPasswordVisible,
                    controller: _repeatedpasswordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.repeatpassword,
                      hintText:
                          AppLocalizations.of(context)!.repeatpasswordhint,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: context
                              .watch<ThemeProvider>()
                              .palette()['buttonBlackWhite']!,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value != _passwordController.text) {
                        return AppLocalizations.of(context)!
                            .nocoincidencedpasswords;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _repeatedPasswordKey.currentState!.validate();
                    },
                  ),*/
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  ReusableRowLoginSignup(
                    text1: AppLocalizations.of(context)!.signininsignup1,
                    text2: AppLocalizations.of(context)!.signininsignup2,
                    onClick: () {
                      Navigator.pop(context);
                      showLoginDialog(context);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  ReusableButton(
                      onClick: () async {
                        await _register();
                        if (_errorMessage == null) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainApp()));
                        } else {
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
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      textButton: AppLocalizations.of(context)!.register,
                      colorButton: 'buttonWhiteBlack',
                      colorTextButton: 'buttonBlackWhite',
                      buttonHeight: 0.08,
                      buttonWidth: 0.5),
                ],
              ),
            ),
          ))),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Check if Firestore is available
        if (firestore == null) {
          throw Exception(
              "Firebase is not properly initialized. Please restart the app.");
        }

        // Create the user account
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save credentials for auto-login (always enabled)
        await _authService.saveCredentials(_emailController.text.trim(),
            _passwordController.text.trim(), false // No biometrics by default
            );

        // Get the user's UID
        final String uid = userCredential.user!.uid;

        //Create a user document in Firestore
        try {
          await firestore!.collection('users').doc(uid).set({
            'email': _emailController.text.trim(),
          });
          context.read<ConfigurationProvider>().logIn(
              UserModel(userId: uid, userEmail: _emailController.text.trim()));
          await CategoryDao().insertarCategoriasRegistro(uid);
        } catch (firestoreError) {
          Logger().e(firestoreError);
          // Continue with registration even if Firestore fails
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = 'Registration failed';

        // More user-friendly error messages
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = 'An account already exists with this email';
            break;
          case 'invalid-email':
            errorMsg = 'Invalid email format';
            break;
          case 'weak-password':
            errorMsg = 'Password is too weak, please use a stronger password';
            break;
          case 'operation-not-allowed':
            errorMsg = 'Email/password registration is not enabled';
            break;
          default:
            errorMsg = e.message ?? 'Registration failed';
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error creating account: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        setState(() {
          _errorMessage = "Can't leave any blank space";
        });
      });
    }
  }
}
