import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:flutter_app_all/Model/UserData.dart';
// import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Page/main_page.dart';



void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Helvetica"),
      debugShowCheckedModeBanner: false,
      home: MainPage(FetchUsers.fromJson(jsonUser).data!, FetchPrivileges.fromJson(jsonPrivileges).data! ),
      );
  }
  //   @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     theme: ThemeData(fontFamily: "Helvetica"),
  //     debugShowCheckedModeBanner: false,
  //     home: LoginTablet(),
  //     );
  // }
}


// manual
Map<String,dynamic> jsonUser = {
"status": 200,
"message": "Berhasil",
"data": {
"user_id": 3,
"username": "alexlo",
"user_password": "alexaja",
"user_fullname": "Alexander Louis",
"user_address": "Jalan mangga",
"user_gender": "L",
"user_birthdate": "2003-02-02",
"user_email": "alexaja@gmail.com",
"user_phone_number": "081000888222",
"user_photo_profile": {
"String": "",
"Valid": false
},
"user_login_timestamp": {
"String": "2024-08-23 00:09:52",
"Valid": true
},
"role_id": 4,
"roles_name": "Warehouse Operational Staff",
"user_otp": "",
"otp_exp": "",
"store_warehouse_id": 2
}
};

Map<String,dynamic> jsonPrivileges = {
"status": 200,
"message": "Berhasil",
"data": [
{
"user_privilege_id": 23,
"role_id": 4,
"privilege_id": 9,
"privileges_name": "members",
"navbar": 1
},
{
"user_privilege_id": 24,
"role_id": 4,
"privilege_id": 10,
"privileges_name": "Add Product",
"navbar": 1
},
{
"user_privilege_id": 25,
"role_id": 4,
"privilege_id": 11,
"privileges_name": "Subtract product stock",
"navbar": 1
},
{
"user_privilege_id": 26,
"role_id": 4,
"privilege_id": 12,
"privileges_name": "stock history",
"navbar": 1
},
{
"user_privilege_id": 27,
"role_id": 4,
"privilege_id": 13,
"privileges_name": "inventory taking",
"navbar": 1
},
{
"user_privilege_id": 28,
"role_id": 4,
"privilege_id": 14,
"privileges_name": "assign product to store",
"navbar": 1
},
{
"user_privilege_id": 29,
"role_id": 4,
"privilege_id": 15,
"privileges_name": "stock transfer notes",
"navbar": 1
},
{
"user_privilege_id": 30,
"role_id": 4,
"privilege_id": 16,
"privileges_name": "notifications",
"navbar": 1
}
]
};
