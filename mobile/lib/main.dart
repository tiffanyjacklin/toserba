import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Page/Umum/splash_page.dart';
import 'package:flutter_app_all/Page/main_page.dart';
import 'package:flutter_app_all/Tambahan/Provider/LoginProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     theme: ThemeData(fontFamily: "Helvetica"),
  //     debugShowCheckedModeBanner: false,
  //     home: MainPage(FetchUsers.fromJson(jsonUser).data!, FetchPrivileges.fromJson(jsonPrivileges).data! ),
  //     );
  // }

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
              ? const MainPage()
              : FutureBuilder(
                  future: authState.tryLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : authState.displayLoginPage
                              ? const LoginTablet()
                              : const MainPage(),
                );
        }),
      ),
    );
  }
}
