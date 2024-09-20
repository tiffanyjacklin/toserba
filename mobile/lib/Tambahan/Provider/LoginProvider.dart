import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Loginprovider extends ChangeNotifier{

  Loginprovider(){
    fetchFromStorage();
  }

  final keyUsername = 'UName';
  final keyPassword = 'UPassword';

  final _secureStorage = FlutterSecureStorage();
  late String _username, _password;

  Future <bool> isLoggedBefore() async {
    return await _secureStorage.containsKey(key: keyUsername);
  }

  Future<void> fetchFromStorage() async{
    _username = (await _secureStorage.read(key: keyUsername))!;
    _password = (await _secureStorage.read(key: keyPassword))!;
  }
}