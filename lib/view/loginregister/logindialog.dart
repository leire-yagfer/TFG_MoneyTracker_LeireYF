import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusableTxtFormFieldLoginRegister.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablebutton.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablecircleprogressindicator.dart';
import 'package:tfg_monetracker_leireyafer/reusable/reusablerowloginregister.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/appbottomnavigationbar.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/mixinloginregisterlogout.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';
import '../../main.dart' show firestore;

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: _isLoading
            ? ReusableCircleProgressIndicator(text: AppLocalizations.of(context)!.signingIn)
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context
                      .watch<ThemeProvider>()
                      .palette()['backgroundDialog']!,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.emailerror;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        //Campo de contraseña
                        ReusableTxtFormFieldLoginRegister(
                          controller: _passwordController,
                          labelText: AppLocalizations.of(context)!.passwordsi,
                          hintText:
                              AppLocalizations.of(context)!.passwordhintsi,
                          obscureText: true,
                          passwordIcon: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .passworderror;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
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
                            await _signIn();
                            if (_errorMessage == null) {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainApp()));
                            } else {
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
                                        child: Text(AppLocalizations.of(context)!.accept),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          textButton: AppLocalizations.of(context)!.signin,
                          colorButton: 'buttonWhiteBlack',
                          colorTextButton: 'buttonBlackWhite',
                          buttonHeight: 0.08,
                          buttonWidth: 0.5,
                        )
                      ],
                    ),
                  ),
                ),
              ));
  }

  Future<void> _signIn() async {
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

        // Sign in the user
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save credentials for auto-login (always enabled)
        await _authService.saveCredentials(_usernameController.text.trim(),
            _passwordController.text.trim(), false // No biometrics by default
            );

        if (mounted) {
          // Use Future.microtask to avoid navigation during build
          context.read<ConfigurationProvider>().logIn(UserModel(
              userId: userCredential.user!.uid,
              userEmail: _usernameController.text));
          await context.read<ConfigurationProvider>().loadTransactions();
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = 'Authentication failed';

        // More user-friendly error messages
        switch (e.code) {
          case 'user-not-found':
            errorMsg = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMsg = 'Incorrect password';
            break;
          case 'invalid-credential':
            errorMsg = 'Invalid email or password';
            break;
          case 'invalid-email':
            errorMsg = 'Invalid email format';
            break;
          case 'user-disabled':
            errorMsg = 'This account has been disabled';
            break;
          case 'too-many-requests':
            errorMsg = 'Too many failed login attempts. Try again later.';
            break;
          default:
            errorMsg = e.message ?? 'Authentication failed';
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error signing in: $e';
        });
      } finally {
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      setState(() {
        _errorMessage = "Can't leave any blank space";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
