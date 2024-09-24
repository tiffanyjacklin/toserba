import 'package:flutter/cupertino.dart';

class LoginProvider extends ChangeNotifier{
  var _chooseRole = false;

  set chooseRole(bool hasil) {
    _chooseRole = hasil;
    notifyListeners();
  }

  bool get isChooseRole{
    return _chooseRole;
  }
}