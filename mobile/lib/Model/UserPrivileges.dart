class UserPrivileges {
  int? userPrivilegesId;
  int? privilegesId;
  int? userId;

  UserPrivileges({this.userPrivilegesId, this.privilegesId, this.userId});

  UserPrivileges.fromJson(Map<String, dynamic> json) {
    userPrivilegesId = json['user_privileges_id'];
    privilegesId = json['privileges_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_privileges_id'] = this.userPrivilegesId;
    data['privileges_id'] = this.privilegesId;
    data['user_id'] = this.userId;
    return data;
  }
}