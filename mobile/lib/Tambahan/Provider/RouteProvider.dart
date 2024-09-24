import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:flutter_app_all/Page/Cashier/sessionHistory_page.dart';
import 'package:flutter_app_all/Page/Cashier/session_page.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/accept_order_page.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/inventory_taking_page.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/product_page.dart';
import 'package:flutter_app_all/Page/Umum/notification_page.dart';
import 'package:flutter_app_all/Page/Warehouse%20Employee/history_all_stock_product_page.dart';
import 'package:flutter_app_all/Page/Warehouse%20Employee/stock_transfer_notes_page.dart';
import 'package:flutter_app_all/Page/Warehouse%20Employee/substract_product_page.dart';
import 'package:http/http.dart' as http;

class RouteProvider extends ChangeNotifier {
  List<DataPrivileges> _priviledge = [];
  List<DataPrivileges> _menuPrividges = [];
  int _indexSidebar = 0;

  bool isLoading = true;
  bool alreadyBuild = false;

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

  void buildPriviledges(int userId, int roleId) {
    if (!alreadyBuild) {
      fetchPriviledge(userId, roleId);
      alreadyBuild = false;
    }
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
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Widget getPage() {
    var _mappingRoute = {
      'session': SessionPage(),
      'session history': SessionHistoryPage(),
      'products': ProductPage(),
      'notifications': NotificationPage(),
      'subtract products': SubstractProductPageWithProvider(),
      'stock history': HistoryAllProductPage(),
      'inventory taking': InventoryTakingPageWithProvider(),
      'stock transfer notes': StockTransferNotesPage(),
      'accept order' : AcceptOrderPage() ,
    };

    if (_mappingRoute.containsKey(sidebarMenu[_indexSidebar].privilegesName!.toLowerCase())) {
      return _mappingRoute[sidebarMenu[_indexSidebar].privilegesName!.toLowerCase()]!;
    } 
    else {
      return Container(
        child: Center(
          child: Text('404 Not Found'),
        ),
      );
    }
  }
}


// Expanded(
//                       flex: 1,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: ColorPalleteLogin.OrangeLightColor,
//                           border: Border(
//                             bottom: BorderSide(width: 1, color: Colors.black),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 20, right: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
                             
//                               Container(
//                                 child: Row(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child:
//                                               Icon(Icons.help_outline_outlined),
//                                         ),
//                                         Text(
//                                           'Help',
//                                           style: TextStyle(
//                                               color: ColorPalleteLogin
//                                                   .PrimaryColor,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                     Icon(Icons.notifications_outlined),
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       )),