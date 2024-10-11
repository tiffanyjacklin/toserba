class UpdateDeliveryOrder {
  int? status;
  String? message;
  int? totalRows;
  Data? data;

  UpdateDeliveryOrder({this.status, this.message, this.totalRows, this.data});

  UpdateDeliveryOrder.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalRows = json['total_rows'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total_rows'] = this.totalRows;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? deliveryOrderId;
  int? storeWarehouseFrom;
  int? storeWarehouseTo;
  String? orderTimestamp;
  String? acceptTimestamp;
  int? statusAccept;
  int? userIdFrom;
  int? userIdTo;
  int? transferNoteId;
  int? quantityTotal;
  String? notes;

  Data(
      {this.deliveryOrderId,
      this.storeWarehouseFrom,
      this.storeWarehouseTo,
      this.orderTimestamp,
      this.acceptTimestamp,
      this.statusAccept,
      this.userIdFrom,
      this.userIdTo,
      this.transferNoteId,
      this.quantityTotal,
      this.notes});

  Data.fromJson(Map<String, dynamic> json) {
    deliveryOrderId = json['delivery_order_id'];
    storeWarehouseFrom = json['store_warehouse_from'];
    storeWarehouseTo = json['store_warehouse_to'];
    orderTimestamp = json['order_timestamp'];
    acceptTimestamp = json['accept_timestamp'];
    statusAccept = json['status_accept'];
    userIdFrom = json['user_id_from'];
    userIdTo = json['user_id_to'];
    transferNoteId = json['transfer_note_id'];
    quantityTotal = json['quantity_total'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery_order_id'] = this.deliveryOrderId;
    data['store_warehouse_from'] = this.storeWarehouseFrom;
    data['store_warehouse_to'] = this.storeWarehouseTo;
    data['order_timestamp'] = this.orderTimestamp;
    data['accept_timestamp'] = this.acceptTimestamp;
    data['status_accept'] = this.statusAccept;
    data['user_id_from'] = this.userIdFrom;
    data['user_id_to'] = this.userIdTo;
    data['transfer_note_id'] = this.transferNoteId;
    data['quantity_total'] = this.quantityTotal;
    data['notes'] = this.notes;
    return data;
  }
}
