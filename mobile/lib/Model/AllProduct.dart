class FetchAllProducts {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  FetchAllProducts({this.status, this.message, this.totalRows, this.data});

  FetchAllProducts.fromJson(Map<String, dynamic> json) {
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
  ProductDetails? productDetails;
  ProductCategories? productCategories;
  Suppliers? suppliers;
  StockOpname? stockOpname;

  Data(
      {this.productDetails,
      this.productCategories,
      this.suppliers,
      this.stockOpname});

  Data.fromJson(Map<String, dynamic> json) {
    productDetails = json['ProductDetails'] != null
        ? new ProductDetails.fromJson(json['ProductDetails'])
        : null;
    productCategories = json['ProductCategories'] != null
        ? new ProductCategories.fromJson(json['ProductCategories'])
        : null;
    suppliers = json['Suppliers'] != null
        ? new Suppliers.fromJson(json['Suppliers'])
        : null;
    stockOpname = json['StockOpname'] != null
        ? new StockOpname.fromJson(json['StockOpname'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.productDetails != null) {
      data['ProductDetails'] = this.productDetails!.toJson();
    }
    if (this.productCategories != null) {
      data['ProductCategories'] = this.productCategories!.toJson();
    }
    if (this.suppliers != null) {
      data['Suppliers'] = this.suppliers!.toJson();
    }
    if (this.stockOpname != null) {
      data['StockOpname'] = this.stockOpname!.toJson();
    }
    return data;
  }
}

class ProductDetails {
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
  bool? checkStock;
  int? productStock;
  String? productUnit;
  String? productTimestamp;
  int? storeWarehouseId;
  String? warehousePlacement;

  ProductDetails(
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
      this.checkStock,
      this.productStock,
      this.productUnit,
      this.productTimestamp,
      this.storeWarehouseId,
      this.warehousePlacement});

  ProductDetails.fromJson(Map<String, dynamic> json) {
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
    checkStock = json['check_stock'];
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
    data['check_stock'] = this.checkStock;
    data['product_stock'] = this.productStock;
    data['product_unit'] = this.productUnit;
    data['product_timestamp'] = this.productTimestamp;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['warehouse_placement'] = this.warehousePlacement;
    return data;
  }
}

class ProductCategories {
  int? productCategoryId;
  String? productCategoryName;

  ProductCategories({this.productCategoryId, this.productCategoryName});

  ProductCategories.fromJson(Map<String, dynamic> json) {
    productCategoryId = json['product_category_id'];
    productCategoryName = json['product_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_category_id'] = this.productCategoryId;
    data['product_category_name'] = this.productCategoryName;
    return data;
  }
}

class Suppliers {
  int? supplierId;
  String? supplierName;
  String? supplierPhoneNumber;
  String? supplierAddress;

  Suppliers(
      {this.supplierId,
      this.supplierName,
      this.supplierPhoneNumber,
      this.supplierAddress});

  Suppliers.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    supplierPhoneNumber = json['supplier_phone_number'];
    supplierAddress = json['supplier_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['supplier_id'] = this.supplierId;
    data['supplier_name'] = this.supplierName;
    data['supplier_phone_number'] = this.supplierPhoneNumber;
    data['supplier_address'] = this.supplierAddress;
    return data;
  }
}

class StockOpname {
  int? stockOpnameId;
  int? productDetailId;
  String? productName;
  String? productCode;
  String? batch;
  String? expiredDate;
  int? expectedStock;
  int? actualStock;
  String? unitType;
  String? timestamp;
  int? storeWarehouseId;
  String? sectionPlacement;

  StockOpname(
      {this.stockOpnameId,
      this.productDetailId,
      this.productName,
      this.productCode,
      this.batch,
      this.expiredDate,
      this.expectedStock,
      this.actualStock,
      this.unitType,
      this.timestamp,
      this.storeWarehouseId,
      this.sectionPlacement});

  StockOpname.fromJson(Map<String, dynamic> json) {
    stockOpnameId = json['stock_opname_id'];
    productDetailId = json['product_detail_id'];
    productName = json['product_name'];
    productCode = json['product_code'];
    batch = json['batch'];
    expiredDate = json['expired_date'];
    expectedStock = json['expected_stock'];
    actualStock = json['actual_stock'];
    unitType = json['unit_type'];
    timestamp = json['timestamp'];
    storeWarehouseId = json['store_warehouse_id'];
    sectionPlacement = json['section_placement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stock_opname_id'] = this.stockOpnameId;
    data['product_detail_id'] = this.productDetailId;
    data['product_name'] = this.productName;
    data['product_code'] = this.productCode;
    data['batch'] = this.batch;
    data['expired_date'] = this.expiredDate;
    data['expected_stock'] = this.expectedStock;
    data['actual_stock'] = this.actualStock;
    data['unit_type'] = this.unitType;
    data['timestamp'] = this.timestamp;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['section_placement'] = this.sectionPlacement;
    return data;
  }
}
