class AllCategory {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  AllCategory({this.status, this.message, this.totalRows, this.data});

  AllCategory.fromJson(Map<String, dynamic> json) {
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
  int? productCategoryId;
  String? productCategoryName;

  Data({this.productCategoryId, this.productCategoryName});

  Data.fromJson(Map<String, dynamic> json) {
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
