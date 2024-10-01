import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/FetchApi/TransferNote+Delivery.dart';
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
// import 'package:flutter_app_all/Model/DeliveryTransferNote.dart';
import 'package:http/http.dart' as http;


class AcceptOrderDeliveryProvider extends ChangeNotifier {
  // init value
  int _deliveryId = 0;
  bool _isAccepted = true;

  AcceptOrderDeliveryProvider(int deliveryId, bool accepted){
    this._deliveryId = deliveryId;
    this._isAccepted = accepted;

    // call the api...
    _fetchDeliveryDetail();
  }

  // >> for filter
  List<DateTime> rangeDate = [DateTime(2000), DateTime.now()];
  String _checkStatus = '';

  // >> for paginator
  int limitPerPage = 4;
  int currentPage = 0;


   /// Internal, private state of the cart.
  List<deliveryDetail.Data> _items = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<deliveryDetail.Data> get items =>
      UnmodifiableListView(_items);


  bool get isAccepted => _isAccepted; 

  /// checker
  bool get isEmpty => _items.isEmpty;

  /// loading state
  bool _isLoading = false;
  int totalRow = 0;

  bool get isLoading => _isLoading;

  set isLoading(bool isload) {
    _isLoading = isload;
    notifyListeners();
  }


  void fillItems(List<deliveryDetail.Data> listData){
    this._items = listData.toList();
    notifyListeners();
  }

  Future<void> _fetchDeliveryDetail() async{
    isLoading = true;

    List<deliveryDetail.Data> result = await fetchDeliveryTransferNotesDetail(this._deliveryId);

    if(result != []){
      this._items = result.toList();
      isLoading = false;
    }
  }

}