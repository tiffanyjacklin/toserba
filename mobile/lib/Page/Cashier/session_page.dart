import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Model/Session.dart';
import 'package:flutter_app_all/Model/SessionList.dart';
import 'package:flutter_app_all/Page/Cashier/WidgetChild/sessionClosing.dart';
import 'package:http/http.dart' as http;

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  Session? sessionLast = null;

  @override
  void initState() {
    // TODO: implement initState
    // calling api
    // sessionLast = await _getLastSession();

    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    // making the card session 
    return Center(
      child: CardSession(session: sessionLast,),
    );
  }



  // buat api function getting all session?
  Future _getLastSession() async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/cashier/session/last';

    // panggil 
    // call api (method GET)
    final response = await http.get(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      // json
      Map<String, dynamic> temp = json.decode(response.body);
      // decode?
      print(response.body);
      if (temp['status'] == 200) {
        print(temp);
        return Session.fromJson(temp['data']);
      }
      else{
        return -1;
      }

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');
      print('Failed to Get Data');
      return -1;
    }
  }
}

class CardSession extends StatelessWidget {
  // all variable check?
  Session? session;

  CardSession({
    required this.session
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      Text(session != null  ? session!.lastUpdateTime! : '--', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,),)
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Closing Cash Balance', style: TextStyle(fontSize: 20, color: ColorPalleteLogin.OrangeLightColor, fontWeight: FontWeight.bold), ),
                      Text(session != null  ? session!.expectedClosingCash.toString() : '--', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ],
            ),

            // cek dulu
            // session != null ? 
            Center(
              child: TextButton(
                child: Text('New Session', style: TextStyle(fontSize: 20, color: ColorPalleteLogin.PrimaryColor, fontWeight: FontWeight.bold),), 
                onPressed: () {
                  // buat alert dialog
                  showDialog(
                    context: context, 
                    builder: (context) => SessionPopup(),
                  );
                },
                style: TextButton.styleFrom(
                  overlayColor: Colors.deepOrange,
                  backgroundColor: ColorPalleteLogin.OrangeLightColor
                ),
                ),
            ) 
            // : Center(),
          ],
        ),
      ),
    );
  }
}
