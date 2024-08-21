class FetchPrivileges {
  int? status;
  String? message;
  List<DataPrivileges>? data;

  FetchPrivileges({this.status, this.message, this.data});

  FetchPrivileges.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DataPrivileges>[];
      json['data'].forEach((v) {
        data!.add(new DataPrivileges.fromJson(v));
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

class DataPrivileges {
  int? userPrivilegeId;
  int? roleId;
  int? privilegeId;
  String? privilegesName;
  int? navbar;

  DataPrivileges(
      {this.userPrivilegeId,
      this.roleId,
      this.privilegeId,
      this.privilegesName,
      this.navbar});

  DataPrivileges.fromJson(Map<String, dynamic> json) {
    userPrivilegeId = json['user_privilege_id'];
    roleId = json['role_id'];
    privilegeId = json['privilege_id'];
    privilegesName = json['privileges_name'];
    navbar = json['navbar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_privilege_id'] = this.userPrivilegeId;
    data['role_id'] = this.roleId;
    data['privilege_id'] = this.privilegeId;
    data['privileges_name'] = this.privilegesName;
    data['navbar'] = this.navbar;
    return data;
  }
}
