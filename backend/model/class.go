package model

import "database/sql"

type Response struct {
	Status  int         `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

type User struct {
	UserId int `json:"user_id"`
	Username string `json:"username"`
	Password string `json:"user_password"`
}

type UserData struct {
	UserId int `json:"user_id"`
	Username string `json:"username"`
	Password string `json:"user_password"`
	UserFullName string `json:"user_fullname"`
	UserAddress string `json:"user_address"`
	UserGender string `json:"user_gender"`
	UserBirthDate string `json:"user_birthdate"`
	UserEmail string `json:"user_email"`
	UserPhoneNumber string `json:"user_phone_number"`
	UserPhotoProfile sql.NullString `json:"user_photo_profile"`
	LoginTimestamp sql.NullString `json:"user_login_timestamp"`
	RoleId int `json:"role_id"` 
	RoleName string `json:"roles_name"`
}

type UserRoles struct {
	UserRoleId int `json:"user_role_id"`
	UserId int `json:"user_id"`
	RoleId int `json:"role_id"`
	RoleName string `json:"roles_name"`
	StoreId sql.NullInt32 `json:"store_id"`
	WarehouseId sql.NullInt32 `json:"warehouse_id"`
	Custom int `json:"custom"`
}

type UserPrivilege struct {
	UserPrivilegeId int `json:"user_privilege_id"`
	RoleId int `json:"role_id"`
	PrivilegeId int `json:"privilege_id"`
	PrivilegeName string `json:"privileges_name"`
	Navbar int `json:"navbar"`
}