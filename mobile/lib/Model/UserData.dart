class FetchUsers {
  int? status;
  String? message;
  List<Data>? data;

  FetchUsers({this.status, this.message, this.data});

  FetchUsers.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? userId;
  String? username;
  String? userPassword;
  String? userFullname;
  String? userAddress;
  String? userGender;
  String? userBirthdate;
  String? userEmail;
  String? userPhoneNumber;
  UserPhotoProfile? userPhotoProfile;
  UserPhotoProfile? userLoginTimestamp;
  int? roleId;
  String? rolesName;

  Data(
      {this.userId,
      this.username,
      this.userPassword,
      this.userFullname,
      this.userAddress,
      this.userGender,
      this.userBirthdate,
      this.userEmail,
      this.userPhoneNumber,
      this.userPhotoProfile,
      this.userLoginTimestamp,
      this.roleId,
      this.rolesName});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    userPassword = json['user_password'];
    userFullname = json['user_fullname'];
    userAddress = json['user_address'];
    userGender = json['user_gender'];
    userBirthdate = json['user_birthdate'];
    userEmail = json['user_email'];
    userPhoneNumber = json['user_phone_number'];
    userPhotoProfile = json['user_photo_profile'] != null
        ? new UserPhotoProfile.fromJson(json['user_photo_profile'])
        : null;
    userLoginTimestamp = json['user_login_timestamp'] != null
        ? new UserPhotoProfile.fromJson(json['user_login_timestamp'])
        : null;
    roleId = json['role_id'];
    rolesName = json['roles_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['username'] = this.username;
    data['user_password'] = this.userPassword;
    data['user_fullname'] = this.userFullname;
    data['user_address'] = this.userAddress;
    data['user_gender'] = this.userGender;
    data['user_birthdate'] = this.userBirthdate;
    data['user_email'] = this.userEmail;
    data['user_phone_number'] = this.userPhoneNumber;
    if (this.userPhotoProfile != null) {
      data['user_photo_profile'] = this.userPhotoProfile!.toJson();
    }
    if (this.userLoginTimestamp != null) {
      data['user_login_timestamp'] = this.userLoginTimestamp!.toJson();
    }
    data['role_id'] = this.roleId;
    data['roles_name'] = this.rolesName;
    return data;
  }
}

class UserPhotoProfile {
  String? string;
  bool? valid;

  UserPhotoProfile({this.string, this.valid});

  UserPhotoProfile.fromJson(Map<String, dynamic> json) {
    string = json['String'];
    valid = json['Valid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['String'] = this.string;
    data['Valid'] = this.valid;
    return data;
  }
}
