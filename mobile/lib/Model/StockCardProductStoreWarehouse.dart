class FetchStockCardProductStoreWarehouse {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  FetchStockCardProductStoreWarehouse(
      {this.status, this.message, this.totalRows, this.data});

  FetchStockCardProductStoreWarehouse.fromJson(Map<String, dynamic> json) {
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
  int? stockCardId;
  int? productDetailId;
  String? stockDate;
  String? stockDescription;
  String? productName;
  String? productBatch;
  int? productStock;
  String? productUnit;
  String? expiredDate;
  int? stockIn;
  int? stockOut;
  int? storeWarehouseId;
  int? totalStock;

  Data(
      {this.stockCardId,
      this.productDetailId,
      this.stockDate,
      this.stockDescription,
      this.productName,
      this.productBatch,
      this.productStock,
      this.productUnit,
      this.expiredDate,
      this.stockIn,
      this.stockOut,
      this.storeWarehouseId,
      this.totalStock});

  Data.fromJson(Map<String, dynamic> json) {
    stockCardId = json['stock_card_id'];
    productDetailId = json['product_detail_id'];
    stockDate = json['stock_date'];
    stockDescription = json['stock_description'];
    productName = json['product_name'];
    productBatch = json['product_batch'];
    productStock = json['product_stock'];
    productUnit = json['product_unit'];
    expiredDate = json['expired_date'];
    stockIn = json['stock_in'];
    stockOut = json['stock_out'];
    storeWarehouseId = json['store_warehouse_id'];
    totalStock = json['total_stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stock_card_id'] = this.stockCardId;
    data['product_detail_id'] = this.productDetailId;
    data['stock_date'] = this.stockDate;
    data['stock_description'] = this.stockDescription;
    data['product_name'] = this.productName;
    data['product_batch'] = this.productBatch;
    data['product_stock'] = this.productStock;
    data['product_unit'] = this.productUnit;
    data['expired_date'] = this.expiredDate;
    data['stock_in'] = this.stockIn;
    data['stock_out'] = this.stockOut;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['total_stock'] = this.totalStock;
    return data;
  }
}
