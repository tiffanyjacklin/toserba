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
	trd, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertTransactionDetails(string(trd))
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
	result, err := model.GetProductByID(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetProductByCode(c echo.Context) error {
	pid := c.Param("product_code")
	result, err := model.GetProductByCode(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByCode", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetProductByName(c echo.Context) error {
	pid := c.Param("product_name")
	result, err := model.GetProductByName(pid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetProductByName", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetAllProducts(c echo.Context) error {
	result, err := model.GetAllProducts()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetAllProducts", result.Data, 3)
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
	result, err := model.InsertStockCards(string(pay))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertStockCards", result.Data, 3)
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
