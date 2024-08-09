class Privileges {
  int? privilegesId;
  String? privilegesName;

  Privileges({this.privilegesId, this.privilegesName});

  Privileges.fromJson(Map<String, dynamic> json) {
    privilegesId = json['privileges_id'];
    privilegesName = json['privileges_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['privileges_id'] = this.privilegesId;
    data['privileges_name'] = this.privilegesName;
    return data;
  }
}