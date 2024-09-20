class FetchStockDescription {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  FetchStockDescription({this.status, this.message, this.totalRows, this.data});

  FetchStockDescription.fromJson(Map<String, dynamic> json) {
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
  int? stockDescriptionId;
  String? stockDescription;

  Data({this.stockDescriptionId, this.stockDescription});

  Data.fromJson(Map<String, dynamic> json) {
    stockDescriptionId = json['stock_description_id'];
    stockDescription = json['stock_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stock_description_id'] = this.stockDescriptionId;
    data['stock_description'] = this.stockDescription;
    return data;
  }
}
