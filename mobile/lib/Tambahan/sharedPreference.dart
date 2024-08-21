// import 'dart:developer';
// import 'dart:ffi';

// import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences? sharedPreferences;

// Future<void> initSharedPreferences() async {
//   sharedPreferences = await SharedPreferences.getInstance();
// }

// Future<void> saveData(int username) async {
//   await sharedPreferences?.setInt("user_id", username).then((onValue) => {
//     sharedPreferences?.setInt("", value)
//   });
// }

// Int? getUsername() {
//   return sharedPreferences?.getInt("user_id");
// }

// Future<void> main() async {
//   await initSharedPreferences();
//   await saveUsername("tamilKannancv");
//   final String? username = getUsername();
//   log(username.toString());
// }