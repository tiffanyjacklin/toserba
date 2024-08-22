import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Page/main_page.dart';



void main() {
  runApp(const MainApp());
}





class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(fontFamily: "Helvetica"),
      debugShowCheckedModeBanner: false,
      home: const LoginTablet(),
      );
  }
}