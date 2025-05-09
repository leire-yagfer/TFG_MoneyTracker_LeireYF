import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2eva_budget/model/models/usuario.dart';
import 'package:proyecto2eva_budget/model/services/firebaseauth.dart';
import 'package:proyecto2eva_budget/reusable/reusablemainbutton.dart';
import 'package:proyecto2eva_budget/reusable/reusablerowloginregister.dart';
import 'package:proyecto2eva_budget/view/home.dart';
import 'package:proyecto2eva_budget/view/loginsignup/mixinloginregisterlogout.dart';
import 'package:proyecto2eva_budget/viewmodel/provider_ajustes.dart';
import 'package:proyecto2eva_budget/viewmodel/themeprovider.dart';
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

  bool _isPasswordVisible =
      false; // Variable para controlar la visibilidad de la contraseña

  String? _errorMessage;

  final _authService = AuthService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  hintText: AppLocalizations.of(context)!.emailhint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emailerror;
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.passwordsi,
                  hintText: AppLocalizations.of(context)!.passwordhintsi,
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
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.passworderror;
                  }
                  return null;
                },
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
              ReusableMainButton(
                onClick: () async {
                  await _signIn();
                  if (_errorMessage == null) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
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
                              child: Text("OK"),
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
    );
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
          context.read<ProviderAjustes>().inicioSesion(Usuario(
              id: userCredential.user!.uid,
              correoUsuario: _usernameController.text));
          await context.read<ProviderAjustes>().cargarTransacciones();
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
