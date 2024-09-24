import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class AuthState extends ChangeNotifier{
  AuthState(){}

  // this for data?
  late String _username, _password;
  late int _roleId;

  late FetchUsers? _user;
  String errorMessage = '';

  bool displayLoginPage = true;

  // Future <bool> isLoggedBefore() async {
  //   return await _secureStorage.containsKey(key: keyUsername);
  // }

  // Future<void> fetchFromStorage() async{
  //   _username = (await _secureStorage.read(key: keyUsername))!;
  //   _password = (await _secureStorage.read(key: keyPassword))!;
  // }

  bool get isAuthorized{
    if(_user != null){
      return true;
    }
    return false;
  }

  Future<bool> tryLogin() async {
    final keyUsername = 'UName';
    final keyPassword = 'UPassword';
    final keyRole = 'roleId';
    final _secureStorage = const FlutterSecureStorage();

    // cek misal pernah ga dia login?
    _username = await _secureStorage.read(key: keyUsername) ?? '';
    _password = await _secureStorage.read(key: keyPassword) ?? '';
    var resultRole = await _secureStorage.read(key: keyRole) ?? '';
    if(resultRole.isEmpty){
      _roleId = -1;
    }
    else{
      _roleId = int.parse(resultRole);
    }
    

    if(_username.isEmpty){
      return false;
    }

    // fetch user
    var result = await _fetchUser();
    if(result.first != null){
      // result is user id

      _user = result.first;
      return true; // sudah login
    }
    return false;

  }

  void logout(){
    _user = null;
    _username = '';
    _password = '';
    displayLoginPage = true;

    notifyListeners();
  }

  // CEK USER
  Future<List> _fetchUser() async {
    // link api http://leap.crossnet.co.id:8888/user/1/1
    // link localhost -> http://localhost:8888/user/
    final link =
        'http://leap.crossnet.co.id:8888/user/login?username=${_username}&password=${_password}';

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

        return [temp['data']['user_id'], ''];
      }
      else{
        return [null, 'Login Failed'];
      }

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');
      print('login Failed');
      return [null, 'Error Login, Try Again'];
    }
  }

  // API Function
  Future _roleValidate() async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/user/${_user!.data!.userId}/${_user!.data!.roleId}';

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
      // // kasih error kalo dia ga punya akses
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: const Text('Akses ditolak'),
      // ));
      return null;

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');

      print('Error, Try Again');

      // // show snackbar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: const Text('Try Again'),
      // ));
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

      // // ambil data yang ada
      // FetchPrivileges privilegesData = FetchPrivileges.fromJson(temp);

      if (temp['data'].length != 0) {
        // ambil list priviledges
        // return privilegesData.data;
        return null;
      }
      return null;
    } else {
      print('Error, Try Again');
      return null;
    }
  }
}