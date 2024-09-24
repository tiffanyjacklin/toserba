import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Page/auth_page.dart';
import 'package:flutter_app_all/Page/Umum/splash_page.dart';
import 'package:flutter_app_all/Page/main_page.dart';
import 'package:flutter_app_all/Tambahan/Provider/Auth.dart';
import 'package:flutter_app_all/Tambahan/Provider/LoginProvider.dart';
import 'package:flutter_app_all/Tambahan/Provider/RouteProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
      ],
      builder: (context, child) => MaterialApp(
        title: 'Toserba',
        theme: ThemeData(fontFamily: "Helvetica"),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthState>(builder: (context, authState, _) {
          return authState.isAuthorized
              ? ChangeNotifierProvider(
                  create: (context) => RouteProvider(),
                  child: MainPage(),
                )
              : FutureBuilder(
                  future: authState.tryLogin(),
                  builder: (context, snapshot) =>
                          authState.displayLoginPage
                              ? ChangeNotifierProvider(
                                  create: (context) => LoginProvider(),
                                  child: AuthenticationPage(),
                                )
                              : ChangeNotifierProvider(
                                  create: (context) => RouteProvider(),
                                  child: MainPage(),
                                ),
                );
        }),
      ),
    );
  }
}
