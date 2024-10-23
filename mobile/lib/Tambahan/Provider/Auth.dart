import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthState extends ChangeNotifier {
  final keyUserId = 'userId';
  final keyRole = 'roleId';
  final keyLoginDate = 'dateLogin';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // this for data?
  // late String _username, _password;
  late String _userId, _roleId, _dateLogin;
  Data? _user;
  String errorMessage = '';
  bool showError = false;

  bool displayLoginPage = true;

  Future<void> saveToStorage(String userId2, String roleId2, Data? user) async {
    userId = userId2;
    roleId = roleId2;

    _user = user;
    _dateLogin = DateTime.now().toLocal().toString();

    await secureStorage.write(key: keyUserId, value: _userId);
    await secureStorage.write(key: keyRole, value: _roleId);
    await secureStorage.write(key: keyLoginDate, value: _dateLogin);
  }

  set userId(String userId) {
    _userId = userId;
  }

  set roleId(String roleId) {
    _roleId = roleId;
  }

  void setDisplayLoginPage(bool log) {
    displayLoginPage = log;
    notifyListeners();
  }

  String get userId {
    return _userId;
  }

  String get roleId {
    return _roleId;
  }

  Data get userData {
    return _user!;
  }

  bool get isAuthorized {
    if (_user != null) {
      return true;
    }
    return false;
  }

  Future<bool> tryLogin() async {
    // cek misal pernah ga dia login?
    _userId = await secureStorage.read(key: keyUserId) ?? '';
    _roleId = await secureStorage.read(key: keyRole) ?? '';
    _dateLogin = await secureStorage.read(key: keyLoginDate) ?? '';

    if (_userId.isEmpty) {
      return false;
    }

    // GET INFO DEVICE GA ISAAAAA
    // var result2 = await getId();
    // print(result2);

    // fetch user
    var result = await _roleValidate();
    if (result.first != null) {
      _user = result.first;
      var resultNotif = await notificationLoginNoInput();

      if (resultNotif) {
        setDisplayLoginPage(false);
        return true; // sudah login
      } else {
        return false;
      }
    }
    return false;
  }

  void logout() {
    notificationLoginNoInput(isLogin: false).then((onValue) {
      if (onValue) {
        _user = null;
        _userId = '';
        _roleId = '';
        _dateLogin = '';

        saveToStorage(_userId, _roleId, _user).then((onValue) => {
              displayLoginPage = true,
              notifyListeners(),
            });
      } else {
        print('Try Again');
      }
    });
  }


  // Future<String> getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) { // import 'dart:io'
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor.toString(); // unique ID on iOS
  //   } else if(Platform.isAndroid) {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     print(androidDeviceInfo.brand + androidDeviceInfo.device);
  //     return androidDeviceInfo.brand + '--' + androidDeviceInfo.device; // unique ID on Android
  //   }
  //   return 'false';
  // }

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

  // e.POST("/notifications/add", controller.InsertNotification)
// {
//     "user_id": 1,
//     "roles_id": 1,
//     "description": "Transaksi baru bos",
//     "notification_type_id": 11
// }

//  // buat isi nya dulu
//     List<Map<String, dynamic>> bodyContent = List.generate(
//       _cartItems.length,
//       (i) => {
//             "product_detail_id": _cartItems[i].productDetailId,
//             "batch": _cartItems[i].batch,
//             "subtract_quantity": int.parse(_listInputQuantity[i].text),
//             "expired_date":
//                 '${getOnlyDateSQL(_cartItems[i].expiredDate!)}', //   "2024-08-20",
//             "notes": _listNotes[i].text,
//           });

  // // fetch notif
  // Future <bool> _notificationLogin(int userId, int roleId ,String roleName, {bool isLogout = false}) async {
  //   // link api
  //   final link = 'http://leap.crossnet.co.id:8888/notifications/add';

  //   if(isLogout){}
  //   else{
  //   // json
  //   Map<String,dynamic> jsonBody ={
  //   "user_id": userId,
  //   "roles_id": roleId,
  //   "description": "User ID ${userId} login Mobile sebagai ${roleName} pada ${DateTime.now().toLocal().toString()}",
  //   "notification_type_id": 13 // id for login
  //   };
  //   }

  //   // call api (method POST)
  //   final response = await http.post(Uri.parse(link), body: json.encode(jsonBody));

  //   // cek status
  //   if (response.statusCode == 200) {
  //     return true;

  //   } else {
  //     return false;
  //   }
  // }
  // fetch notif
  Future<bool> notificationLoginNoInput({bool isLogin = true}) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/notifications/add';

    Map<String, dynamic> jsonBody;
    if (isLogin) {
      // json
      jsonBody = {
        "user_id": userData.userId,
        "roles_id": userData.roleId,
        "description":
            "User ID ${userData.userId!} login mobile sebagai ${userData.rolesName} pada ${DateTime.now().toLocal().toString()}",
        "notification_type_id": 13 // id for login
      };
    } else {
      // json
      jsonBody = {
        "user_id": userData.userId,
        "roles_id": userData.roleId,
        "description":
            "User ID ${userData.userId!} logout mobile pada ${DateTime.now().toLocal().toString()}",
        "notification_type_id": 13 // id for login
      };
    }

    // call api (method POST)
    final response =
        await http.post(Uri.parse(link), body: json.encode(jsonBody));

    print(response.body);
    // cek status
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
