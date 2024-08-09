class Roles {
  int? rolesId;
  String? rolesName;

  Roles({this.rolesId, this.rolesName});

  Roles.fromJson(Map<String, dynamic> json) {
    rolesId = json['roles_id'];
    rolesName = json['roles_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roles_id'] = this.rolesId;
    data['roles_name'] = this.rolesName;
    return data;
  }
}