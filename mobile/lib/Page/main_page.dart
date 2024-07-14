import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // cek layar tablet atau hp
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 767;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              flex: 2, 
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalleteLogin.PrimaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage('https://picsum.photos/id/237/300/300'),
                      ),
                      Text('cixixi'),
                    ],
                  ),
                ),
              )),
          Expanded(flex: 8, child: Text('hhhh')),
        ],
      ),
    );
  }
}
