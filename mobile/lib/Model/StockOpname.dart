class FetchStockOpnameWarehouse {
  int? status;
  String? message;
  List<Data>? data;

  FetchStockOpnameWarehouse({this.status, this.message, this.data});

  FetchStockOpnameWarehouse.fromJson(Map<String, dynamic> json) {
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
