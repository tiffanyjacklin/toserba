package controller

import (
	"TemplateProject/model"
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

func GetRoles(c echo.Context) error {
	id := c.Param("user_id")
	result, err := model.GetRoles(id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
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
