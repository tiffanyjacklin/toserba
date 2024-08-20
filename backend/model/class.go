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
	UserFullName string `json:"user_fullname"`
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
	ProductTimeStamp string `json:"product_timestamp"`
	StoreWarehouseID int `json:"store_warehouse_id"`
	WarehousePlacement string `json:"warehouse_placement"`
}

type Transaction struct {
	TransactionId int `json:"transaction_id"`
	TransactionTotalPrice int `json:"transaction_total_price"`
	TransactionTimeStamp string `json:"transaction_timestamp"`
	PaymentMethodId int `json:"transaction_payment_method_id"`
	TransactionPayment int `json:"transaction_payment"`
	TransactionChange int `json:"transaction_change"`
	TotalItem int `json:"transaction_total_item"`
	TransactionUser string `json:"transaction_user"`
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

type SessionTransaction struct {
	SessionTransactionId int `json:"session_transaction_id"`
	TransactionId int `json:"transaction_id"`
	SessionId int `json:"session_id"`
}

type TransactionMember struct {
	TransactionMemberId int `json:"transaction_member_id"`
	TransactionId int `json:"transaction_id"`
	MemberId int `json:"member_id"`
}

type PromoTypes struct {
	PromoTypeId int `json:"promo_type_id"`
	PromoTypeName string `json:"promo_type_name"`
}

type Promos struct {
	PromoId int `json:"promo_id"`
	PromoCode string `json:"promo_code"`
	PromoTypeId int `json:"promo_type_id"`
	PromoStartDate string `json:"promo_start_date"`
	PromoEndDate string `json:"promo_end_date"`
	PromoPercentage int `json:"promo_percentage"`
	PromoDiscount int `json:"promo_discount"`
	TermAndCond string `json:"promo_term_and_cond"`
	XAmount int `json:"x_amount"`
	YAmount int `json:"y_amount"`
}

type PromoProducts struct {
	PromoProductId int `json:"promo_product_id"`
	ProductDetailId int `json:"product_detail_id"`
	PromoId int `json:"promo_id"`
}

type PaymentMethod struct {
	PaymentMethodId int `json:"payment_method_id"`
	PaymentMethodName string `json:"payment_method_name"`
}

type StockCards struct {
	StockCardID int `json:"stock_card_id"`
	ProductDetailID int `json:"product_detail_id"`
	StockDate string `json:"stock_date"`
	StockDescription string `json:"stock_description"`
	ProductName string `json:"product_name"`
	ProductBatch int `json:"product_batch"`
	ProductStock int `json:"product_stock"`
	ExpiredDate string `json:"expired_date"`
	StockIn int `json:"stock_in"`
	StockOut int `json:"stock_out"`
	StoreWarehouseID int `json:"store_warehouse_id"`
}

type StoreWarehouses struct {
	StoreWarehouseId int `json:"store_warehouse_id"`
	StoreWarehouseType string `json:"store_warehouse_type"`
	StoreWarehouseName string `json:"store_warehouse_name"`
	StoreWarehouseAddress string `json:"store_warehouse_address"`
	StoreWarehousePhoneNumber string `json:"store_warehouse_phone_number"`
}

type Suppliers struct {
	SupplierId int `json:"supplier_id"`
	SupplierName string `json:"supplier_name"`
	SupplierPhoneNumber string `json:"supplier_phone_number"`
	SupplierAddress string `json:"supplier_address"`
}