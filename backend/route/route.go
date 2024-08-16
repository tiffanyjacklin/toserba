package route

import (
	"TemplateProject/controler"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"net/http"
)

// mengatur syntax uri
func Init() *echo.Echo {
	e := echo.New()
	e.Use(middleware.CORSWithConfig(middleware.DefaultCORSConfig))
	e.GET("/getPhoto", controller.GetFoto)
	e.POST("/uploadFoto", controller.UploadFoto)

	// kalau pakai param
	// e.POST("/uploadFoto/:id", controler.UploadFoto)

	// error exception
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "welcome here")
	})

	e.POST("/file/upload", controller.UploadFile)
	e.GET("/file", controller.GetFile)

	// User
	e.PUT("/user/login", controller.GetUser) // body form-data username & password
	e.GET("/user/:user_id/:role_id", controller.GetDataUser)
	e.GET("/user/roles/:user_id", controller.GetUserRoles)
	e.GET("/user/privileges/:user_id/:role_id", controller.GetUserPriv)

	e.PUT("/cashier/session/edit/sendotp/:user_id", controller.AccountSendOTP)
	e.PUT("/cashier/session/edit/verifotp/:user_id", controller.OTPVerification)

	// Cashier - Session
	e.GET("/cashier/session/:session_id", controller.GetSessionByID)
	e.GET("/cashier/session", controller.GetAllSession)
	e.GET("/cashier/session/last", controller.GetLastSession)
	e.GET("/cashier/session/transaction/:session_id", controller.GetTransactionIDBySessionID)
	e.POST("/cashier/session/new", controller.InsertNewSession)
	e.PUT("/cashier/session/close/:session_id", controller.UpdateClosingSession)
	e.PUT("/cashier/session/edit/:session_id", controller.UpdateSessionData)

	// Cashier - Transaction, Member & Product
	e.GET("/cashier/members/:member_id", controller.GetMemberByID)
	e.POST("/cashier/members/add", controller.InsertNewMember)
	e.GET("/cashier/members/transaction/:member_id", controller.GetTransactionIDByMemberID)

	e.GET("/transaction/:transaction_id", controller.GetTransactionByID)
	e.GET("/transaction/last", controller.GetLastTransaction)
	e.GET("/transaction", controller.GetAllTransaction)
	e.POST("/transaction/details/add", controller.InsertTransactionDetails) 
	e.PUT("/transaction/update/:transaction_id/:session_id/:member_id", controller.InsertTransaction)

	// Admin
	e.POST("/products/category/add", controller.InsertProductCategory)
	e.GET("/products/:product_id", controller.GetProductByID) 
	e.GET("/products", controller.GetAllProducts) 
	e.POST("/products/add", controller.InsertProductDetails)
	e.POST("/promos/type/add", controller.InsertPromoType)
	e.GET("/promos/:promo_id", controller.GetPromoByID) 
	e.POST("/promos/add", controller.InsertPromos) 
	e.POST("promos/product/add", controller.InsertPromoProducts) 
	e.GET("/roles/:roles_id", controller.GetRolesByID)
	e.GET("/privileges/:priv_id", controller.GetPrivilegesByID)

	// Owner 
	e.GET("/stores/:store_id", controller.GetStoreByID)
	e.POST("/stores/add", controller.InsertStore)
	e.GET("/warehouses/:warehouse_id", controller.GetWarehouseByID)
	e.POST("/warehouses/add", controller.InsertWarehouse)
	e.POST("/roles/add", controller.InsertRoles)
	e.POST("/privileges/add", controller.InsertPrivileges)
	e.POST("/owner/roles/default/add", controller.InsertRolesDefault)
	e.POST("/suppliers/add", controller.InsertSupplier)
	e.POST("/payment/method/add", controller.InsertPaymentMethod)
	return e
}
