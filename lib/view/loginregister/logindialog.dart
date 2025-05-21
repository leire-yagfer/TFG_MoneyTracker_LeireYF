import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusableTxtFormFieldLoginRegister.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablecircleprogressindicator.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/reusable/reusablerowloginregister.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/appbottomnavigationbar.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';
import '../../main.dart' show firestore;

///clase que muestra el diálogo de inicio de sesión
class LogInDialog extends StatefulWidget {
  LogInDialog({super.key});

  @override
  State<LogInDialog> createState() => _LogInDialogState();
}

class _LogInDialogState extends State<LogInDialog> with LoginLogoutDialog {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  final _authService = AuthService();

  bool _isLoading = false;

  bool isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
                child: ReusableCircleProgressIndicator(
                    text: AppLocalizations.of(context)!.signingIn)),
          )
        : Dialog(
            child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  context.watch<ThemeProvider>().palette()['backgroundDialog']!,
            ),
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Campo de correo electrónico
                    ReusableTxtFormFieldLoginRegister(
                      keyboardType: TextInputType.emailAddress,
                      controller: _usernameController,
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.emailhint,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    //Campo de contraseña
                    ReusableTxtFormFieldLoginRegister(
                      controller: _passwordController,
                      labelText: AppLocalizations.of(context)!.passwordsi,
                      hintText: AppLocalizations.of(context)!.passwordhintsi,
                      obscureText: true,
                      passwordIcon: true,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ReusableRowLoginSignup(
                      text1: AppLocalizations.of(context)!.singupinsignin1,
                      text2: AppLocalizations.of(context)!.singupinsignin2,
                      onClick: () {
                        Navigator.pop(context);
                        showRegisterDialog(context);
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    ReusableButton(
                        onClick: () async {
                          setState(() {
                            isSigningIn = true;
                          });
                          await _signIn();
                          if (_errorMessage == null) {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainApp()));
                          } else {
                            setState(() {
                              isSigningIn = false;
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(_errorMessage!),
                                  content: Text(_errorMessage!),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.accept),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        textButton: isSigningIn
                            ? null
                            : AppLocalizations.of(context)!.signin,
                        colorButton: 'buttonWhiteBlack',
                        colorTextButton: 'buttonBlackWhite',
                        buttonHeight: 0.08,
                        buttonWidth: 0.5,
                        colorBorderButton: 'buttonBlackWhite',
                        child: isSigningIn
                            ? CircularProgressIndicator(
                                color: context
                                    .watch<ThemeProvider>()
                                    .palette()['textBlackWhite']!)
                            : null)
                  ],
                ),
              ),
            ),
          ));
  }

  Future<void> _signIn() async {
    //Verificar que el formulario sea correcto antes de continuar
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        //verificar si firestore está correctamente inicializado
        if (firestore == null) {
          throw Exception(
              AppLocalizations.of(context)!.firebaseNotInitialized);
        }

        //iniciar sesión con email y contraseña usando firebase auth
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //guardar las credenciales para el autoLogin
        await _authService.saveCredentials(_usernameController.text.trim(),
            _passwordController.text.trim(), false 
            );

        if (mounted) {
          //realizar login en la configuración y cargar las transacciones
          context.read<ConfigurationProvider>().logIn(UserModel(
              userId: userCredential.user!.uid,
              userEmail: _usernameController.text));
          await context.read<ConfigurationProvider>().loadTransactions();
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = AppLocalizations.of(context)!.authenticationFailed;

        //errores de firebase auth más corrientes
        switch (e.code) {
          case 'user-not-found':
            errorMsg = AppLocalizations.of(context)!.noUserFound;
            break;
          case 'wrong-password':
            errorMsg = AppLocalizations.of(context)!.incorrectPassword;
            break;
          case 'invalid-credential':
            errorMsg = AppLocalizations.of(context)!.invalidEmailPassword;
            break;
          case 'invalid-email':
            errorMsg = AppLocalizations.of(context)!.invalidEmailFormat;
            break;
          case 'user-disabled':
            errorMsg = AppLocalizations.of(context)!.accountDisabled;
            break;
          default:
            errorMsg = e.message ?? AppLocalizations.of(context)!.authenticationFailed;
        }

        setState(() {
          //actualizar estado con el mensaje de error
          _errorMessage = errorMsg;
        });
      } catch (e) {
        setState(() {
          //manejar cualquier otro tipo de error
          _errorMessage = '${AppLocalizations.of(context)!.errorSigningIn} $e';
        });
      } finally {
        if (mounted) {
          //forzar reconstrucción del widget si está montado
          setState(() {});
        }
      }
    } else {
      //mostrar error si hay campos vacíos
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.blankSpace;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
