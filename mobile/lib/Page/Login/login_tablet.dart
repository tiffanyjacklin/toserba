import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Tambahan/Provider/LoginProvider.dart';
import 'package:Toserba_App/Template.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginTablet extends StatefulWidget {
  const LoginTablet({super.key});

  @override
  State<LoginTablet> createState() => _LoginTabletState();
}

class _LoginTabletState extends State<LoginTablet> {
  // Controller text edit
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // // cek layar tablet atau hp
  // bool isTablet(BuildContext context) =>
  //     MediaQuery.of(context).size.width >= 767;
  // bool isMobile(BuildContext context) =>
  //     MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    LoginProvider provider = Provider.of<LoginProvider>(context);
    AuthState providerAuth = Provider.of<AuthState>(context);
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
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
                    if (!isPhone())
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
                                          fontSize: (fontSizeBody * 4.0),
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ColorPalleteLogin.PrimaryColor),
                                    ),

                                    
                                  ],
                                  
                                ),
                              ),
                            ),
                            // AutoSizeText(
                                  //     'Welcome',
                                  //     maxLines: 1,
                                  //     style: TextStyle(
                                  //         fontSize: (fontSizeBody * 3.0),
                                  //         fontWeight: FontWeight.bold,
                                  //         color:
                                  //             ColorPalleteLogin.PrimaryColor),
                                  //   ),
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
                                          fontSize: (fontSizeBody * 5.0),
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
                                  fontSize: (fontSizeBody * 3.0),
                                  fontWeight: FontWeight.bold,
                                  color: ColorPalleteLogin.SecondaryColor),
                            )),

                            SizedBox(height: 20),

                            // input username and pw
                            Text(
                              ' Username',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeBody,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: usernameController,
                              style: TextStyle(fontSize: fontSizeBody),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                prefixIcon: Icon(Icons.person_3_outlined),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            Text(
                              ' Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeBody,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: passwordController,
                              style: TextStyle(fontSize: fontSizeBody),
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
                                  style: TextStyle(
                                      fontSize: fontSizeBody,
                                      color: Colors.white)),
                              alignment: Alignment.centerRight,
                            ),

                            SizedBox(
                              height: 20,
                            ),

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
                                  onPressed: () {
                                    _login(providerAuth, provider);
                                  },
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

                            SizedBox(height: 20),
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
    });
  }

  // CEK USER
  Future _fetchUser() async {
    final link =
        'https://leap.crossnet.co.id:8888/user/login?username=${usernameController.text}&password=${passwordController.text}';

    try {
      // call api (method PUT)
      final response = await http.put(Uri.parse(link));
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

          return temp['data']['user_id'];
        } else {
          return -1;
        }
      } else {
        print('login Failed');
        return -1;
      }
    } catch (e) {
      if (e is SocketException) {
        //treat SocketException
        print("Socket exception: ${e.toString()}");
        return -1;
      } else {
        print("Unhandled exception : ${e.toString()}");
        return -1;
      }
    }
  }

  // LOGIN
  void _login(AuthState providerAuth, LoginProvider provider) async {
    // cek semua apakah ada yang belum diisi
    var belumDiisi = '';
    if (usernameController.text == '') {
      belumDiisi = belumDiisi + 'Username ';
    }
    if (passwordController.text == '') {
      belumDiisi = belumDiisi + 'Password ';
    }

    // cek belum diisi
    if (belumDiisi != '') {
      // show snackbar
      final snackBar = SnackBar(
        backgroundColor: Colors.red[400],
        content: Text(belumDiisi + 'belum diisi'),
      );

      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    // lanjutkan login
    else {
      // cari apakah valid
      _fetchUser().then((hasil) => {
            if (hasil != -1)
              {
                //  // berati berhasil login
                providerAuth.userId = hasil.toString(),
                provider.chooseRole = true,
              }
            else
              {
                // show snackbar
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    'Wrong Username/Password',
                    style: TextStyle(fontSize: fontSizeBody),
                  ),
                ))
              }
          });
    }
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
