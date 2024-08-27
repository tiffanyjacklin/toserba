import 'dart:collection';

import 'package:flutter/cupertino.dart';

class FetchAllHistoryProductWarehouse {
  int? status;
  String? message;
  List<Data>? data;

  FetchAllHistoryProductWarehouse({this.status, this.message, this.data});

  FetchAllHistoryProductWarehouse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? stockOpnameId;
  int? productDetailId;
  String? productName;
  String? batch;
  String? expiredDate;
  int? expectedStock;
  int? actualStock;
  String? unitType;
  String? timestamp;
  int? storeWarehouseId;

  Data(
      {this.stockOpnameId,
      this.productDetailId,
      this.productName,
      this.batch,
      this.expiredDate,
      this.expectedStock,
      this.actualStock,
      this.unitType,
      this.timestamp,
      this.storeWarehouseId});

  Data.fromJson(Map<String, dynamic> json) {
    stockOpnameId = json['stock_opname_id'];
    productDetailId = json['product_detail_id'];
    productName = json['product_name'];
    batch = json['batch'];
    expiredDate = json['expired_date'];
    expectedStock = json['expected_stock'];
    actualStock = json['actual_stock'];
    unitType = json['unit_type'];
    timestamp = json['timestamp'];
    storeWarehouseId = json['store_warehouse_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stock_opname_id'] = this.stockOpnameId;
    data['product_detail_id'] = this.productDetailId;
    data['product_name'] = this.productName;
    data['batch'] = this.batch;
    data['expired_date'] = this.expiredDate;
    data['expected_stock'] = this.expectedStock;
    data['actual_stock'] = this.actualStock;
    data['unit_type'] = this.unitType;
    data['timestamp'] = this.timestamp;
    data['store_warehouse_id'] = this.storeWarehouseId;
    return data;
  }
}


// TAMBAHAN
class ListHistoryProductWarehouse extends ChangeNotifier {
  final List<Data> _listHistoryStockProduct = [];

  // Unmodifiale?
  UnmodifiableListView<Data> get listHistoryStockProduct => UnmodifiableListView(_listHistoryStockProduct);

  // get current length
  int get itemCount => _listHistoryStockProduct.length;

  // refresh the item?
  void resetAll(){

  }
}
