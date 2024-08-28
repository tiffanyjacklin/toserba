import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Template.dart';

class SubstractProductPage extends StatelessWidget {
  const SubstractProductPage({super.key});

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
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
          child: Column(children: [
            // judul
            TitlePage(name: 'Substract Product'),

            // table

            // divider + add button

            // misal diklik button maka muncul input untuk masukin product yg ada

            // buat container jika klik
            Container(
              child: Column(
                children: [
                  
                ],
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.55 * 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalleteLogin.OrangeLightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black)
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 6,
                    children: [
                      Text(
                        'Add',
                        style: TextStyle(
                          color: ColorPalleteLogin.PrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {},
              ),
            ),


            // save button
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.55 * 0.45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalleteLogin.PrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black)
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 6,
                    children: [
                      Text(
                        'Submit',
                        style: TextStyle(
                          color: ColorPalleteLogin.OrangeLightColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
