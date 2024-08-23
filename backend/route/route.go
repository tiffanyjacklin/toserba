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
	e.GET("/cashier/members", controller.GetAllMember)
	e.GET("/cashier/members/phone_number/:phonenumber", controller.GetMemberByPhoneNumber)
	e.POST("/cashier/members/add", controller.InsertNewMember)
	e.GET("/cashier/members/transaction/:member_id", controller.GetTransactionIDByMemberID)

	e.GET("/transaction/:transaction_id", controller.GetTransactionByID)
	e.GET("/transaction/last", controller.GetLastTransaction)
	e.GET("/transaction", controller.GetAllTransaction)
	e.GET("/transaction/detail/:transaction_id", controller.GetTransactionDetailByTransactionID)
	e.POST("/transaction/details/add/:user_id/:role_id", controller.InsertTransactionDetails) 
	e.PUT("/transaction/update/:transaction_id/:session_id/:member_id", controller.InsertTransaction)

	e.PUT("/store/orders/delivery/accept/:deliveryorder_id/:user_id", controller.AcceptDeliveryOrders)
	e.GET("/store/orders/delivery/not_accept", controller.GetNotAcceptedDeliveryOrder)

	// Warehouse
	e.POST("/products/stock/card/add", controller.InsertStockCards)
	e.GET("/products/stock/card/:stock_card_id", controller.GetStockCardByID)
	e.GET("/products/stock/card/product/:product_id", controller.GetStockCardByProductID)
	e.GET("/products/stock/card/product/store_warehouse/:product_id/:storewarehouse_id", controller.GetStockCardByStoreWarehouse)
	e.GET("/products/stock/card/product/store_warehouse/exp/:exp_date/:storewarehouse_id", controller.GetStockCardByStoreWarehouseEXPDate)
	e.GET("/products/stock/card/product/store_warehouse/batch/:exp_date/:storewarehouse_id", controller.GetStockCardByStoreWarehouseBatch)
	e.GET("/products/stock/card/product/exp/:product_id/:exp_date", controller.GetStockCardByEXPDate)
	e.GET("/products/stock/card/product/exp/early/:product_id/:sw_id", controller.GetEarliestEXPByProductID)
	e.GET("/products/stock/card/product/total_stock/all/:product_id", controller.GetTotalStockByProductID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id", controller.GetTotalStockByProductIDSWID)
	e.GET("/products/stock/card/product/total_stock/batch/:sw_id/:batch", controller.GetTotalStockByBatchSWID)
	e.GET("/products/stock/card/product/total_stock/batch/:product_id/:sw_id/:batch", controller.GetTotalStockByBatchPIDSWID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id/:exp_date", controller.GetTotalStockByEXPPIDSWID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id/:exp_date/:batch", controller.GetTotalStockByBatchEXPPIDSWID)

	e.GET("/products/stock/min/:product_id/:store_warehouse_id", controller.CheckMinStock)

	e.GET("/products/stock/opname/data", controller.GetDataforStockOpname)
	e.GET("/products/stock/opname/data/store_warehouse/:sw_id", controller.GetDataforStockOpnameBySWID)
	e.GET("/products/stock/opname/store_warehouse/:sw_id", controller.GetStockOpnameBySWID)
	e.GET("/products/stock/opname", controller.GetAllStockOpname)
	e.POST("/products/stock/opname/add", controller.InsertStockOpname)

	e.GET("/orders/delivery/:delivery_order_id", controller.GetDeliveryOrderByID)
	e.GET("/orders/delivery/last", controller.GetLastDeliveryOrder)
	e.GET("/orders/delivery/warehouse/:sw_from_id", controller.GetDeliveryOrderBySWFromID)
	e.GET("/orders/delivery/storewarehouse/:sw_from_id/:sw_to_id", controller.GetDOFromSWIDToSWID)
	e.GET("/orders/delivery/detail/:delivery_order_id", controller.GetDeliveryOrderDetailByDOID)
	e.POST("/orders/delivery/add/:user_id/:role_id", controller.InsertDeliveryOrderDetails) 
	e.PUT("/orders/delivery/update/:deliveryorder_id", controller.InsertDeliveryOrders)

	// Admin
	e.POST("/products/category/add", controller.InsertProductCategory)
	e.GET("/products/:product_id/:user_id/:role_id", controller.GetProductByID) 
	e.GET("/products/code/:product_code/:user_id/:role_id", controller.GetProductByCode) 
	e.GET("/products/name/:product_name/:user_id/:role_id", controller.GetProductByName) 
	e.GET("/products/:user_id/:role_id", controller.GetAllProducts) 
	e.GET("/products/store_warehouse/:user_id/:role_id", controller.GetAllProductsInStoreWarehouse) 
	e.POST("/products/add/:store_warehouse_id", controller.InsertProductDetails)
	e.POST("/promos/type/add", controller.InsertPromoType)
	e.GET("/promos/:promo_id", controller.GetPromoByID)
	e.GET("/promos", controller.GetAllPromos)  
	e.POST("/promos/add", controller.InsertPromos) 
	e.GET("/promos/product/:product_id", controller.GetPromoIDByProductID)
	e.POST("/promos/product/add", controller.InsertPromoProducts) 
	e.POST("/promos/product/all/:promo_id", controller.UpdatePromoToAllProducts)
	e.GET("/roles/:roles_id", controller.GetRolesByID)
	e.GET("/privileges/:priv_id", controller.GetPrivilegesByID)

	e.PUT("/orders/delivery/verify/:deliveryorder_id", controller.VerifyDeliveryOrders)

	// Owner 
	e.GET("/store_warehouses/:user_id/:role_id", controller.GetStoreWarehouseByUIDRID)
	e.GET("/store_warehouses/:store_warehouse_id", controller.GetStoreWarehouseByID)
	e.POST("/store_warehouses/add", controller.InsertStoreWarehouse)
	e.POST("/roles/add", controller.InsertRoles)
	e.POST("/privileges/add", controller.InsertPrivileges)
	e.POST("/owner/roles/default/add", controller.InsertRolesDefault)
	e.POST("/suppliers/add", controller.InsertSupplier)
	e.GET("/payment/method/:payment_id", controller.GetPaymentMethodByID)
	e.GET("/payment/method", controller.GetAllPaymentMethod)
	e.POST("/payment/method/add", controller.InsertPaymentMethod)

	e.GET("/notifications", controller.GetAllNotification)
	e.GET("/notifications/:role_id", controller.GetNotificationByRoleId)
	e.POST("/notifications/add", controller.InsertNotification)

	return e
}
