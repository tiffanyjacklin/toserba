package controller

import (
	"TemplateProject/model"
	"fmt"
	// "fmt"
	"io"

	// "io"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func AccountSendOTP (c echo.Context) error {
	id := c.Param("user_id")

	result, err := model.AccountSendOTP(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"messageee": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "AccountSendOTP", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func OTPVerification (c echo.Context) error {
	id := c.Param("user_id")
	otp, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}

	result, err := model.OTPVerification(id, string(otp))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "OTPVerification", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetFoto(c echo.Context) error {
	id := c.FormValue("id")
	folder := c.FormValue("folder")
	result := model.GetPhoto(folder, id)
	ip := c.RealIP()
	model.InsertLog(ip, "GetPhotoFolder", "getfoto("+id+")", 1)
	return c.File(result)
}

func GetFile(c echo.Context) error {
	// path := c.FormValue("path")
	tabel := c.FormValue("tabel")
	kolom_name := c.FormValue("kolom_name")
	kolom_id := c.FormValue("kolom_id")
	id := c.FormValue("id")
	path := ""

	fmt.Println("MASUK1")
	result, err := model.GetPhotoData(tabel, kolom_name, kolom_id, id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message333": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPath", result.Data, 3)

	userData, ok := result.Data.(model.UserData)
	if !ok {
		// Handle the case where the assertion fails
		fmt.Println("Failed to cast result.Data to UserData")
		return c.JSON(http.StatusInternalServerError, "Invalid data type")
	}

	// Now access the UserPhotoProfile
	path = userData.UserPhotoProfile.String

	return c.File(path)
}

func UploadFile(c echo.Context) error {
	folder := c.FormValue("folder")
	kolom_name := c.FormValue("kolom_name")
	kolom_id := c.FormValue("kolom_id")
	id := c.FormValue("id")
	fileUpload, err := c.FormFile("file")
	// student, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.UploadFile(fileUpload, kolom_name, kolom_id, id, folder)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadFoto", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetUser(c echo.Context) error {
	uname := c.FormValue("username")
	password := c.FormValue("password")
	result, err := model.GetUser(uname, password)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "Login", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDataUser(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetDataUser(uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDataUser", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetUserRoles(c echo.Context) error {
	id := c.Param("user_id")
	result, err := model.GetUserRoles(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, result)
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetRole", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetRolesByID(c echo.Context) error {
	rid := c.Param("roles_id")
	result, err := model.GetRolesByID(rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetRolesByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetUserPriv(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetUserPriv(rid, uid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPrivileges", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetPrivilegesByID(c echo.Context) error {
	pid := c.Param("priv_id")
	result, err := model.GetPrivilegesByID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPrivilegesByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetSessionByID(c echo.Context) error {
	sid := c.Param("session_id")
	result, err := model.GetSessionByID(sid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetSessionByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetLastSession(c echo.Context) error {
	result, err := model.GetLastSession()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetLastSessions", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllSession(c echo.Context) error {
	result, err := model.GetAllSession()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllSessions", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertNewSession(c echo.Context) error {
	session, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertNewSession(string(session))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertNewSession", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetMemberByID(c echo.Context) error {
	mid := c.Param("member_id")
	result, err := model.GetMemberByID(mid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetMemberByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetMemberByPhoneNumber(c echo.Context) error {
	mid := c.Param("phonenumber")
	result, err := model.GetMemberByPhoneNumber(mid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetMemberByPhoneNumbe", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllMember(c echo.Context) error {
	result, err := model.GetAllMember()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllMember", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertNewMember(c echo.Context) error {
	member, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertNewMember(string(member))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertNewMember", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

// func InsertTransaction(c echo.Context) error {
// 	sid := c.Param("session_id")
// 	mid := c.Param("member_id")
// 	trs, err := io.ReadAll(c.Request().Body)
// 	if err != nil {
// 		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
// 	}
// 	result, err := model.InsertTransaction(string(trs), sid, mid)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
// 	}
// 	ip := c.RealIP()
// 	model.InsertLog(ip, "InsertTransaction", result.Data, 3)
// 	return c.JSON(http.StatusOK, result)
// }

func GetTransactionIDBySessionID(c echo.Context) error {
	sid := c.Param("session_id")
	result, err := model.GetTransactionIDBySessionID(sid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTransactionIDBySessionID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTransactionIDByMemberID(c echo.Context) error {
	sid := c.Param("member_id")
	result, err := model.GetTransactionIDByMemberID(sid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTransactionIDByMemberID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTransactionByID(c echo.Context) error {
	tid := c.Param("transaction_id")
	result, err := model.GetTransactionByID(tid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTransactionByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetLastTransaction(c echo.Context) error {
	result, err := model.GetLastTransaction()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetLastTransaction", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllTransaction(c echo.Context) error {
	result, err := model.GetAllTransaction()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllTransaction", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTransactionDetailByTransactionID(c echo.Context) error {
	wid := c.Param("transaction_id")
	result, err := model.GetTransactionDetailByTransactionID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTransactionDetailByTransactionID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertTransaction(c echo.Context) error {
	tid := c.Param("transaction_id")
	sid := c.Param("session_id")
	mid := c.Param("member_id")
	transaction, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertTransaction(tid, sid, mid, string(transaction))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UpdateTransaction", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertTransactionDetails(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	trd, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertTransactionDetails(string(trd), uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertTransactionDetails", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func UpdateClosingSession(c echo.Context) error {
	id := c.Param("session_id")
	session, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.UpdateClosingSession(id, string(session))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadFoto", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func UpdateSessionData(c echo.Context) error {
	id := c.Param("session_id")
	session, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.UpdateSessionData(id, string(session))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadFoto", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertProductCategory(c echo.Context) error {
	procat, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertProductCategory(string(procat))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadProductCategory", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetProductByID(c echo.Context) error {
	pid := c.Param("product_id")
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetProductByID(pid, uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetProductByCode(c echo.Context) error {
	pid := c.Param("product_code")
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetProductByCode(pid, uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByCode", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetProductByName(c echo.Context) error {
	pid := c.Param("user_id")
	rid := c.Param("role_id")
	pname := c.Param("product_name")
	result, err := model.GetProductByName(pname, pid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByName", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllProducts(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetAllProducts(uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllProducts", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllProductsInStoreWarehouse(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetAllProductsInStoreWarehouse(uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllProductsInStoreWarehouse", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertProductDetails(c echo.Context) error {
	swid := c.Param("store_warehouse_id")
	procat, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertProductDetails(string(procat), swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadProductDetails", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertPromoType(c echo.Context) error {
	prt, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertPromoType(string(prt))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "nsertPromoType", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetPromoByID(c echo.Context) error {
	pid := c.Param("promo_id")
	result, err := model.GetPromoByID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPromoByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllPromos(c echo.Context) error {
	result, err := model.GetAllPromos()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllPromos", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetPromoIDByProductID(c echo.Context) error {
	pid := c.Param("product_id")
	result, err := model.GetPromoIDByProductID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPromoIDByProductID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertPromos(c echo.Context) error {
	promo, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertPromos(string(promo))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertPromos", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertPromoProducts(c echo.Context) error {
	prd, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertPromoProducts(string(prd))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertPromoProducts", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func UpdatePromoToAllProducts(c echo.Context) error {
	pid := c.Param("promo_id")
	result, err := model.UpdatePromoToAllProducts(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UpdatePromoToAllProducts", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetPaymentMethodByID(c echo.Context) error {
	pid := c.Param("payment_id")
	result, err := model.GetPaymentMethodByID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPaymentMethodByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllPaymentMethod(c echo.Context) error {
	result, err := model.GetAllPaymentMethod()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllPaymentMethod", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertPaymentMethod(c echo.Context) error {
	pay, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertPaymentMethod(string(pay))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertPaymentMethod", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertStockCards(c echo.Context) error {
	pay, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertStockCards(string(pay), false)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertStockCards", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByID(c echo.Context) error {
	wid := c.Param("stock_card_id")
	result, err := model.GetStockCardByID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByProductID(c echo.Context) error {
	wid := c.Param("product_id")
	result, err := model.GetStockCardByProductID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByProductID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByStoreWarehouse(c echo.Context) error {
	pid := c.Param("product_id")
	wid := c.Param("storewarehouse_id")
	result, err := model.GetStockCardByStoreWarehouse(pid, wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByProductID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByStoreWarehouseEXPDate(c echo.Context) error {
	pid := c.Param("exp_date")
	wid := c.Param("storewarehouse_id")
	result, err := model.GetStockCardByStoreWarehouseEXPDate(wid, pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByStoreWarehouseEXPDate", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByStoreWarehouseBatch(c echo.Context) error {
	pid := c.Param("batch")
	wid := c.Param("storewarehouse_id")
	result, err := model.GetStockCardByStoreWarehouseEXPDate(wid, pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByStoreWarehouseEXPDate", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockCardByEXPDate(c echo.Context) error {
	wid := c.Param("product_id")
	exp := c.Param("exp_date")
	result, err := model.GetStockCardByEXPDate(wid, exp)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockCardByEXPDate", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetEarliestEXPByProductID(c echo.Context) error {
	pid := c.Param("product_id")
	swid := c.Param("sw_id")
	result, err := model.GetEarliestEXPByProductID(pid, swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetEarliestEXPByProductID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByProductID(c echo.Context) error {
	pid := c.Param("product_id")
	result, err := model.GetTotalStockByProductID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "etTotalStockByProductID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByProductIDSWID(c echo.Context) error {
	pid := c.Param("product_id")
	swid := c.Param("sw_id")
	result, err := model.GetTotalStockByProductIDSWID(pid, swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "etTotalStockByProductIDSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByEXPPIDSWID(c echo.Context) error {
	pid := c.Param("product_id")
	swid := c.Param("sw_id")
	exp := c.Param("exp_date")
	result, err := model.GetTotalStockByEXPPIDSWID(pid, swid, exp)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "etTotalStockByProductIDSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByBatchEXPPIDSWID(c echo.Context) error {
	pid := c.Param("product_id")
	swid := c.Param("sw_id")
	exp := c.Param("exp_date")
	batch := c.Param("batch")
	result, err := model.GetTotalStockByBatchEXPPIDSWID(pid, swid, exp, batch)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTotalStockByBatchEXPPIDSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByBatchSWID(c echo.Context) error {
	pid := c.Param("batch")
	swid := c.Param("sw_id")
	result, err := model.GetTotalStockByBatchSWID(pid, swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTotalStockByBatchSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetTotalStockByBatchPIDSWID(c echo.Context) error {
	pid := c.Param("product_id")
	swid := c.Param("sw_id")
	exp := c.Param("batch")
	result, err := model.GetTotalStockByBatchPIDSWID(pid, swid, exp)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetTotalStockByBatchPIDSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDataforStockOpname(c echo.Context) error {
	result, err := model.GetDataforStockOpname()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDataforStockOpname", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDataforStockOpnameBySWID(c echo.Context) error {
	swid := c.Param("sw_id")

	result, err := model.GetDataforStockOpnameBySWID(swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDataforStockOpnameBySWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStockOpnameBySWID(c echo.Context) error {
	swid := c.Param("sw_id")

	result, err := model.GetStockOpnameBySWID(swid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStockOpnameBySWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllStockOpname(c echo.Context) error {
	result, err := model.GetAllStockOpname()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllStockOpname", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertStockOpname(c echo.Context) error {
	pay, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertStockOpname(string(pay))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertStockOpname", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func CheckMinStock(c echo.Context) error {
	pid := c.Param("product_id")
	wid := c.Param("store_warehouse_id")
	result, err := model.CheckMinStock(pid, wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "CheckMinStock", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDeliveryOrderByID(c echo.Context) error {
	wid := c.Param("delivery_order_id")
	result, err := model.GetDeliveryOrderByID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDeliveryOrderByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDeliveryOrderBySWFromID(c echo.Context) error {
	wid := c.Param("sw_from_id")
	result, err := model.GetDeliveryOrderBySWFromID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDeliveryOrderBySWFromID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDOFromSWIDToSWID(c echo.Context) error {
	swidfr := c.Param("sw_from_id")
	swidto := c.Param("sw_to_id")
	result, err := model.GetDOFromSWIDToSWID(swidfr, swidto)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDOFromSWIDToSWID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetDeliveryOrderDetailByDOID(c echo.Context) error {
	wid := c.Param("delivery_order_id")
	result, err := model.GetDeliveryOrderDetailByDOID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetDeliveryOrderDetailByDOID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetLastDeliveryOrder(c echo.Context) error {
	result, err := model.GetLastDeliveryOrder()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetLastDelriveryOrder", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertDeliveryOrders(c echo.Context) error {
	tid := c.Param("deliveryorder_id")
	delo, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertDeliveryOrders(tid, string(delo))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertDeliveryOrders", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertDeliveryOrderDetails(c echo.Context) error {
	trd, err := io.ReadAll(c.Request().Body)
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertDeliveryOrderDetails(string(trd), uid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertDeliveryOrderDetails", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func VerifyDeliveryOrders(c echo.Context) error {
	doi := c.Param("deliveryorder_id")

	result, err := model.VerifyDeliveryOrders(doi)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "VerifyDeliveryOrders", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func AcceptDeliveryOrders(c echo.Context) error {
	doi := c.Param("deliveryorder_id")
	uid := c.Param("user_id")

	result, err := model.AcceptDeliveryOrders(doi, uid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "VerifyDeliveryOrders", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetNotAcceptedDeliveryOrder(c echo.Context) error {
	result, err := model.GetNotAcceptedDeliveryOrder()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetNotAcceptedDeliveryOrder", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStoreWarehouseByUIDRID(c echo.Context) error {
	wid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetStoreWarehouseByUIDRID(wid, rid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStoreWarehouseByUIDRID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetStoreWarehouseByID(c echo.Context) error {
	wid := c.Param("store_warehouse_id")
	result, err := model.GetStoreWarehouseByID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStoreWarehouseByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertStoreWarehouse(c echo.Context) error {
	warehouse, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertStoreWarehouse(string(warehouse))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertStoreWarehouse", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetNotificationByRoleId(c echo.Context) error {
	sid := c.Param("role_id")
	result, err := model.GetNotificationByRoleId(sid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetNotificationByRoleId", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllNotification(c echo.Context) error {
	result, err := model.GetAllNotification()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllPaymentMethod", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertNotification(c echo.Context) error {
	notification, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertNotification(string(notification))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertNotification", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertRoles(c echo.Context) error {
	roles, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertRoles(string(roles))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadRoles", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertPrivileges(c echo.Context) error {
	priv, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertPrivileges(string(priv))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadPrivileges", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertRolesDefault(c echo.Context) error {
	rd, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertRolesDefault(string(rd))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadRolesDefault", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertSupplier(c echo.Context) error {
	sup, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertSupplier(string(sup))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertSupplier", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}



func UploadFoto(c echo.Context) error {
	// /login?username=tipani. formvalue ini username it
	folder := c.FormValue("folder")
	// /login/1. ini kalau param
	// id := c.Param("id")
	id := c.FormValue("id")
	fotoFile, err := c.FormFile("photo")
	nId, _ := strconv.Atoi(id)
	tId := int64(nId)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	result, err := model.UploadFotoFolder(fotoFile, tId, folder)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "UploadFoto", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}
