class RolesDefault {
  int? rolesDefaultId;
  int? rolesId;
  int? privilegesId;

  RolesDefault({this.rolesDefaultId, this.rolesId, this.privilegesId});

  RolesDefault.fromJson(Map<String, dynamic> json) {
    rolesDefaultId = json['roles_default_id'];
    rolesId = json['roles_id'];
    privilegesId = json['privileges_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roles_default_id'] = this.rolesDefaultId;
    data['roles_id'] = this.rolesId;
    data['privileges_id'] = this.privilegesId;
    return data;
  }
}