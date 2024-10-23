class FetchUsers {
  int? status;
  String? message;
  int? totalRows;
  Data? data;

  FetchUsers({this.status, this.message, this.totalRows, this.data});

  FetchUsers.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalRows = json['total_rows'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total_rows'] = this.totalRows;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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
  String? userCreatedAt;
  String? userDeletedAt;
  String? userUpdatedAt;
  int? roleId;
  String? rolesName;
  String? userOtp;
  String? otpExp;
  int? storeWarehouseId;
  int? statusActive;
  int? custom;

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
      this.userCreatedAt,
      this.userDeletedAt,
      this.userUpdatedAt,
      this.roleId,
      this.rolesName,
      this.userOtp,
      this.otpExp,
      this.storeWarehouseId,
      this.statusActive,
      this.custom});

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
    userCreatedAt = json['user_created_at'];
    userDeletedAt = json['user_deleted_at'];
    userUpdatedAt = json['user_updated_at'];
    roleId = json['role_id'];
    rolesName = json['roles_name'];
    userOtp = json['user_otp'];
    otpExp = json['otp_exp'];
    storeWarehouseId = json['store_warehouse_id'];
    statusActive = json['status_active'];
    custom = json['custom'];
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
    data['user_created_at'] = this.userCreatedAt;
    data['user_deleted_at'] = this.userDeletedAt;
    data['user_updated_at'] = this.userUpdatedAt;
    data['role_id'] = this.roleId;
    data['roles_name'] = this.rolesName;
    data['user_otp'] = this.userOtp;
    data['otp_exp'] = this.otpExp;
    data['store_warehouse_id'] = this.storeWarehouseId;
    data['status_active'] = this.statusActive;
    data['custom'] = this.custom;
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
