import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Loginprovider extends ChangeNotifier{

  Loginprovider(){
    fetchFromStorage();
  }

  final keyUsername = 'UName';
  final keyPassword = 'UPassword';

  final _secureStorage = FlutterSecureStorage();

  // this for data?
  late String _username, _password;
  late FetchUsers _users;


  bool wasLogged(){
    if(_username.isNotEmpty && _password.isNotEmpty){
      return true;
    }
    return false;
  }  
  
  Future <bool> isLoggedBefore() async {
    return await _secureStorage.containsKey(key: keyUsername);
  }

  Future<void> fetchFromStorage() async{
    _username = (await _secureStorage.read(key: keyUsername))!;
    _password = (await _secureStorage.read(key: keyPassword))!;
  }
}