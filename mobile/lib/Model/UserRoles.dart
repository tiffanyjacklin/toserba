class UserRoles {
  int? userRolesId;
  int? userId;
  int? rolesId;
  int? custom;

  UserRoles({this.userRolesId, this.userId, this.rolesId, this.custom});

  UserRoles.fromJson(Map<String, dynamic> json) {
    userRolesId = json['user_roles_id'];
    userId = json['user_id'];
    rolesId = json['roles_id'];
    custom = json['custom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_roles_id'] = this.userRolesId;
    data['user_id'] = this.userId;
    data['roles_id'] = this.rolesId;
    data['custom'] = this.custom;
    return data;
  }
}