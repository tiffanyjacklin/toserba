import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Template.dart';

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Session History', style : TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ColorPalleteLogin.PrimaryColor)),
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: SearchBar(       
                  // trailing: Icon(Icons.abc),
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
}