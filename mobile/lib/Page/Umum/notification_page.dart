import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Template.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
          child: Column(
            children: [
              Text(
                'Notification',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorPalleteLogin.PrimaryColor),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: RichText(
                            text: TextSpan(
                              text: '',
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'WARNING',
                                  style: TextStyle(
                                      color: ColorPalleteLogin.PrimaryColor,
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ' : There\'s an unchecked order.',
                                  style: TextStyle(
                                      color: ColorPalleteLogin.PrimaryColor,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                    
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: VerticalDivider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('07:31 AM',  style: TextStyle(
                                        color: ColorPalleteLogin.PrimaryColor,
                                        fontSize: 16, fontWeight: FontWeight.bold),),
                                    Text('10/10/2024',  style: TextStyle(
                                        color: ColorPalleteLogin.PrimaryColor,
                                        fontSize: 16, fontWeight: FontWeight.bold),),
                                    
                                  ],
                                ),
                              ),
                            ],
                          ), 
                        ),
                      ],
                    ),
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
