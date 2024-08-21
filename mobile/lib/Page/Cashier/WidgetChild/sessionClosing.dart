import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';

class SessionPopup extends StatelessWidget {
  const SessionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.height * 0.8,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 26,
                ),
                alignment: Alignment.topRight,
              ),
              Center(
                  child: Text(
                'Session Details',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(1, 1)),
                    ]),
              )),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cashier',
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Budi Setiawan',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start time',
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Closing time',
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '12:04 PM, 12 July 2024',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opening cash',
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp. 400,000.00',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional notes',
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'helpt',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
