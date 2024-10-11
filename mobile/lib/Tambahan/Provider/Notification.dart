import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/NotificationsByRoles.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends ChangeNotifier{

  // >> fetch purpose
  bool _isLoading = true;
  List<Data> _listNotification = [];
  bool get isLoading => _isLoading;

  UnmodifiableListView<Data> get listNotification =>
      UnmodifiableListView(_listNotification);

  Future<void> fetchNotificationsProvider(int roleId , int userId) async {
    // /notifications/:role_id/:user_id/:notification_type_id/:start_date/:end_date/:limit/:offset
    final link =
        'http://leap.crossnet.co.id:8888/notifications/$roleId/$userId////0/0'; // NOTE : diganti nanti kalo udah ada

    _isLoading = true;
    notifyListeners();

    // call api
    final response = await http.get(Uri.parse(link));
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
        _listNotification = FetchNotifications.fromJson(temp).data!;
        print("hasil panjang list --> ${_listNotification.length}");
      } else {
        _listNotification = [];
      }
    } else {
      print('fetch failed');
      _listNotification = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
