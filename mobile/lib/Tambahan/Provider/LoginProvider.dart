import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class AuthState extends ChangeNotifier{

  final keyUserId = 'userId';
  final keyRole = 'roleId';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // this for data?
  // late String _username, _password;
  late String _userId, _roleId;
  Data? _user;
  String errorMessage = '';
  bool showError = false;

  bool displayLoginPage = true;



  Future<void> saveToStorage(String userId2, String roleId2, Data user) async{
    userId = userId2;
    roleId = roleId2;
    _user = user;

    await secureStorage.write(key: keyUserId, value: _userId);
    await secureStorage.write(key: keyRole, value: _roleId);
  }

  set userId(String userId){
    _userId = userId;
  }

  set roleId(String roleId){
    _roleId = roleId;
  }

  void setDisplayLoginPage(bool log){
    displayLoginPage = log;
  }

  Data get userData{
    return _user!;
  }

  bool get isAuthorized{
    if(_user != null){
      return true;
    }
    return false;
  }

  Future<bool> tryLogin() async {
    // cek misal pernah ga dia login?
    _userId = await secureStorage.read(key: keyUserId) ?? '';
    _roleId = await secureStorage.read(key: keyRole) ?? '';

    if(_userId.isEmpty){
      return false;
    }

    // fetch user
    var result = await _roleValidate();
    if(result.first != null){
      _user = result.first;
      setDisplayLoginPage(false);
      return true; // sudah login
    }
    return false;

  }

  void logout(){
    _user = null;
    _userId = '';
    _roleId = '';
    displayLoginPage = true;

    notifyListeners();
  }

  // API Function
  Future<List> _roleValidate() async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/user/$_userId/$_roleId';

    // call api (method GET)
    final response = await http.get(Uri.parse(link));

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      Map<String, dynamic> temp = json.decode(response.body);

      // ambil data yang ada
      FetchUsers userData = FetchUsers.fromJson(temp);

      if (temp['data'].length != 0 && temp['data']['user_id'] != 0) {
        return [userData.data, ''];
      }
      return [null, 'Invalid Login, Try Again'];

    } else {
      return [null, 'Login Failed, Try Again'];
    }
  }
}