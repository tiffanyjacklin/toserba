package controller

import (
	"TemplateProject/model"
	"io"
	// "io"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

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
	
	result, err := model.GetPhotoData(tabel, kolom_name, kolom_id, id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message333": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPath", result.Data, 3)

	if result.Data != nil {
		path, _ = result.Data.(string)
	}

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

func GetRoles(c echo.Context) error {
	id := c.Param("user_id")
	result, err := model.GetRoles(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, result)
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetRole", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetPriv(c echo.Context) error {
	uid := c.Param("user_id")
	rid := c.Param("role_id")
	result, err := model.GetPriv(rid, uid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetPrivileges", result.Data, 3)
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

func GetStoreByID(c echo.Context) error {
	sid := c.Param("store_id")
	result, err := model.GetStoreByID(sid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetStoreByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertStore(c echo.Context) error {
	store, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertStore(string(store))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertStore", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func GetWarehouseByID(c echo.Context) error {
	wid := c.Param("warehouse_id")
	result, err := model.GetWarehouseByID(wid)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "GetWarehouseByID", result.Data, 3)
	return c.JSON(http.StatusOK, result)
}

func InsertWarehouse(c echo.Context) error {
	warehouse, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Gagal membaca body request"})
	}
	result, err := model.InsertWarehouse(string(warehouse))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	ip := c.RealIP()
	model.InsertLog(ip, "InsertWarehouse", result.Data, 3)
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
