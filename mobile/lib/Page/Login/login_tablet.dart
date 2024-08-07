import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:flutter_app_all/Page/Login/choose_role.dart';
import 'package:flutter_app_all/Page/main_page.dart';

// anggep ini data
var user = [];

// anggep ini pilihan dropdown ( AMBIL DARI DATABASE )
var itemDropDown = ['Cashier', 'Inventory', 'Admin', 'Owner'];

class LoginTablet extends StatefulWidget {
  const LoginTablet({super.key});

  @override
  State<LoginTablet> createState() => _LoginTabletState();
}

class _LoginTabletState extends State<LoginTablet> {
  String dropDownValue = itemDropDown[0];

  // cek layar tablet atau hp
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 767;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation){ 
      return Scaffold(
        // resizeToAvoidBottomInset: true,
          // backgroundColor: ColorPalleteLogin.PrimaryColor,
          body: CustomPaint(
            painter: DiagonalBackgroundPainter(),
            child: Center(
              child: Container(
                color: ColorPalleteLogin.PrimaryColor,
                width: MediaQuery.sizeOf(context).width * 0.90,
                height: MediaQuery.sizeOf(context).height * 0.85,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      if (isTablet(context) && orientation == Orientation.landscape)
                        Expanded(
                          flex: 4,
                          // ini kolom 1
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              // Kotak Hello
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalleteLogin.OrangeLightColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AutoSizeText(
                                        'Welcome',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 74,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                ColorPalleteLogin.PrimaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // Kotak back
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalleteLogin.OrangeDarkColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                          child: AutoSizeText(
                                        maxLines: 1,
                                        'Back.',
                                        style: TextStyle(
                                            fontSize: 100,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                ColorPalleteLogin.PrimaryColor),
                                      )),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.barcode,
                                            size: 55,
                                            color: ColorPalleteLogin.PrimaryColor,
                                          ),
                                          Icon(
                                            CupertinoIcons.barcode,
                                            size: 55,
                                            color: ColorPalleteLogin.PrimaryColor,
                                          ),
                                          Icon(
                                            CupertinoIcons.barcode,
                                            size: 55,
                                            color: ColorPalleteLogin.PrimaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        flex: 6,
                        // kolom 2
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32.0, right: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Text(
                                'LOGIN',
                                style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalleteLogin.SecondaryColor),
                              )),
      
                              SizedBox(height: 20),
      
                              // // select box
                              // Container(
                              //   decoration: ShapeDecoration(
                              //     color: Colors.white,
                              //     shape: RoundedRectangleBorder(
                              //       side: BorderSide(
                              //           width: 1.0, style: BorderStyle.solid),
                              //       borderRadius:
                              //           BorderRadius.all(Radius.circular(20.0)),
                              //     ),
                              //   ),
                              //   child: DropdownButton(
                              //     borderRadius: BorderRadius.circular(20.0),
                              //     items: itemDropDown
                              //         .map<DropdownMenuItem<String>>(
                              //             (String value) {
                              //       return DropdownMenuItem<String>(
                              //         value: value,
                              //         child: Padding(
                              //           padding: const EdgeInsets.only(left: 6.0),
                              //           child: Text(value),
                              //         ),
                              //       );
                              //     }).toList(),
                              //     value: dropDownValue,
                              //     onChanged: onDropdownValueChanged,
                              //     isExpanded: true,
                              //     dropdownColor: Colors.white,
                              //     style: TextStyle(
                              //         color: ColorPalleteLogin.PrimaryColor),
                              //   ),
                              // ),
      
                              // input username and pw
                              Text(
                                ' Username',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  prefixIcon: Icon(Icons.person_3_outlined),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
      
                              Text(
                                ' Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true, // ini nanti mau disetting ga?
                              ),
      
                              // untuk forgot password
                              Align(
                                child: AutoSizeText('Forgot Password?',
                                maxLines: 1,
                                    style: TextStyle(color: Colors.white)),
                                alignment: Alignment.centerRight,
                              ),
      
                              SizedBox(height: 20,),
      
                              Center(
                                child: Container(
                                  width: 200,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          ColorPalleteLogin.OrangeDarkColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    onPressed: _login,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LOGIN ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  ColorPalleteLogin.PrimaryColor),
                                        ),
                                        Icon(
                                          Icons.logout,
                                          color: ColorPalleteLogin.PrimaryColor,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // tambahin callback
  void onDropdownValueChanged(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        dropDownValue = selectedValue;

        // perlu set selected jadi dipaling atas
      });
    }
  }

  // LOGIN
  void _login() async {
    // kerjakan logic login


    // pindah halaman
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => ChooseRolePage()));
  }
}

class DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    // persentasi titik potong atas dan bawah
    double titikAtas = 0.05;
    double titikBawah = 0.7;

    // gambar segitiga kiri
    Path path = Path();

    // 4 titik segitiga kiri
    path.moveTo(0, 0);
    path.lineTo(size.width * titikAtas, 0);
    path.lineTo(size.width * titikBawah, size.height);
    path.lineTo(0, size.height);
    path.close();

    paint.color = ColorPalleteLogin.PrimaryColor;
    canvas.drawPath(path, paint);

    // gambar segitiga kanan
    path = Path();

    // 4 titik segitiga kanan mulai dari titik atas
    path.moveTo(size.width * titikAtas, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * titikBawah, size.height);
    path.close();

    paint.color = ColorPalleteLogin.OrangeLightColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
