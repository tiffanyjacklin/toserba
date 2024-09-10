class FetchNotifications {
  int? status;
  String? message;
  int? totalRows;
  List<Data>? data;

  FetchNotifications({this.status, this.message, this.totalRows, this.data});

  FetchNotifications.fromJson(Map<String, dynamic> json) {
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
  Notifications? notifications;
  UserData? userData;

  Data({this.notifications, this.userData});

  Data.fromJson(Map<String, dynamic> json) {
    notifications = json['Notifications'] != null
        ? new Notifications.fromJson(json['Notifications'])
        : null;
    userData = json['UserData'] != null
        ? new UserData.fromJson(json['UserData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notifications != null) {
      data['Notifications'] = this.notifications!.toJson();
    }
    if (this.userData != null) {
      data['UserData'] = this.userData!.toJson();
    }
    return data;
  }
}

class Notifications {
  int? notificationId;
  int? notificationTypeId;
  int? userId;
  int? rolesId;
  String? notificationTypeName;
  String? timestamp;
  String? description;

  Notifications(
      {this.notificationId,
      this.notificationTypeId,
      this.userId,
      this.rolesId,
      this.notificationTypeName,
      this.timestamp,
      this.description});

  Notifications.fromJson(Map<String, dynamic> json) {
    notificationId = json['notification_id'];
    notificationTypeId = json['notification_type_id'];
    userId = json['user_id'];
    rolesId = json['roles_id'];
    notificationTypeName = json['notification_type_name'];
    timestamp = json['timestamp'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notification_id'] = this.notificationId;
    data['notification_type_id'] = this.notificationTypeId;
    data['user_id'] = this.userId;
    data['roles_id'] = this.rolesId;
    data['notification_type_name'] = this.notificationTypeName;
    data['timestamp'] = this.timestamp;
    data['description'] = this.description;
    return data;
  }
}

class UserData {
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
  String? userOtp;
  String? otpExp;
  int? storeWarehouseId;

  UserData(
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
      this.rolesName,
      this.userOtp,
      this.otpExp,
      this.storeWarehouseId});

  UserData.fromJson(Map<String, dynamic> json) {
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
    userOtp = json['user_otp'];
    otpExp = json['otp_exp'];
    storeWarehouseId = json['store_warehouse_id'];
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
    data['user_otp'] = this.userOtp;
    data['otp_exp'] = this.otpExp;
    data['store_warehouse_id'] = this.storeWarehouseId;
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
