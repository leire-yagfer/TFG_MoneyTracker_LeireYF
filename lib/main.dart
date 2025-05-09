// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto2eva_budget/model/models/usuario.dart';
import 'package:proyecto2eva_budget/model/services/apicambiodivisa.dart';
import 'package:proyecto2eva_budget/model/services/firebaseauth.dart';
import 'package:proyecto2eva_budget/view/home.dart';
import 'package:proyecto2eva_budget/view/loginsignup/loginregister.dart';
import 'package:proyecto2eva_budget/viewmodel/provider_ajustes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto2eva_budget/viewmodel/themeprovider.dart';
import 'firebase_options.dart';

FirebaseFirestore?
    firestore; //variable que se pasa por todas las clases para iniciar firebase --> que haya acceso a la base de datos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await APIUtils.get_all_currencies();

  // Inicializa Firebase Firestore
  firestore = FirebaseFirestore.instance;

  User? user = await _tryAutoLogin();

  Usuario? u;

  if (user != null) {
    u = Usuario(id: user.uid, correoUsuario: user.email!);
  }

  //MultiProvider para los cambios
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderAjustes(u)),
        ChangeNotifierProvider(create: (context) => ThemeProvider())
      ],
      child: MyApp(),
    ),
  );
}

Future<User?> _tryAutoLogin() async {
  final _authService = AuthService();

  try {
    final user = await _authService.autoLogin();
    return user;
  } catch (e) {
    // Auto-login failed, continue with manual login
    return null;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderAjustes>(
      builder: (context, ajustesProvider, child) {
        //Bloqueo de orientación -> solo permite vertical
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

        return MaterialApp(
          debugShowCheckedModeBanner: false, //Desactivar el banner de debug
          title: 'MoneyTracker',

          //Declaración de los temas
          theme: ThemeData(
              brightness: (context.watch<ThemeProvider>().isLightModeActive)
                  ? Brightness.light
                  : Brightness.dark,
              scaffoldBackgroundColor: context
                  .watch<ThemeProvider>()
                  .palette()['scaffoldBackground']!,
              appBarTheme: AppBarTheme(
                backgroundColor: context
                    .watch<ThemeProvider>()
                    .palette()['scaffoldBackground']!,
                elevation: 0,
              ),
              textTheme: TextTheme(bodyMedium: GoogleFonts.notoSans())),

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: ajustesProvider.idioma, //Idioma de la aplicación
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
          //En función de si existe un usuario ya registrado que ha iniciado sesión, se muestra la pantalla principal y sino, la pagina de inicio de sesión/registro
          home: (context.read<ProviderAjustes>().usuario == null)
              ? LoginSignupPage()
              : MyHomePage(),
        );
      },
    );
  }
}
