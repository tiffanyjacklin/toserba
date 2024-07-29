package model

import (
	"TemplateProject/db"
	"database/sql"
	"strconv"

	// "fmt"
	// "encoding/json"
	"net/http"
)

func GetUser(username, password string)(Response, error) {
	var res Response
	var user User

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT user_id FROM users WHERE username =?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt username check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(username).Scan(&user.UserId)

	if (err != nil)  {
		res.Status = http.StatusUnauthorized
		res.Message = "Username not exist"
		return res, err
	}

	query = "SELECT user_id, username, user_password FROM users WHERE username = ? AND user_password = ?"
	stmt, err = con.Prepare(query)
	if (err != nil) {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(username, password).Scan(&user.UserId, &user.Username, &user.Password)

	if err != nil {
		res.Status = http.StatusBadRequest
		res.Message = "Incorrect Username or Password"
		return res, nil
	}

	query = "UPDATE users SET user_login_timestamp = NOW() WHERE username = ?"
	stmt, err = con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(username)
	if err != nil {
		res.Status = http.StatusInternalServerError
		res.Message = "Failed to update login timestamp"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func GetDataUser(id_user string)(Response, error) {
	var res Response
	var user UserData

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT user_id, username, user_password, user_fullname, user_address, user_gender, user_birthdate, user_email, user_phone_number, user_photo_profile, user_login_timestamp FROM users WHERE user_id = ?"
	stmt, err := con.Prepare(query)
	if (err != nil) {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	uid, _ := strconv.Atoi(id_user)
	err = stmt.QueryRow(uid).Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp)

	if err != nil {
		res.Status = http.StatusBadRequest
		res.Message = "Invalid user id"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func GetRoles(id_user string)(Response, error) {
	var res Response
	var urole UserRoles
	var arrRole = []UserRoles{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT ur.user_roles_id, ur.user_id, ur.roles_id, r.roles_name, ur.store_id, ur.warehouse_id, ur.custom FROM user_roles ur JOIN roles r ON ur.roles_id = r.roles_id WHERE ur.user_id = ?"
	stmt, err := con.Prepare(query)
	if (err != nil) {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query(id_user)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
		}
	defer rows.Close()

	for rows.Next() {	
		err = rows.Scan(&urole.UserRoleId, &urole.UserId, &urole.RoleId, &urole.RoleName, &urole.StoreId, &urole.WarehouseId, &urole.Custom)		
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
			}
		arrRole = append(arrRole, urole)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrRole
	return res, nil
}

func GetPriv(id_role, id_user string) (Response, error) {
	var res Response
	var custom int16
	var upriv UserPrivilege
	var arrPriv = []UserPrivilege{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT custom FROM user_roles WHERE roles_id = ? AND user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(id_role, id_user).Scan(&custom)

	if (custom == 1) {
		query = "SELECT up.user_privileges_id, up.role_id, up.privileges_id, p.navbar FROM user_privileges up JOIN privileges p ON up.privileges_id = p.privileges_id WHERE up.role_id = ? AND up.user_id = ?"	
	} else {
		query = "SELECT rd.roles_default_id, rd.roles_id, rd.privileges_id, p.navbar FROM roles_default rd JOIN privileges p ON rd.privileges_id = p.privileges_id WHERE rd.roles_id = ?"
	}

	stmt, err = con.Prepare(query)
	if (err != nil) {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	var rows *sql.Rows

	if custom == 1 {
		rows, err = stmt.Query(id_role, id_user)
		if err != nil {
			res.Status = 401
			res.Message = "rows gagal"
			res.Data = err.Error()
			return res, err
		}
	} else {
		rows, err = stmt.Query(id_role)
		if err != nil {
			res.Status = 401
			res.Message = "rows gagal"
			res.Data = err.Error()
			return res, err
		}
	}
	defer rows.Close()

	for rows.Next() {	
		err = rows.Scan(&upriv.UserPrivilegeId, &upriv.RoleId, &upriv.PrivilegeId, &upriv.Navbar)		
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
			}
		arrPriv = append(arrPriv, upriv)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPriv
	return res, nil
}
