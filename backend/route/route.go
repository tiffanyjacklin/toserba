package route

import (
	"TemplateProject/controler"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"net/http"
)

func Init() *echo.Echo {
	e := echo.New()
	e.Use(middleware.CORSWithConfig(middleware.DefaultCORSConfig))
	e.GET("/getPhoto", controller.GetFoto)
	e.POST("/uploadFoto", controller.UploadFoto)

	// error exception
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "welcome here")
	})

	e.POST("/file/upload", controller.UploadFile)
	e.GET("/file", controller.GetFile)

	// User
	e.PUT("/user/login", controller.GetUser) // body form-data username & password
	e.GET("/user/:user_name/:limit/:offset", controller.GetAllUser)
	e.GET("/user/:start_date/:end_date/:user_name/:role_id/:gender/:limit/:offset", controller.GetAllUserFilter)
	e.GET("/user/roles/data/:role_id", controller.GetAllUserByRoleID)
	e.GET("/user/:user_id", controller.GetUserByID)
	e.GET("/user/last", controller.GetLastUser)
	e.GET("/user/store_warehouse/:sw_id", controller.GetUserByStoreWarehouseID)
	e.GET("/user/name/:user_name", controller.GetUserByName)
	e.GET("/user/:user_id/:role_id", controller.GetDataUser)
	e.POST("/user/add", controller.InsertNewUser)
	e.PUT("/user/update/:user_id", controller.UpdateUser)
	e.PUT("/user/update/password/:user_id/:password", controller.UpdatePassword)
	e.GET("/user/roles/:user_id", controller.GetUserRoles)
	e.POST("/user/roles/add", controller.InsertNewUserRoles)
	e.DELETE("/user/roles/delete/:user_id/:role_id/:sw_id", controller.DelUserRoles)
	e.PUT("/user/roles/update/:user_id/:role_id", controller.UpdateUserRoles)
	e.PUT("/user/roles/update/:user_id/:role_id/:sw_id", controller.UpdateUserStoreWarehouse)
	e.POST("/user/privileges/add/new/:user_id/:role_id", controller.InsertUserPrivilege)
	e.POST("/user/privileges/add/exist/:user_id/:role_id", controller.InsertExistUserPrivilege)
	e.PUT("/user/privileges/update/:user_id/:role_id/:privilege_id", controller.UpdateUserPrivilege)
	e.GET("/user/privileges/:user_id/:role_id", controller.GetUserPriv)

	e.PUT("/cashier/session/edit/sendotp/:user_id", controller.AccountSendOTP)
	e.PUT("/cashier/session/edit/verifotp/:user_id", controller.OTPVerification)

	// Cashier - Session
	e.GET("/cashier/session/:session_id", controller.GetSessionByID)
	e.GET("/cashier/session/:sess_id_user_name/:limit/:offset", controller.GetAllSession)
	e.GET("/cashier/session/:start_date/:end_date/:sess_id_user_name/:limit/:offset", controller.GetSessionByDateRange)
	e.GET("/cashier/session/last", controller.GetLastSession)
	e.GET("/cashier/session/transaction/:session_id/:transaction_id_user_name/:limit/:offset", controller.GetTransactionIDBySessionID)
	e.GET("/cashier/session/transaction/:session_id/:start_date/:end_date/:transaction_id_user_name/:limit/:offset", controller.GetTransactionIDBySessionIDDateRange)
	e.POST("/cashier/session/new", controller.InsertNewSession)
	e.PUT("/cashier/session/close/:session_id", controller.UpdateClosingSession)
	e.PUT("/cashier/session/edit/:session_id", controller.UpdateSessionData)

	// Cashier - Transaction, Member & Product
	e.GET("/cashier/members/:member_id", controller.GetMemberByID)
	e.GET("/cashier/members/:member_ph_name/:limit/:offset", controller.GetAllMember)
	e.GET("/cashier/members/:start_date/:end_date/:member_ph_name/:limit/:offset", controller.GetMemberByJoinDate)
	e.GET("/cashier/members/phone_number/:phonenumber", controller.GetMemberByPhoneNumber)
	e.POST("/cashier/members/add", controller.InsertNewMember)
	e.GET("/cashier/members/transaction/:member_id", controller.GetTransactionIDByMemberID)

	e.GET("/transaction/:transaction_id", controller.GetTransactionByID)
	e.GET("/transaction/store_warehouse/:sw_id/:limit/:offset", controller.GetTransactionBySWID)
	e.GET("/transaction/user/:user_id/:limit/:offset", controller.GetTransactionByUserID)
	e.GET("/transaction/last", controller.GetLastTransaction)
	e.GET("/transaction/:transaction_id_user_name/:limit/:offset", controller.GetAllTransaction)
	e.GET("/transaction/:start_date/:end_date/:transaction_id_user_name/:limit/:offset", controller.GetTransactionByTimestamp)
	e.GET("/transaction/detail/:transaction_id/:limit/:offset", controller.GetTransactionDetailByTransactionID)
	e.POST("/transaction/details/add/:user_id/:role_id", controller.InsertTransactionDetails) 
	e.PUT("/transaction/update/:transaction_id/:session_id/:member_id", controller.InsertTransaction)

	e.PUT("/store/orders/delivery/accept/:deliveryorder_id/:user_id", controller.AcceptDeliveryOrders)
	e.GET("/store/orders/delivery/accept/:deliveryorder_id/:status/:start_date/:end_date/:limit/:offset", controller.GetAcceptedDeliveryOrder)

	// Warehouse
	e.GET("/products/stock/card/description", controller.GetAllStockDescription)
	e.POST("/products/stock/card/add", controller.InsertStockCards)
	e.GET("/products/stock/card/all/:limit/:offset", controller.GetAllStockCard)
	e.GET("/products/stock/card/:stock_card_id", controller.GetStockCardByID)
	e.GET("/products/stock/card/product/:product_id/:limit/:offset", controller.GetStockCardByProductID)
	e.GET("/products/stock/card/product/store_warehouse/:storewarehouse_id/:start_date/:end_date/:category/:unit_type/:description/:product_name_id_code_batch/:limit/:offset", controller.GetStockCardByStoreWarehouse)
	e.GET("/products/stock/card/product/store_warehouse/:product_id/:storewarehouse_id/:limit/:offset", controller.GetStockCardByPIDStoreWarehouse)
	e.GET("/products/stock/card/product/store_warehouse/exp/:exp_date/:storewarehouse_id/:limit/:offset", controller.GetStockCardByStoreWarehouseEXPDate)
	e.GET("/products/stock/card/product/store_warehouse/batch/:batch/:storewarehouse_id/:limit/:offset", controller.GetStockCardByStoreWarehouseBatch)
	e.GET("/products/stock/card/product/exp/:product_id/:exp_date/:limit/:offset", controller.GetStockCardByEXPDate)
	e.GET("/products/stock/card/product/exp/early/:product_id/:sw_id", controller.GetEarliestEXPByProductID)
	e.GET("/products/stock/card/product/total_stock/all/:product_id", controller.GetTotalStockByProductID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id", controller.GetTotalStockByProductIDSWID)
	e.GET("/products/stock/card/product/total_stock/batch/:sw_id/:batch", controller.GetTotalStockByBatchSWID)
	e.GET("/products/stock/card/product/total_stock/batch/:product_id/:sw_id/:batch", controller.GetTotalStockByBatchPIDSWID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id/:exp_date", controller.GetTotalStockByEXPPIDSWID)
	e.GET("/products/stock/card/product/total_stock/:product_id/:sw_id/:exp_date/:batch", controller.GetTotalStockByBatchEXPPIDSWID)

	e.GET("/products/stock/card/exp_date/:product_id/:limit/:offset", controller.GetAllEXPDateByProductID)
	e.GET("/products/stock/card/exp_date/:product_id/:sw_id/:limit/:offset", controller.GetAllEXPDateByProductIDSWID)
	e.GET("/products/stock/card/batch/:product_id/:limit/:offset", controller.GetAllBatchByProductID)
	e.GET("/products/stock/card/batch/:product_id/:sw_id/:limit/:offset", controller.GetAllBatchByProductIDSWID)
	e.GET("/products/stock/min/:product_id/:sw_id", controller.CheckMinStock)

	e.GET("/products/stock/opname/data/:limit/:offset", controller.GetDataforStockOpname)
	e.GET("/products/stock/opname/data/store_warehouse/:sw_id/:product_name/:batch/:unit_type/:product_id/:expired_date/:category/:asc/:limit/:offset", controller.GetDataforStockOpnameBySWID)
	e.GET("/products/stock/opname/data/store_warehouse/:product_id/:sw_id/:limit/:offset", controller.GetDataforStockOpnameByPIDSWID)
	e.GET("/products/stock/opname/store_warehouse/:sw_id", controller.GetStockOpnameBySWID)
	e.GET("/products/stock/opname/:limit/:offset", controller.GetAllStockOpname)
	e.POST("/products/stock/opname/add", controller.InsertStockOpname)

	e.GET("/orders/transfer/notes/:transfernote_id", controller.GetTransferNoteByID)
	e.GET("/orders/transfer/notes/last", controller.GetLastTransferNote)
	e.GET("/orders/transfer/notes/all/:transfernote_id/:sw_from/:sw_to/:status_verif/:status_send/:start_date/:end_date/:limit/:offset", controller.GetAllTransferNotes)
	e.GET("/orders/transfer/notes/verified/:transfernote_id/:limit/:offset", controller.GetVerifiedTransferNotes)
	e.GET("/orders/transfer/notes/sent/:transfernote_id/:limit/:offset", controller.GetSentTransferNotes)
	e.GET("/orders/transfer/notes/stock/left/:product_id/:batch/:exp_date/:transfernote_id", controller.GetStockLeftInTransferNotes)
	e.GET("/orders/transfer/notes/detail/:transfernote_id", controller.GetTransferNoteDetailByTNID)
	e.POST("/orders/transfer/notes/add/:user_id/:role_id", controller.InsertTransferNoteDetails) 
	e.PUT("/orders/transfer/notes/update/:transfernote_id", controller.InsertTransferNotes)
	e.GET("/orders/transfer/notes/check/:product_id/:sw_id/:quantity", controller.GetCheckProductForTransferNote)

	e.GET("/orders/delivery/:delivery_order_id", controller.GetDeliveryOrderByID)
	e.GET("/orders/delivery/last", controller.GetLastDeliveryOrder)
	e.GET("/orders/delivery/warehouse/from/:sw_from_id/:limit/:offset", controller.GetDeliveryOrderBySWFromID)
	e.GET("/orders/delivery/warehouse/to/:sw_to_id/:limit/:offset", controller.GetDeliveryOrderBySWToID)
	e.GET("/orders/delivery/storewarehouse/:sw_from_id/:sw_to_id", controller.GetDOFromSWIDToSWID)
	e.GET("/orders/delivery/transfernote/:transfernote_id", controller.GetDeliveryOrderByTNID)
	e.GET("/orders/delivery/detail/:delivery_order_id", controller.GetDeliveryOrderDetailByDOID)
	e.POST("/orders/delivery/add/:transfernote_id", controller.InsertDeliveryOrderDetails) 
	e.PUT("/orders/delivery/update/:deliveryorder_id", controller.InsertDeliveryOrders)

	e.GET("/orders/supplier/all/:asc/:limit/:offset", controller.GetAllAddStock)
	e.GET("/orders/supplier/:addstock_id", controller.GetAddStockByID)
	e.GET("/orders/supplier/detail/:addstock_id/:asc/:limit/:offset", controller.GetAddStockDetailByASID)
	e.POST("/orders/supplier/add/:user_id/:role_id", controller.InsertAddStockDetails) 
	e.PUT("/orders/supplier/update/:addstock_id", controller.InsertAddStock)

	e.GET("/products/stock/subtract/all/:asc/:limit/:offset", controller.GetAllSubtractStock)
	e.GET("/products/stock/subtract/:subtractstock_id", controller.GetSubtractStockByID)
	e.GET("/products/stock/subtract/store_warehouse/:sw_id/:asc/:limit/:offset", controller.GetSubtractStockBySWID)
	e.POST("/products/stock/subtract/:user_id/:role_id", controller.InsertSubtractStock)

	// Admin
	e.GET("/sessions/store_warehouse/:sw_id/:limit/:offset", controller.GetSessionBySWID)
	e.GET("/sessions/not_verified", controller.GetNotVerifiedSession)
	e.PUT("/sessions/verify/:session_id", controller.VerifySession)

	e.GET("/products/sorting", controller.GetAllProductSorting)
	e.GET("/products/category", controller.GetAllProductCategory)
	e.POST("/products/category/add", controller.InsertProductCategory)
	e.GET("/products/:product_id/:user_id/:role_id", controller.GetProductByID) 
	e.GET("/products/all/:product_id", controller.GetProductByIdAllSW) 
	e.GET("/products/code/:product_code/:user_id/:role_id", controller.GetProductByCode) 
	e.GET("/products/code/all/:product_code", controller.GetProductByCodeAllSW) 
	e.GET("/products/name/:product_name/:user_id/:role_id", controller.GetProductByName) 
	e.GET("/products/name/all/:product_name", controller.GetProductByNameAllSW)
	e.GET("/products/:limit/:offset", controller.GetAllProducts) 
	e.GET("/products/detail", controller.GetAllProductDetail)
	e.GET("/products/detail/store_warehouse/:user_id/:role_id/:product_name_id/:limit/:offset", controller.GetAllProductDetailInSW) 
	e.GET("/products/store_warehouse/:user_id/:role_id/:product_name_id/:limit/:offset", controller.GetAllProductsInSW) 
	e.GET("/products/store_warehouse/:user_id/:role_id/:start_price/:end_price/:product_name_id_code/:category/:unit_type/:product_sort/:asc/:limit/:offset", controller.GetAllProductsInSWFilter) 
	e.GET("/products/supplier/:supplier_id/:limit/:offset", controller.GetAllProductDetailFromSupplier) 
	e.POST("/products/add", controller.InsertProductDetails)
	e.PUT("/products/edit/:product_id", controller.UpdateProductDetails)

	e.POST("/promos/type/add", controller.InsertPromoType)
	e.GET("/promos/:promo_id", controller.GetPromoByID)
	e.GET("/promos/last", controller.GetLastPromo)
	e.GET("/promos/:start_date/:end_date/:product_name_promo_code/:promo_type/:status/:limit/:offset", controller.GetAllPromos)  
	e.GET("/promos/active/:limit/:offset", controller.GetAllActivePromos)  
	e.POST("/promos/add", controller.InsertPromos) 
	e.GET("/promos/product/:product_id/:limit/:offset", controller.GetPromoIDByProductID)
	e.POST("/promos/product/add", controller.InsertPromoProducts) 
	e.POST("/promos/product/all/:promo_id", controller.UpdatePromoToAllProducts)
	e.GET("/promos/stores/:sw_id", controller.GetPromoIDBySWID)
	e.POST("/promos/stores/add", controller.InsertPromoStores)

	e.GET("/roles/:roles_id", controller.GetRolesByID)
	e.GET("/privileges/:priv_id", controller.GetPrivilegesByID)

	e.GET("/orders/transfer/notes/verify/:status/:sw_from/:sw_to/:limit/:offset", controller.GetNotVerifiedTransferNote)
	e.PUT("/orders/transfer/notes/verify/:transfernote_id/:status", controller.VerifyTransferNotes)
	e.POST("/orders/transfer/detail/add/product/:transfernote_id", controller.InsertProductToTransferNoteDetails) 
	e.PUT("/orders/transfer/detail/update/product/:transfernote_id/:product_id/:quantity", controller.UpdateProductQtyTransferNote)
	e.DELETE("/orders/transfer/detail/delete/product/:transfernote_id/:product_id/:batch/:exp_date", controller.DelProductFromTransferNote)

	e.GET("/orders/supplier/verify/:status/:sw_name/:limit/:offset", controller.GetNotVerifiedAddStock)
	e.PUT("/orders/supplier/verify/:addstock_id/:status", controller.VerifyAddStock)
	e.PUT("/orders/supplier/update/stock/:addstock_id", controller.UpdateStockInAddStock)
	e.DELETE("/orders/supplier/detail/:addstock_id", controller.DelAddStockDetail)

	e.GET("/products/stock/subtract/verify/:status/:sw_name/:limit/:offset", controller.GetNotVerifiedSubtractStock)
	e.PUT("/products/stock/subtract/verify/:subtract_id/:status", controller.VerifySubtractStock)
	e.PUT("/products/stock/subtract/update/stock/:subtract_id", controller.UpdateStockInSubtractStock)

	// Owner 
	e.GET("/store_warehouses/all", controller.GetAllStoreWarehouse)
	e.GET("/store_warehouses/type/:sw_type/:sw_name_address/:limit/:offset", controller.GetAllStoreWarehouseFilter)
	e.GET("/store_warehouses/:user_id/:role_id", controller.GetStoreWarehouseByUIDRID)
	e.GET("/store_warehouses/promos/:promo_id", controller.GetSWIDByPromoID)
	e.GET("/store_warehouses/:store_warehouse_id", controller.GetStoreWarehouseByID)
	e.GET("/store_warehouses/name/:sw_name", controller.GetStoreWarehouseByName)
	e.POST("/store_warehouses/add", controller.InsertStoreWarehouse)
	e.PUT("/store_warehouses/edit/:sw_id", controller.UpdateStoreWarehouse)
	e.GET("/roles/all/:role_name/:limit/:offset", controller.GetAllRoles)
	e.POST("/roles/add", controller.InsertRoles)
	e.GET("/privileges/all/:priv_name/:limit/:offset", controller.GetAllPrivileges)
	e.POST("/privileges/add", controller.InsertPrivileges)
	e.POST("/owner/roles/default/add", controller.InsertRolesDefault)
	e.GET("/suppliers/:supplier_id", controller.GetSupplierByID)
	e.GET("/suppliers/all/:supplier_name/:limit/:offset", controller.GetAllSupplier)
	e.POST("/suppliers/add", controller.InsertSupplier)
	e.GET("/payment/method/:payment_id", controller.GetPaymentMethodByID)
	e.GET("/payment/method", controller.GetAllPaymentMethod)
	e.POST("/payment/method/add", controller.InsertPaymentMethod)

	e.GET("/products/moving/transaction/product/:product_id/:asc/:limit/:offset", controller.GetSlowFastMovingPerProduct)
	e.GET("/products/moving/transaction/:sw_id/:year/:month/:day/:category/:unit_type/:asc/:limit/:offset", controller.GetSlowFastMovingFromTransactionBySWID)
	e.GET("/products/moving/transaction/range/:sw_id/:start_date/:end_date/:category/:unit_type/:asc/:limit/:offset", controller.GetSlowFastMovingFromTransactionBySWIDDateRange)
	e.GET("/products/moving/stock/card/:asc/:limit/:offset", controller.GetSlowFastMovingFromStockOut)

	e.GET("/promos/verify/:status/:pd_name_code/:promo_code/:limit/:offset", controller.GetVerifiedPromoProducts)
	e.PUT("/promos/verify/:promo_id/:product_id/:status", controller.VerifyPromoProduct)
	e.GET("/promos/cost/all", controller.GetTotalPromoCost)
	e.GET("/promos/cost/transaction/all", controller.GetTotalPromoCostPerTransaction)
	e.GET("/promos/cost/transaction/:transaction_id", controller.GetTotalPromoCostByTransactionID)
	e.GET("/promos/cost/store/all", controller.GetTotalPromoCostPerStore)
	e.GET("/promos/cost/store/:store_id", controller.GetTotalPromoCostByStoreID)

	e.GET("/promos/cost/difference/:promo_id/:product_id", controller.GetPromoPriceDiff)

	e.GET("/profit/all/:year/:month/:day/:asc/:limit/:offset", controller.GetAllProfit)
	e.GET("/profit/sum/all/:year/:month/:day", controller.GetSumProfit)
	e.GET("/profit/all/date/:start_date/:end_date/:asc/:limit/:offset", controller.GetAllProfitByDate)
	e.GET("/profit/all/product/:product_id/:asc/:limit/:offset", controller.GetAllProfitByProductID)
	e.GET("/profit/sum/date/:start_date/:end_date", controller.GetSumProfitByDate)
	e.GET("/profit/sum/product/:product_id", controller.GetSumProfitByProductID)
	e.GET("/profit/sum/transaction/:transaction_id", controller.GetSumProfitByTransactionID)
	e.GET("/profit/sum/store/:sw_id", controller.GetSumProfitBySWID)
	e.GET("/profit/all/transaction/:transaction_id/:asc/:limit/:offset", controller.GetAllProfitByTransactionID)
	e.GET("/profit/all/store/:sw_id/:asc/:limit/:offset", controller.GetAllProfitBySWID)
	e.GET("/profit/sum/all/year/:start_date/:end_date", controller.GetSumProfitByAllYear)
	e.GET("/profit/sum/all/month/:start_date/:end_date", controller.GetSumProfitByAllMonth)
	e.GET("/profit/sum/all/date/:start_date/:end_date", controller.GetSumProfitByAllDate)
	e.GET("/profit/sum/all/transaction/:start_date/:end_date", controller.GetSumProfitByAllTransaction)
	e.GET("/profit/sum/all/product/:start_date/:end_date", controller.GetSumProfitByAllProduct)
	e.GET("/profit/sum/all/store/:start_date/:end_date", controller.GetSumProfitByAllSW)

	e.GET("/notifications/:limit/:offset", controller.GetAllNotification)
	e.GET("/notifications/:role_id", controller.GetNotificationByRoleId)
	e.POST("/notifications/add", controller.InsertNotification)

	return e
}
