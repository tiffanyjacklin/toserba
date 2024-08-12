package model

import (
	"TemplateProject/db"
	"database/sql"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	// "fmt"
	// "encoding/json"
	"net/http"
)

func GetPhotoData(tabel, kolom_name, kolom_id, id string) (Response, error) {
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

	nId, _ := strconv.Atoi(id)

	query := fmt.Sprintf("SELECT %s FROM %s WHERE %s_id = %d", kolom_name, tabel, kolom_id, nId)
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt username check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow().Scan(&user.UserPhotoProfile)

	if err != nil {
		res.Status = http.StatusUnauthorized
		res.Message = "User Photo not exist"
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func GetUser(username, password string) (Response, error) {
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

	if err != nil {
		res.Status = http.StatusUnauthorized
		res.Message = "Username not exist"
		return res, err
	}

	query = "SELECT user_id, username, user_password FROM users WHERE username = ? AND user_password = ?"
	stmt, err = con.Prepare(query)
	if err != nil {
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

func GetDataUser(id_user, id_role string) (Response, error) {
	var res Response
	var user UserData
	var arrUser = []UserData{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE u.user_id = ? AND ur.roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	uid, _ := strconv.Atoi(id_user)
	rid, _ := strconv.Atoi(id_role)
	rows, err := stmt.Query(uid, rid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrUser = append(arrUser, user)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrUser
	return res, nil
}

func GetUserRoles(id_user string) (Response, error) {
	var res Response
	var urole UserRoles
	var arrRole = []UserRoles{}

	con, err := db.DbConnection()
	if err != nil {
		// fmt.Println("error db open")
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT ur.user_roles_id, ur.user_id, ur.roles_id, r.roles_name, ur.store_id, ur.warehouse_id, ur.custom FROM user_roles ur JOIN roles r ON ur.roles_id = r.roles_id WHERE ur.user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
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

func GetRolesByID (id_roles string) (Response, error) {
	var res Response
	var roles Roles

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT roles_id, roles_name FROM roles WHERE roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_roles)
	err = stmt.QueryRow(Id).Scan(&roles.RolesId, &roles.RolesName)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = roles
	return res, nil
}

func GetUserPriv (id_role, id_user string) (Response, error) {
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
	if err != nil {
		res.Status = 401
		res.Message = "Failed"
		res.Data = err.Error()
		return res, err
	}

	if custom == 1 {
		query = "SELECT up.user_privileges_id, up.role_id, up.privileges_id, p.privileges_name, p.navbar FROM user_privileges up JOIN privileges p ON up.privileges_id = p.privileges_id WHERE up.role_id = ? AND up.user_id = ?"
	} else {
		query = "SELECT rd.roles_default_id, rd.roles_id, rd.privileges_id, p.privileges_name, p.navbar FROM roles_default rd JOIN privileges p ON rd.privileges_id = p.privileges_id WHERE rd.roles_id = ?"
	}

	stmt2, err := con.Prepare(query)
	if err != nil {
		res.Status = http.StatusBadRequest
		res.Message = "stmt user check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt2.Close()

	var rows *sql.Rows

	if custom == 1 {
		rows, err = stmt2.Query(id_role, id_user)
		if err != nil {
			res.Status = 401
			res.Message = "rows gagal"
			res.Data = err.Error()
			return res, err
		}
	} else {
		rows, err = stmt2.Query(id_role)
		if err != nil {
			res.Status = 401
			res.Message = "rows gagal"
			res.Data = err.Error()
			return res, err
		}
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&upriv.UserPrivilegeId, &upriv.RoleId, &upriv.PrivilegeId, &upriv.PrivilegeName, &upriv.Navbar)
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

func GetPrivilegesByID (id_priv string) (Response, error) {
	var res Response
	var priv Privileges

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT privileges_id, privileges_name, navbar FROM privileges WHERE privileges_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_priv)
	err = stmt.QueryRow(Id).Scan(&priv.PrivilegesId, &priv.PrivilegesName, &priv.Navbar)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = priv
	return res, nil
}

func GetSessionByID (id_session string) (Response, error) {
	var res Response
	var sess Session

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT session_id, user_id, start_time, end_time, opening_cash, total_income, expected_closing_cash, actual_closing_cash, difference_cash, opening_notes, closing_notes, last_update_time FROM sessions WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	err = stmt.QueryRow(Id).Scan(&sess.SessionId, &sess.UserId, &sess.StartTime, &sess.EndTime, &sess.OpeningCash, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.DifferenceCash, &sess.OpeningNotes, &sess.ClosingNotes, &sess.LastUpdateTime)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sess
	return res, nil
}

func InsertNewSession (session string) (Response, error) {
	var res Response
	var sess  Session

	err := json.Unmarshal([]byte(session), &sess)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO sessions(user_id, start_time, opening_cash, opening_notes) VALUES (?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	startTime, _ := time.Parse("2006-01-02 15:04:05", sess.StartTime)
	result, err := stmt.Exec(sess.UserId, startTime, sess.OpeningCash, sess.OpeningNotes)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	lastId, err := result.LastInsertId()
	if err != nil {
		res.Status = 401
		res.Message = "last id gagal"
		res.Data = err.Error()
		return res, err
	}

	sess.SessionId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sess
	return res, nil
}

func UpdateClosingSession (id_session, session string) (Response, error) {
	var res Response
	var sess  Session

	err := json.Unmarshal([]byte(session), &sess)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "UPDATE sessions SET end_time = ?, expected_closing_cash = ?, actual_closing_cash = ?, difference_cash = ?, closing_notes = ? WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	endTime, _ := time.Parse("2006-01-02 15:04:05", sess.EndTime)
	_, err = stmt.Exec(endTime, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.DifferenceCash, &sess.ClosingNotes, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sess
	return res, nil
}

func UpdateSessionData (id_session, session string) (Response, error) {
	var res Response
	var sess  Session

	err := json.Unmarshal([]byte(session), &sess)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "UPDATE sessions SET last_update_time = ?, actual_closing_cash = ?, difference_cash = ?, closing_notes = ? WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	updateTime, _ := time.Parse("2006-01-02 15:04:05", sess.LastUpdateTime)
	_, err = stmt.Exec(updateTime, &sess.ActualClosingCash, &sess.DifferenceCash, &sess.ClosingNotes, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sess
	return res, nil
}

func InsertProductCategory (procat string)(Response, error) {
	var res Response
	var name sql.NullString
	var arrPro = []ProductCategories{}

	err := json.Unmarshal([]byte(procat), &arrPro)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	for _ ,x := range arrPro {
		query := "SELECT product_category_name FROM products_category WHERE product_category_name = ?"
		stmt, _ := con.Prepare(query)
		defer stmt.Close()

		err = stmt.QueryRow(&x.ProductCategoryName).Scan(&name)
		if err == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Product Category Name " + x.ProductCategoryName + " existed"
			return res, nil
		}
	}

	query := "INSERT INTO products_category(product_category_name) VALUES(?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i ,x := range arrPro {
		result, err := stmt.Exec(x.ProductCategoryName)
		if err != nil {
			res.Status = 401
			res.Message = "exec gagal"
			res.Data = err.Error()
			return res, err
		}
		lastId, err := result.LastInsertId()
		if err != nil {
			res.Status = 401
			res.Message = "last id gagal"
			res.Data = err.Error()
			return res, err
		}
		arrPro[i].ProductCategoryId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPro
	return res, nil
}

func GetStoreByID (id_store string) (Response, error) {
	var res Response
	var str Stores

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT store_id, store_name, store_address, store_phone_number FROM stores WHERE store_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_store)
	err = stmt.QueryRow(Id).Scan(&str.StoreId, &str.StoreName, &str.StoreAddress, &str.StorePhoneNumber)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = str
	return res, nil
}

func InsertStore(store string) (Response, error) {
	var res Response
	var str Stores

	err := json.Unmarshal([]byte(store), &str)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO stores(store_name, store_address, store_phone_number) VALUES (?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(&str.StoreName, &str.StoreAddress, &str.StorePhoneNumber)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	lastId, err := result.LastInsertId()
	if err != nil {
		res.Status = 401
		res.Message = "last id gagal"
		res.Data = err.Error()
		return res, err
	}

	str.StoreId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = str
	return res, nil
}

func GetWarehouseByID(id_warehouse string) (Response, error) {
	var res Response
	var wrh Warehouses

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT warehouse_id, warehouse_name, warehouse_address, warehouse_phone_number FROM warehouses WHERE warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_warehouse)
	err = stmt.QueryRow(Id).Scan(&wrh.WarehouseId, &wrh.WarehouseName, &wrh.WarehouseAddress, &wrh.WarehousePhoneNumber)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = wrh
	return res, nil
}

func InsertWarehouse(warehouse string) (Response, error) {
	var res Response
	var wrh Warehouses

	err := json.Unmarshal([]byte(warehouse), &wrh)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO warehouses(warehouse_name, warehouse_address, warehouse_phone_number) VALUES (?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(&wrh.WarehouseName, &wrh.WarehouseAddress, &wrh.WarehousePhoneNumber)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	lastId, err := result.LastInsertId()
	if err != nil {
		res.Status = 401
		res.Message = "last id gagal"
		res.Data = err.Error()
		return res, err
	}

	wrh.WarehouseId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = wrh
	return res, nil
}

func InsertRoles(roles string)(Response, error) {
	var res Response
	var name string
	var arrRole = []Roles{}

	err := json.Unmarshal([]byte(roles), &arrRole)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	for _ ,x := range arrRole {
		query := "SELECT roles_name FROM roles WHERE roles_name = ?"
		stmt, _ := con.Prepare(query)
		defer stmt.Close()

		err = stmt.QueryRow(&x.RolesName).Scan(&name)
		if err == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Role Name " + x.RolesName + " existed"
			return res, nil
		}
	}

	query := "INSERT INTO roles(roles_name) VALUE (?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i ,x := range arrRole {
		result, err := stmt.Exec(x.RolesName)
		if err != nil {
			res.Status = 401
			res.Message = "exec gagal"
			res.Data = err.Error()
			return res, err
		}
		lastId, err := result.LastInsertId()
		if err != nil {
			res.Status = 401
			res.Message = "last id gagal"
			res.Data = err.Error()
			return res, err
		}
		arrRole[i].RolesId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrRole
	return res, nil
}

func InsertPrivileges(priv string)(Response, error) {
	var res Response
	var name string
	var arrPrv = []Privileges{}

	err := json.Unmarshal([]byte(priv), &arrPrv)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	for _ ,x := range arrPrv {
		query := "SELECT privileges_name FROM privileges WHERE privileges_name = ?"
		stmt, _ := con.Prepare(query)
		defer stmt.Close()

		err = stmt.QueryRow(&x.PrivilegesName).Scan(&name)
		if err == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Privilege Name " + x.PrivilegesName + " existed"
			return res, nil
		}
	}

	query := "INSERT INTO privileges(privileges_name, navbar) VALUE (?, ?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i ,x := range arrPrv {
		result, err := stmt.Exec(x.PrivilegesName, x.Navbar)
		if err != nil {
			res.Status = 401
			res.Message = "exec gagal"
			res.Data = err.Error()
			return res, err
		}
		lastId, err := result.LastInsertId()
		if err != nil {
			res.Status = 401
			res.Message = "last id gagal"
			res.Data = err.Error()
			return res, err
		}
		arrPrv[i].PrivilegesId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrv
	return res, nil
}

func InsertRolesDefault(roled string)(Response, error) {
	var res Response
	var arrRD = []RolesDefault{}

	err := json.Unmarshal([]byte(roled), &arrRD)
	if err != nil {
		res.Status = 401
		res.Message = "gagal decode json"
		res.Data = err.Error()
		return res, err
	}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	for _ ,x := range arrRD {
		subid := strconv.Itoa(x.RolesId)
		check, err := GetRolesByID(subid)
		if (err != nil || check.Data == nil) {
			res.Status = http.StatusBadRequest
			res.Message = "Roles ID " + subid+ " not exist"
			return res, nil
		}

		tchid := strconv.Itoa(x.PrivilegesId)
		check, err = GetPrivilegesByID(tchid)
		if (err != nil || check.Data == nil) {
			res.Status = http.StatusBadRequest
			res.Message = "Privileges iD " + tchid + " not exist"
			return res, nil
		}
	}

	query := "INSERT INTO roles_default (roles_id, privileges_id) VALUES(?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i ,x := range arrRD {
		result, err := stmt.Exec(x.RolesId, x.PrivilegesId)
		if err != nil {
			res.Status = 401
			res.Message = "exec gagal"
			res.Data = err.Error()
			return res, err
		}
		lastId, err := result.LastInsertId()
		if err != nil {
			res.Status = 401
			res.Message = "last id gagal"
			res.Data = err.Error()
			return res, err
		}
		arrRD[i].RoleDefaultId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrRD
	return res, nil
}