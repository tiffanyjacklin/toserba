import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:http/http.dart' as http;

class RouteProvider extends ChangeNotifier {
  late List<DataPrivileges> _priviledge;
  late List<DataPrivileges> _menuPrividges;
  int _indexSidebar = 0;

  set selectMenu(int i) {
    _indexSidebar = i;
    notifyListeners();
  }
  int get selectedMenuIndex => _indexSidebar;

  // List<String> get sidebarMenu {
  //   List<String> result = [];
  //   for (int i = 0; i < _priviledge.length; i++) {
  //     if (_priviledge[i].navbar == 1) {
  //       result.add(_priviledge[i].privilegesName!);
  //     }
  //   }
  //   return result;
  // }

    List<DataPrivileges> get sidebarMenu {
    return _menuPrividges;
  }


  Future<void> fetchPriviledge(int userId, int roleId) async {
    // link api
    final link =
        'http://leap.crossnet.co.id:8888/user/privileges/$userId/$roleId';

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
        _priviledge = privilegesData.data!;
        _menuPrividges = _priviledge.where((i) => i.navbar == 1).toList();
        notifyListeners();
      }
    }
  }
}
