class AllSortProduct {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  AllSortProduct({this.status, this.message, this.totalRows, this.data});

  AllSortProduct.fromJson(Map<String, dynamic> json) {
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
  int? sortId;
  String? sortType;

  Data({this.sortId, this.sortType});

  Data.fromJson(Map<String, dynamic> json) {
    sortId = json['sort_id'];
    sortType = json['sort_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sort_id'] = this.sortId;
    data['sort_type'] = this.sortType;
    return data;
  }
}

