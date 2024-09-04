class StoreWarehouseByUser {
  int? status;
  String? message;
  Data? data;

  StoreWarehouseByUser({this.status, this.message, this.data});

  StoreWarehouseByUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? storeWarehouseId;
  String? storeWarehouseType;
  String? storeWarehouseName;
  String? storeWarehouseAddress;
  String? storeWarehousePhoneNumber;

  Data(
      {this.storeWarehouseId,
      this.storeWarehouseType,
      this.storeWarehouseName,
      this.storeWarehouseAddress,
      this.storeWarehousePhoneNumber});

  Data.fromJson(Map<String, dynamic> json) {
    storeWarehouseId = json['store_warehouse_id'];
    storeWarehouseType = json['store_warehouse_type'];
    storeWarehouseName = json['store_warehouse_name'];
    storeWarehouseAddress = json['store_warehouse_address'];
    storeWarehousePhoneNumber = json['store_warehouse_phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['store_warehouse_type'] = this.storeWarehouseType;
    data['store_warehouse_name'] = this.storeWarehouseName;
    data['store_warehouse_address'] = this.storeWarehouseAddress;
    data['store_warehouse_phone_number'] = this.storeWarehousePhoneNumber;
    return data;
  }
}


// coba json
var jsonUserStoreWarehouse = {
"status": 200,
"message": "Berhasil",
"data": {
"store_warehouse_id": 1,
"store_warehouse_type": "STORE",
"store_warehouse_name": "Toko ABC",
"store_warehouse_address": "Jl. Jeruk Busuk No. 12, Surabaya",
"store_warehouse_phone_number": "081555666888"
}
};