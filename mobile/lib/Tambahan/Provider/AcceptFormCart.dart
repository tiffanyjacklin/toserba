import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:http/http.dart' as http;

class AcceptFormCart extends ChangeNotifier {
  int _deliveryId = 0;

  AcceptFormCart(int deliveryId, List<deliveryDetail.Data> listData) {
    this._deliveryId = deliveryId;
    _items = listData.toList();
  }

  /// Internal, private state of the cart.
  List<deliveryDetail.Data> _items = [];
  late List<deliveryDetail.Data> _allItemRemaining = [];
  List<TextEditingController> _listInputQuantity = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<deliveryDetail.Data> get items =>
      UnmodifiableListView(_items);

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listControllerInput =>
      UnmodifiableListView(_listInputQuantity);

  // check if empty
  bool get isEmptyCart => _items.isEmpty;

  /// loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool isload) {
    _isLoading = isload;
    notifyListeners();
  }

  // check cart if there is empty input
  bool isThereEmptyField() {
    for (TextEditingController input in _listInputQuantity) {
      if (input.text == '') {
        return true;
      }
    }
    return false;
  }

  // submit the cart
  Future<void> submit(String notes) async {
    //   // panggil lah semua api untuk post + put update
    // _InsertDeliveryOrderDetails(noteId, items, listControllerInput).then(
    //       (result) => {
    //             print('selesai insert ==='),
    //             _UpdateDeliveryOrderDetails(result.first.deliveryOrderId!, 1, notes)
    //           });
  }

  Future<void> _fetchAccepted() async {
    // accept fetch

    // stock card minus (alternative solution)
  }

  Future<bool> _fetchAcceptOrder(int deliveryOrder) async {
    final userId = 1;

    final link =
        'http://leap.crossnet.co.id:8888/store/orders/delivery/accept/$deliveryOrder/$userId'; // NOTE : diganti nanti kalo udah ada

    // call api
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
        return true;
      }
    }
    return false;
  }
}
