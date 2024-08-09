import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:flutter_app_all/Page/main_page.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Role',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: ColorPalleteLogin.PrimaryColor),
          ),

          Container(
            height: 350,
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        250, // tinggal setting berapa besar kotak rolenya mau berapa
                    childAspectRatio: (3/2), // rasio hasil besar child
                    crossAxisSpacing: 10, // kiri kanan
                    mainAxisSpacing: 10 // atas bawah
                    ),
                itemCount: 6,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                        print('Kamu pilih blabla');


                        // pindah halaman
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MainPage()));
                      },
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalleteLogin.OrangeLightColor,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_alarm_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Data Halo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ColorPalleteLogin.PrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // // button back
          // Container(
          //   child: TextButton(
          //     style: TextButton.styleFrom(
          //       backgroundColor: ColorPalleteLogin.PrimaryColor,
          //     ),
          //     child: Text('BACK', style: TextStyle(color: ColorPalleteLogin.OrangeColor),),
          //     onPressed: (){
          //       // Navigator.of(context).pop();
          //     },
          //     ),
          // ),
        ],
      ),
    );
  }
}
