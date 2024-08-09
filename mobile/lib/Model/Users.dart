class Users {
  int? userId;
  String? username;
  String? userPassword;
  String? userFullname;
  String? userAddress;
  String? userGender;
  String? userBirthdate;
  String? userEmail;
  String? userPhoneNumber;
  Null? userPhotoProfile;
  String? userCreatedAt;
  Null? userDeletedAt;
  Null? userUpdatedAt;
  Null? userLoginTimestamp;

  Users(
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
      this.userCreatedAt,
      this.userDeletedAt,
      this.userUpdatedAt,
      this.userLoginTimestamp});

  Users.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    userPassword = json['user_password'];
    userFullname = json['user_fullname'];
    userAddress = json['user_address'];
    userGender = json['user_gender'];
    userBirthdate = json['user_birthdate'];
    userEmail = json['user_email'];
    userPhoneNumber = json['user_phone_number'];
    userPhotoProfile = json['user_photo_profile'];
    userCreatedAt = json['user_created_at'];
    userDeletedAt = json['user_deleted_at'];
    userUpdatedAt = json['user_updated_at'];
    userLoginTimestamp = json['user_login_timestamp'];
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
    data['user_photo_profile'] = this.userPhotoProfile;
    data['user_created_at'] = this.userCreatedAt;
    data['user_deleted_at'] = this.userDeletedAt;
    data['user_updated_at'] = this.userUpdatedAt;
    data['user_login_timestamp'] = this.userLoginTimestamp;
    return data;
  }
}
