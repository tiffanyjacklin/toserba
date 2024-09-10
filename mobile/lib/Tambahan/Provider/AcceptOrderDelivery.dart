import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/FetchApi/TransferNote+Delivery.dart';

import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:flutter_app_all/Model/DeliveryTransferNote.dart';


class AcceptOrderDeliveryProvider extends ChangeNotifier {
  // init value
  int _deliveryId = 0;

  AcceptOrderDeliveryProvider(int deliveryId){
    this._deliveryId = deliveryId;

    // call the api...
    _fetchDeliveryDetail();
  }

   /// Internal, private state of the cart.
  List<deliveryDetail.Data> _items = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<deliveryDetail.Data> get items =>
      UnmodifiableListView(_items);

  /// checker
  bool get isEmpty => _items.isEmpty;

    /// loading state
  bool _isLoading = false;
  
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