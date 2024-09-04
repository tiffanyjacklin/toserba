class FetchDeliveryTransferDetail {
  int? status;
  String? message;
  List<Data>? data;

  FetchDeliveryTransferDetail({this.status, this.message, this.data});

  FetchDeliveryTransferDetail.fromJson(Map<String, dynamic> json) {
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
  int? deliveryOrderDetailId;
  int? deliveryOrderId;
  int? productDetailId;
  String? productName;
  int? quantity;
  String? unitType;
  String? expiredDate;
  String? batch;

  Data(
      {this.deliveryOrderDetailId,
      this.deliveryOrderId,
      this.productDetailId,
      this.productName,
      this.quantity,
      this.unitType,
      this.expiredDate,
      this.batch});

  Data.fromJson(Map<String, dynamic> json) {
    deliveryOrderDetailId = json['delivery_order_detail_id'];
    deliveryOrderId = json['delivery_order_id'];
    productDetailId = json['product_detail_id'];
    productName = json['product_name'];
    quantity = json['quantity'];
    unitType = json['unit_type'];
    expiredDate = json['expired_date'];
    batch = json['batch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery_order_detail_id'] = this.deliveryOrderDetailId;
    data['delivery_order_id'] = this.deliveryOrderId;
    data['product_detail_id'] = this.productDetailId;
    data['product_name'] = this.productName;
    data['quantity'] = this.quantity;
    data['unit_type'] = this.unitType;
    data['expired_date'] = this.expiredDate;
    data['batch'] = this.batch;
    return data;
  }
}
