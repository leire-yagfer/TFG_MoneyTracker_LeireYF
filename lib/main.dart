// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tfg_monetracker_leireyafer/firebase_options.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebaseauthentication.dart';
import 'package:tfg_monetracker_leireyafer/view/appbottomnavigationbar.dart';
import 'package:tfg_monetracker_leireyafer/view/loginregister/loginregister.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/configurationprovider.dart';
import 'package:tfg_monetracker_leireyafer/viewmodel/themeprovider.dart';

FirebaseFirestore?
    firestore; //variable que se pasa por todas las clases para iniciar firebase --> que haya acceso a la base de datos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //Cargo el archivo interno que contiene las divisas para saber cuáles se pueden usar
    await APIUtils.getAllCurrencies();

    // Inicializa Firebase Firestore
    firestore = FirebaseFirestore.instance;

    User? user = await _tryAutoLogin();

    UserModel? u;

    if (user != null) {
      u = UserModel(userId: user.uid, userEmail: user.email!);
    }

    //MultiProvider para los cambios
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ConfigurationProvider(u)),
          ChangeNotifierProvider(create: (context) => ThemeProvider())
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    Logger().e(e);
  }
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
    return Consumer<ConfigurationProvider>(
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
          locale: ajustesProvider.languaje, //Idioma de la aplicación
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
          //En función de si el usuario tiene internet o no (en base a si se han conseguido recopilar las transacciones de firebase)
          home: (context.watch<ConfigurationProvider>().isWifiConnected)
              ? StatefulBuilder(
                  builder: (context, setState) {
                    return Scaffold(
                        body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off,
                              size: MediaQuery.of(context).size.width * 0.3,
                              color: context
                                  .watch<ThemeProvider>()
                                  .palette()['buttonBlackWhite']!),
                          SizedBox(
                              height: MediaQuery.of(context).size.width * 0.05),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Text(
                              AppLocalizations.of(context)!.errorNoInternet,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context)
                                      .textScaler
                                      .scale(20),
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ));
                  },
                )
              : //En función de si existe un usuario ya registrado que ha iniciado sesión, se muestra la pantalla principal y sino, la pagina de inicio de sesión/registro
              (context.read<ConfigurationProvider>().userRegistered == null)
                  ? LoginSignupPage()
                  : MainApp(),
        );
      },
    );
  }
}
