import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Page/main_page.dart';
import 'package:http/http.dart' as http;

// manual nama
var roleName = [
  'Cashier',
  'Inventory Store Employee',
  'Warehouse Employee',
  'Warehouse Operational Staff',
  'Admin',
  'Owner'
];

class ChooseRolePage extends StatefulWidget {
  final int userId;
  const ChooseRolePage(this.userId);

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
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
            height: 400,
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        250, // tinggal setting berapa besar kotak rolenya mau berapa
                    childAspectRatio: (3 / 2), // rasio hasil besar child
                    crossAxisSpacing: 10, // kiri kanan
                    mainAxisSpacing: 10 // atas bawah
                    ),
                itemCount: 6,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                      _roleValidate(widget.userId, index + 1).then((hasil) => {
                            if (hasil != null)
                              {
                                // getting also the priviledges and passing it
                                _fetchPriviledge(widget.userId, index + 1)
                                    .then((listPrivileges) => {
                                          if (listPrivileges != null)
                                            {
                                              // pindah halaman dengan kirim data user
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              MainPage(hasil, listPrivileges)))
                                            }
                                        }),
                              },
                            // print(hasil.runtimeType)
                          });
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
                          Center(
                            child: Text(
                              roleName[index],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: ColorPalleteLogin.PrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // API Function
  Future _roleValidate(int userId, int roleId) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/user/$userId/$roleId';

    // call api (method GET)
    final response = await http.get(Uri.parse(link));

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      Map<String, dynamic> temp = json.decode(response.body);

      // ambil data yang ada
      FetchUsers userData = FetchUsers.fromJson(temp);

      if (temp['data'].length != 0) {
        // masukin data login ke dalam sharedpreference
        return userData.data;
      }
      // kasih error kalo dia ga punya akses
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Akses ditolak'),
      ));
      return null;

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');

      print('Error, Try Again');

      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Try Again'),
      ));
      return null;
    }
  }

  Future _fetchPriviledge(int userId, int roleId) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/user/privileges/$userId/$roleId';

    // call api (method GET)
    final response = await http.get(Uri.parse(link));

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      Map<String, dynamic> temp = json.decode(response.body);

      // ambil data yang ada
      FetchPrivileges privilegesData = FetchPrivileges.fromJson(temp);

      if (temp['data'].length != 0) {
        // ambil list priviledges
        return privilegesData.data;
      }
      return null;
    } else {
      print('Error, Try Again');
      return null;
    }
  }
}
