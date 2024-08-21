import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:stroke_text/stroke_text.dart';

class AcceptOrderPage extends StatelessWidget {
  const AcceptOrderPage({super.key});

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
          child: Column(
            children: [
              Text('Accept Order',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ColorPalleteLogin.PrimaryColor)),
              SizedBox(
                height: 20,
              ),
              // search bar
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(
                    // trailing: Icon(Icons.abc),
                    ),
              ),

              SizedBox(
                height: 20,
              ),

              // pagination nya

              // list tiles view
              // Card(
              //   margin: EdgeInsets.all(8.0),
              //   child: ListTile(
              //     tileColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       side: BorderSide(color: Colors.black, width: 1),
              //       borderRadius: BorderRadius.circular(16.0),
              //     ),
              //     leading: Icon(
              //       Icons.insert_drive_file_outlined,
              //       size: 40,
              //     ),
              //     title: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Delivery Order #112345667 ',
              //           style: TextStyle(
              //             color: ColorPalleteLogin.PrimaryColor,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 16,
              //           ),
              //         ),
              //         Text(
              //           '01-07-2024, 07:40 PM ',
              //           style: TextStyle(
              //             color: ColorPalleteLogin.PrimaryColor,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 16,
              //           ),
              //         ),
              //       ],
              //     ),
              // subtitle: StrokeText(
              //   text: 'Unchecked !!',
              //   textStyle: true == true
              //       ? TextStyle(
              //           color: ColorPalleteLogin.OrangeDarkColor,
              //           fontWeight: FontWeight.bold,
              //           fontSize: 18,
              //         )
              //       : TextStyle(
              //           color: ColorPalleteLogin.PrimaryColor,
              //           fontWeight: FontWeight.bold,
              //           fontSize: 18,
              //         ),
              // ),

              //     // kanan
              //     trailing: GestureDetector(
              //       onTap: () {
              //         // buat alert dialog
              //         // showDialog(
              //         //   barrierDismissible: false,
              //         //   context: context,
              //         //   builder: (context) => ProductDetailsPopup(),
              //         // );
              //       },
              //       child: Container(
              //         height: double.maxFinite,

              //         decoration: BoxDecoration(
              //           color: ColorPalleteLogin.PrimaryColor,
              //         ),
              //         child: Icon(
              //           Icons.remove_red_eye_outlined,
              //           size: 32,
              //           color: ColorPalleteLogin.OrangeColor,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // making self
              DeliveryOrderChild(),
              DeliveryOrderChild(),
              DeliveryOrderChild(),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryOrderChild extends StatelessWidget {
  const DeliveryOrderChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // leading
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 40,
                ),
              ),

              // center
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Order #112345667 ',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '01-07-2024, 07:40 PM ',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    StrokeText(
                      text: 'Unchecked !!',
                      textStyle: true == true
                          ? TextStyle(
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )
                          : TextStyle(
                              color: ColorPalleteLogin.PrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                    ),
                  ],
                ),
              ),

              // trailing
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    // buat alert dialog
                    // showDialog(
                    //   barrierDismissible: false,
                    //   context: context,
                    //   builder: (context) => ProductDetailsPopup(),
                    // );
                  },
                  child: Container(
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: ColorPalleteLogin.PrimaryColor,
                    ),
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 32,
                      color: ColorPalleteLogin.OrangeLightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
