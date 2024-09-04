class StockTransferNotesWarehouse {
  int? status;
  String? message;
  List<Data>? data;

  StockTransferNotesWarehouse({this.status, this.message, this.data});

  StockTransferNotesWarehouse.fromJson(Map<String, dynamic> json) {
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
  int? transferNoteId;
  int? storeWarehouseFrom;
  int? storeWarehouseTo;
  String? createdAt;
  int? statusVerify;
  int? statusSend;
  int? userIdFrom;
  int? quantityTotal;

  Data(
      {this.transferNoteId,
      this.storeWarehouseFrom,
      this.storeWarehouseTo,
      this.createdAt,
      this.statusVerify,
      this.statusSend,
      this.userIdFrom,
      this.quantityTotal});

  Data.fromJson(Map<String, dynamic> json) {
    transferNoteId = json['transfer_note_id'];
    storeWarehouseFrom = json['store_warehouse_from'];
    storeWarehouseTo = json['store_warehouse_to'];
    createdAt = json['created_at'];
    statusVerify = json['status_verify'];
    statusSend = json['status_send'];
    userIdFrom = json['user_id_from'];
    quantityTotal = json['quantity_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transfer_note_id'] = this.transferNoteId;
    data['store_warehouse_from'] = this.storeWarehouseFrom;
    data['store_warehouse_to'] = this.storeWarehouseTo;
    data['created_at'] = this.createdAt;
    data['status_verify'] = this.statusVerify;
    data['status_send'] = this.statusSend;
    data['user_id_from'] = this.userIdFrom;
    data['quantity_total'] = this.quantityTotal;
    return data;
  }
}


