import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Template.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Icon(Icons.app_settings_alt_rounded, size: MediaQuery.of(context).size.height * 0.20,),
            TitlePage(name: 'Page Not Found'),
            Text('Please Contact Developer, If you think this is a mistake', style: TextStyle(fontSize: fontSizeBody+2),)
          ],
        ),
      );
  }
}
