import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ColorPalleteLogin.OrangeColor,
              offset: Offset(0, 6),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(child: Text('Session Details', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, offset: Offset(1, 1)),] ),)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last Closing Date', style: TextStyle(fontSize: 20, color: ColorPalleteLogin.OrangeLightColor, fontWeight: FontWeight.bold), ),
                        Text('06:32 PM, 06 June 2024', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,),)
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last Closing Cash Balance', style: TextStyle(fontSize: 20, color: ColorPalleteLogin.OrangeLightColor, fontWeight: FontWeight.bold), ),
                        Text('Rp 1,203,000.00', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ],
              ),
              Center(
                child: TextButton(
                  child: Text('New Session', style: TextStyle(fontSize: 20, color: ColorPalleteLogin.PrimaryColor, fontWeight: FontWeight.bold),), 
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    overlayColor: Colors.deepOrange,
                    backgroundColor: ColorPalleteLogin.OrangeLightColor
                  ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
