package model

import "database/sql"

type Response struct {
	Status  int         `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

type OTPRequest struct {
	OTP string `json:"user_otp"`
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
	UserOTP string `json:"user_otp"`
	OTPExp string `json:"otp_exp"`
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

type Roles struct {
	RolesId int `json:"roles_id"`
	RolesName string `json:"roles_name"`
}

type Privileges struct {
	PrivilegesId int `json:"privileges_id"`
	PrivilegesName string `json:"privileges_name"`
	Navbar int `json:"navbar"`
}

type RolesDefault struct {
	RoleDefaultId int `json:"roles_default_id"`
	RolesId int `json:"roles_id"`
	PrivilegesId int `json:"privileges_id"`
}

type UserPrivilege struct {
	UserPrivilegeId int `json:"user_privilege_id"`
	RoleId int `json:"role_id"`
	PrivilegeId int `json:"privilege_id"`
	PrivilegeName string `json:"privileges_name"`
	Navbar int `json:"navbar"`
}

type Session struct {
	SessionId int `json:"session_id"`
	UserId int `json:"user_id"`
	StartTime string `json:"start_time"`
	EndTime string `json:"end_time"`
	LastUpdateTime string `json:"last_update_time"`
	OpeningCash int `json:"opening_cash"`
	TotalIncome int `json:"total_income"`
	ExpectedClosingCash int `json:"expected_closing_cash"`
	ActualClosingCash int `json:"actual_closing_cash"`
	ActualDifference int `json:"actual_difference"`
	DepositMoney int `json:"deposit_money"`
	DepositDifference int `json:"deposit_difference"`
	OpeningNotes string `json:"opening_notes"`
	ClosingNotes string `json:"closing_notes"`
}

type Members struct {
	MemberId int `json:"member_id"`
	MemberName string `json:"member_name"`
	MemberPhoneNumber string `json:"member_phone_number"`
	MemberPoints int `json:"member_points"`
	MemberJoinDate string `json:"member_join_date"`
}

type ProductCategories struct {
	ProductCategoryId int `json:"product_category_id"`
	ProductCategoryName string `json:"product_category_name"`
}

type ProductDetails struct {
	ProductDetailId int `json:"product_detail_id"`
	ProductCode string `json:"product_code"`
	ProductCategoryId int `json:"product_category_id"`
	ProductName string `json:"product_name"`
	SupplierId int `json:"supplier_id"`
	ProductBatch int `json:"product_batch"`
	BuyPrice int `json:"buy_price"`
	SellPrice int `json:"sell_price"`
	ExpiryDate string `json:"expiry_date"`
	MinStock int `json:"min_stock"`
	ProductStock int `json:"product_stock"`
	ProductUnit string `json:"product_unit"`
	ProductTimeStamp string `json:"product_time_stamp"`
}

type Transaction struct {
	TransactionId int `json:"transaction_id"`
	TransactionTotalPrice int `json:"transaction_total_price"`
	TransactionTimeStamp string `json:"transaction_timestamp"`
	PaymentMethod string `json:"transaction_payment_method"`
	TransactionPayment int `json:"transaction_payment"`
	TransactionChange int `json:"transaction_change"`
	TotalItem int `json:"transaction_total_item"`
}

type TransactionDetails struct {
	TransactionDetailId int `json:"transaction_detail_id"`
	TransactionId int `json:"transaction_id"`
	ProductDetailId int `json:"product_detail_id"`
	PromoProductId int `json:"promo_product_id"`
	Quantity int `json:"quantity"`
	SellPrice int `json:"sell_price"`
	DiscountPrice int `json:"discount_price"`
	TotalPrice int `json:"total_price"`
}

type Stores struct {
	StoreId int `json:"store_id"`
	StoreName string `json:"store_name"`
	StoreAddress string `json:"store_address"`
	StorePhoneNumber string `json:"store_phone_number"`
}

type Warehouses struct {
	WarehouseId int `json:"warehouse_id"`
	WarehouseName string `json:"warehouse_name"`
	WarehouseAddress string `json:"warehouse_address"`
	WarehousePhoneNumber string `json:"warehouse_phone_number"`
}

type Suppliers struct {
	SupplierId int `json:"supplier_id"`
	SupplierName string `json:"supplier_name"`
	SupplierPhoneNumber string `json:"supplier_phone_number"`
	SupplierAddress string `json:"supplier_address"`
}