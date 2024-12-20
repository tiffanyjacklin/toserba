class StockTransferNotesDetailWarehouse {
  int? status;
  String? message;
  List<Data>? data;

  StockTransferNotesDetailWarehouse({this.status, this.message, this.data});

  StockTransferNotesDetailWarehouse.fromJson(Map<String, dynamic> json) {
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
  int? transferNoteDetailId;
  int? transferNoteId;
  int? productDetailId;
  String? productName;
  String? batch;
  String? expiredDate;
  int? quantity;
  String? unitType;
  int? remainingQuantity;

  Data(
      {this.transferNoteDetailId,
      this.transferNoteId,
      this.productDetailId,
      this.productName,
      this.batch,
      this.expiredDate,
      this.quantity,
      this.unitType,
      this.remainingQuantity});

  Data.fromJson(Map<String, dynamic> json) {
    transferNoteDetailId = json['transfer_note_detail_id'];
    transferNoteId = json['transfer_note_id'];
    productDetailId = json['product_detail_id'];
    productName = json['product_name'];
    batch = json['batch'];
    expiredDate = json['expired_date'];
    quantity = json['quantity'];
    unitType = json['unit_type'];
    remainingQuantity = json['remaining_quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transfer_note_detail_id'] = this.transferNoteDetailId;
    data['transfer_note_id'] = this.transferNoteId;
    data['product_detail_id'] = this.productDetailId;
    data['product_name'] = this.productName;
    data['batch'] = this.batch;
    data['expired_date'] = this.expiredDate;
    data['quantity'] = this.quantity;
    data['unit_type'] = this.unitType;
    data['remaining_quantity'] = this.remainingQuantity;
    return data;
  }
}
