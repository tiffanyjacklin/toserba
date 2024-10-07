class SubmitSubstractProduct {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  SubmitSubstractProduct(
      {this.status, this.message, this.totalRows, this.data});

  SubmitSubstractProduct.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalRows = json['total_rows'];
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
    data['total_rows'] = this.totalRows;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? subtractStockId;
  int? productDetailId;
  String? batch;
  String? expiredDate;
  int? subtractQuantity;
  int? statusVerify;
  String? notes;
  int? userId;
  int? storeWarehouseId;
  String? storeWarehouseName;
  String? timestamp;

  Data(
      {this.subtractStockId,
      this.productDetailId,
      this.batch,
      this.expiredDate,
      this.subtractQuantity,
      this.statusVerify,
      this.notes,
      this.userId,
      this.storeWarehouseId,
      this.storeWarehouseName,
      this.timestamp});

  Data.fromJson(Map<String, dynamic> json) {
    subtractStockId = json['subtract_stock_id'];
    productDetailId = json['product_detail_id'];
    batch = json['batch'];
    expiredDate = json['expired_date'];
    subtractQuantity = json['subtract_quantity'];
    statusVerify = json['status_verify'];
    notes = json['notes'];
    userId = json['user_id'];
    storeWarehouseId = json['store_warehouse_id'];
    storeWarehouseName = json['store_warehouse_name'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subtract_stock_id'] = this.subtractStockId;
    data['product_detail_id'] = this.productDetailId;
    data['batch'] = this.batch;
    data['expired_date'] = this.expiredDate;
    data['subtract_quantity'] = this.subtractQuantity;
    data['status_verify'] = this.statusVerify;
    data['notes'] = this.notes;
    data['user_id'] = this.userId;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['store_warehouse_name'] = this.storeWarehouseName;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
