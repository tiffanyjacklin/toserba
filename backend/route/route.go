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

	// User
	e.GET("/user/login", controller.GetUser) // body form-data username & password
	e.GET("/user/:user_id", controller.GetDataUser)
	e.GET("/user/roles/:user_id", controller.GetRoles)
	e.GET("/user/privileges/:user_id/:role_id", controller.GetPriv)
	return e
}
