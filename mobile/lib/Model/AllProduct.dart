class FetchAllProduct {
  int? status;
  String? message;
  List<Data>? data;

  FetchAllProduct({this.status, this.message, this.data});

  FetchAllProduct.fromJson(Map<String, dynamic> json) {
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
  int? productDetailId;
  String? productCode;
  int? productCategoryId;
  String? productName;
  int? supplierId;
  String? productBatch;
  int? buyPrice;
  int? sellPrice;
  String? expiryDate;
  int? minStock;
  int? productStock;
  String? productUnit;
  String? productTimestamp;
  int? storeWarehouseId;
  String? warehousePlacement;

  Data(
      {this.productDetailId,
      this.productCode,
      this.productCategoryId,
      this.productName,
      this.supplierId,
      this.productBatch,
      this.buyPrice,
      this.sellPrice,
      this.expiryDate,
      this.minStock,
      this.productStock,
      this.productUnit,
      this.productTimestamp,
      this.storeWarehouseId,
      this.warehousePlacement});

  Data.fromJson(Map<String, dynamic> json) {
    productDetailId = json['product_detail_id'];
    productCode = json['product_code'];
    productCategoryId = json['product_category_id'];
    productName = json['product_name'];
    supplierId = json['supplier_id'];
    productBatch = json['product_batch'];
    buyPrice = json['buy_price'];
    sellPrice = json['sell_price'];
    expiryDate = json['expiry_date'];
    minStock = json['min_stock'];
    productStock = json['product_stock'];
    productUnit = json['product_unit'];
    productTimestamp = json['product_timestamp'];
    storeWarehouseId = json['store_warehouse_id'];
    warehousePlacement = json['warehouse_placement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_detail_id'] = this.productDetailId;
    data['product_code'] = this.productCode;
    data['product_category_id'] = this.productCategoryId;
    data['product_name'] = this.productName;
    data['supplier_id'] = this.supplierId;
    data['product_batch'] = this.productBatch;
    data['buy_price'] = this.buyPrice;
    data['sell_price'] = this.sellPrice;
    data['expiry_date'] = this.expiryDate;
    data['min_stock'] = this.minStock;
    data['product_stock'] = this.productStock;
    data['product_unit'] = this.productUnit;
    data['product_timestamp'] = this.productTimestamp;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['warehouse_placement'] = this.warehousePlacement;
    return data;
  }
}
