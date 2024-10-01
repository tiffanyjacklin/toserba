class RolesPerUser {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  RolesPerUser({this.status, this.message, this.totalRows, this.data});

  RolesPerUser.fromJson(Map<String, dynamic> json) {
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
  int? userRoleId;
  int? userId;
  int? roleId;
  String? rolesName;
  int? storeWarehouseId;
  int? custom;

  Data(
      {this.userRoleId,
      this.userId,
      this.roleId,
      this.rolesName,
      this.storeWarehouseId,
      this.custom});

  Data.fromJson(Map<String, dynamic> json) {
    userRoleId = json['user_role_id'];
    userId = json['user_id'];
    roleId = json['role_id'];
    rolesName = json['roles_name'];
    storeWarehouseId = json['store_warehouse_id'];
    custom = json['custom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_role_id'] = this.userRoleId;
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    data['roles_name'] = this.rolesName;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['custom'] = this.custom;
    return data;
  }
}
