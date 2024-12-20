package model

import (
	"TemplateProject/db"
	"database/sql"
	"encoding/json"
	"fmt"
	"math"
	"math/rand"
	"net/http"
	"net/smtp"
	"strconv"
	"time"
)

func GenerateOTP() string {
	// var res Response
	otp := rand.Intn(9000) + 100000

	return strconv.Itoa(otp)
}

func SendEmail(toEmail, otp string) error {
	from := "c14210021@john.petra.ac.id"
	password := "bnkp otmd lwcr biif"
	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	subject := "Your OTP Code"
	body := fmt.Sprintf(
		"Your OTP is: %s\n\nPlease do not reply to this email. Replies are not monitored.",
		otp,
	)
	message := fmt.Sprintf(
		"From: %s\nTo: %s\nReply-To: no-reply@example.com\nSubject: %s\n\n%s",
		from, toEmail, subject, body,
	)

	// Authentication
	auth := smtp.PlainAuth("", from, password, smtpHost)

	// Sending email
	err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{toEmail}, []byte(message))
	if err != nil {
		fmt.Printf("SMTP error: %v", err)
		return err
	}
	return err
}

func AccountSendOTP(id_user string) (Response, error) {
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

	query := "SELECT user_email FROM users WHERE user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_user)
	err = stmt.QueryRow(&Id).Scan(&user.UserEmail)
	if err != nil {
		res.Status = http.StatusBadRequest
		res.Message = "User ID " + id_user + " not existed"
		return res, nil
	}

	user.UserOTP = GenerateOTP()

	err = SendEmail(user.UserEmail, user.UserOTP)
	if err != nil {
		res.Status = 401
		res.Message = "Send Email Failed"
		res.Data = err.Error()
		return res, err
	}

	query = "UPDATE users SET user_otp = ?, otp_exp = ? WHERE user_id = ?"
	stmt, err = con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	expTime := time.Now().Add(5 * time.Minute)
	user.OTPExp = expTime.Format("2006-01-02 15:04:05")
	_, err = stmt.Exec(&user.UserOTP, &user.OTPExp, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func ResetOTP(id_user int, res Response, con *sql.DB) (Response, error) {
	query := "UPDATE users SET user_otp = '', otp_exp = '0000-00-00 00:00:00' WHERE user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(id_user)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}
	return res, nil
}

func OTPVerification(id_user, vOtp string) (Response, error) {
	var res Response
	var user UserData
	var verifOtp OTPRequest

	err := json.Unmarshal([]byte(vOtp), &verifOtp)
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

	query := "SELECT user_otp, otp_exp FROM users WHERE user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_user)
	_ = stmt.QueryRow(&Id).Scan(&user.UserOTP, &user.OTPExp)

	endTime, err := time.Parse("2006-01-02 15:04:05", user.OTPExp)
	if err != nil {
		res.Status = 401
		res.Message = "Error Parsing Time"
		res.Data = err.Error()
		return res, err
	}

	if endTime.Before(time.Now()) {
		res.Status = 401
		res.Message = "OTP Not Valid Anymore"
		ResetOTP(Id, res, con)
	} else if user.UserOTP != verifOtp.OTP {
		res.Status = 401
		res.Message = "Incorrect OTP"
	} else {
		res.Status = http.StatusOK
		res.Message = "Berhasil"
		res.Data = user
		ResetOTP(Id, res, con)
	}

	return res, nil
}

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

func GetAllUser() (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
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

func GetAllUserByRoleID(id_role string) (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE ur.roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rid, _ := strconv.Atoi(id_role)
	rows, err := stmt.Query(rid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
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

func GetUserByID(id_user string) (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE u.user_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rid, _ := strconv.Atoi(id_user)
	rows, err := stmt.Query(rid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
		if err != nil {
			if err == sql.ErrNoRows {
				user = UserData{}
				res.Status = http.StatusOK
				res.Message = "Data Not Exist"
				res.Data = user
				return res, nil
			}
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

func GetUserByName(user_name string) (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE u.user_fullname LIKE ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	searchName := "%" + user_name + "%"

	rows, err := stmt.Query(searchName)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
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

func GetUserByStoreWarehouseID(id_sw string) (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE ur.store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rid, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(rid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
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

func GetDataUser(id_user, id_role string) (Response, error) {
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

	query := "SELECT u.user_id, u.username, u.user_password, u.user_fullname, u.user_address, u.user_gender, u.user_birthdate, u.user_email, u.user_phone_number, u.user_photo_profile, u.user_login_timestamp, ur.roles_id, r.roles_name, ur.store_warehouse_id FROM users u JOIN user_roles ur ON u.user_id = ur.user_id JOIN roles r ON r.roles_id = ur.roles_id WHERE u.user_id = ? AND ur.roles_id = ?"
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
	err = stmt.QueryRow(uid, rid).Scan(&user.UserId, &user.Username, &user.Password, &user.UserFullName, &user.UserAddress, &user.UserGender, &user.UserBirthDate, &user.UserEmail, &user.UserPhoneNumber, &user.UserPhotoProfile, &user.LoginTimestamp, &user.RoleId, &user.RoleName, &user.StoreWarehouseID)
	if err != nil {
		if err == sql.ErrNoRows {
			user = UserData{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = user
			return res, nil
		}
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func GetUserRoles(id_user string) (Response, error) {
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

	query := "SELECT ur.user_roles_id, ur.user_id, ur.roles_id, r.roles_name, ur.store_warehouse_id, ur.custom FROM user_roles ur JOIN roles r ON ur.roles_id = r.roles_id WHERE ur.user_id = ?"
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
		err = rows.Scan(&urole.UserRoleId, &urole.UserId, &urole.RoleId, &urole.RoleName, &urole.StoreWarehouseID, &urole.Custom)
		if err != nil {
			if err == sql.ErrNoRows {
				urole = UserRoles{}
				res.Status = http.StatusOK
				res.Message = "Data Not Exist"
				res.Data = urole
				return res, nil
			}
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

func InsertNewUserRoles(userrole string) (Response, error) {
	var res Response
	var user UserRoles

	err := json.Unmarshal([]byte(userrole), &user)
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

	uid := strconv.Itoa(user.UserId)
	rid := strconv.Itoa(user.RoleId)
	check, _ := GetUserByID(uid)
	userData, ok := check.Data.([]UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if userData[0].UserId == 0 {
		res.Status = 500
		res.Message = "User not exist"
		return res, fmt.Errorf("user id %d not exist", user.UserId)
	}

	check, _ = GetRolesByID(rid) 
	roleData, ok := check.Data.(Roles)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if roleData.RolesId == 0 {
		res.Status = 500
		res.Message = "Role not exist"
		return res, fmt.Errorf("role id %d not exist", user.RoleId)
	}

	query := "INSERT INTO user_roles(roles_id, user_id, store_warehouse_id, custom) VALUES (?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(user.RoleId, user.UserId, user.StoreWarehouseID, user.Custom)
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

	user.UserRoleId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = user
	return res, nil
}

func UpdateUserRoles(id_user, id_role, userrole string) (Response, error) {
	var res Response
	var urole UserRoles

	err := json.Unmarshal([]byte(userrole), &urole)
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

	check, _ := GetUserRoles(id_user)
	userData, ok := check.Data.([]UserRoles)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if userData[0].UserRoleId == 0 {
		res.Status = 500
		res.Message = "User have not role registered yet"
		return res, fmt.Errorf("user id %s have not role registered yet", id_user)
	}

	query := "UPDATE user_roles SET roles_id = ?, store_warehouse_id = ?, custom = ? WHERE user_id = ? AND roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_user)
	rid, _ := strconv.Atoi(id_role)
	_, err = stmt.Exec(&urole.RoleId, &urole.StoreWarehouseID, &urole.Custom, Id, rid)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = urole
	return res, nil
}

func UpdateUserStoreWarehouse(id_user, id_role, id_sw string) (Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetUserRoles(id_user)
	userData, ok := check.Data.([]UserRoles)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if userData[0].UserRoleId == 0 {
		res.Status = 500
		res.Message = "User have not role registered yet"
		return res, fmt.Errorf("user id %s have not role registered yet", id_user)
	}

	query := "UPDATE user_roles SET store_warehouse_id = ? WHERE user_id = ? AND roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_user)
	rid, _ := strconv.Atoi(id_role)
	swid, _ := strconv.Atoi(id_sw)
	_, err = stmt.Exec(swid, Id, rid)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	return res, nil
}

func GetRolesByID(id_roles string) (Response, error) {
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
		if err == sql.ErrNoRows {
            roles = Roles{}
            res.Status = http.StatusOK
            res.Message = "Data Not Exist"
            res.Data = roles
            return res, nil
        }
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

func GetUserPriv(id_role, id_user string) (Response, error) {
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

func GetPrivilegesByID(id_priv string) (Response, error) {
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

func GetSessionByID(id_session string) (Response, error) {
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

	query := "SELECT s.session_id, s.user_id, u.user_fullname ,s.start_time, s.end_time, s.opening_cash, s.total_income, s.expected_closing_cash, s.actual_closing_cash, s.actual_difference, s.deposit_money, s.deposit_difference, s.opening_notes, s.closing_notes, s.last_update_time FROM sessions s JOIN users u ON s.user_id = u.user_id WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	err = stmt.QueryRow(Id).Scan(&sess.SessionId, &sess.UserId, &sess.UserFullName, &sess.StartTime, &sess.EndTime, &sess.OpeningCash, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.OpeningNotes, &sess.ClosingNotes, &sess.LastUpdateTime)
	if err != nil {
		if err == sql.ErrNoRows {
           	sess = Session{}
            res.Status = http.StatusOK
            res.Message = "Data Not Exist"
            res.Data = sess
            return res, nil
        }
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

func GetSessionBySWID(id_sw string) (Response, error) {
	var res Response
	var sess SessionUser
	var arrSess = []SessionUser{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetStoreWarehouseByID(id_sw)
	swData, ok := check.Data.(StoreWarehouses)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if swData.StoreWarehouseId == 0 {
		res.Status = 500
		res.Message = "Store not exist"
		return res, fmt.Errorf("store ID %s not exist", id_sw)
	}

	if swData.StoreWarehouseType != "STORE" {
		res.Status = 500
		res.Message = "Select a store"
		return res, fmt.Errorf("sw %s is not a store", id_sw)
	}

	query := "SELECT s.session_id, s.user_id, u.user_fullname ,s.start_time, s.end_time, s.opening_cash, s.total_income, s.expected_closing_cash, s.actual_closing_cash, s.actual_difference, s.deposit_money, s.deposit_difference, s.opening_notes, s.closing_notes, s.last_update_time, ur.store_warehouse_id FROM sessions s JOIN users u ON s.user_id = u.user_id JOIN user_roles ur ON ur.user_id = s.user_id WHERE ur.roles_id = 1 AND ur.store_warehouse_id = ? GROUP BY s.session_id ASC"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rid, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(rid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sess.Session.SessionId, &sess.Session.UserId, &sess.Session.UserFullName, &sess.Session.StartTime, &sess.Session.EndTime, &sess.Session.OpeningCash, &sess.Session.TotalIncome, &sess.Session.ExpectedClosingCash, &sess.Session.ActualClosingCash, &sess.Session.ActualDifference, &sess.Session.DepositMoney, &sess.Session.DepositDifference, &sess.Session.OpeningNotes, &sess.Session.ClosingNotes, &sess.Session.LastUpdateTime, &sess.UserData.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSess = append(arrSess, sess)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSess
	return res, nil
}

func GetLastSession() (Response, error) {
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

	query := "SELECT session_id, user_id, start_time, end_time, opening_cash, total_income, expected_closing_cash, actual_closing_cash, actual_difference, deposit_money, deposit_difference, opening_notes, closing_notes, last_update_time FROM sessions ORDER BY session_id DESC LIMIT 1"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow().Scan(&sess.SessionId, &sess.UserId, &sess.StartTime, &sess.EndTime, &sess.OpeningCash, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.OpeningNotes, &sess.ClosingNotes, &sess.LastUpdateTime)
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

func GetAllSession() (Response, error) {
	var res Response
	var sess Session
	var arrSess = []Session{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT s.session_id, s.user_id, u.user_fullname ,s.start_time, s.end_time, s.opening_cash, s.total_income, s.expected_closing_cash, s.actual_closing_cash, s.actual_difference, s.deposit_money, s.deposit_difference, s.opening_notes, s.closing_notes, s.last_update_time FROM sessions s JOIN users u ON s.user_id = u.user_id ORDER BY s.session_id"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sess.SessionId, &sess.UserId, &sess.UserFullName, &sess.StartTime, &sess.EndTime, &sess.OpeningCash, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.OpeningNotes, &sess.ClosingNotes, &sess.LastUpdateTime)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSess = append(arrSess, sess)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSess
	return res, nil
}

func InsertNewSession(session string) (Response, error) {
	var res Response
	var sess Session

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

	check, err := GetLastSession()

	sessionData, ok := check.Data.(Session)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if sessionData.DepositDifference != sess.OpeningCash {
		res.Status = 401
		res.Message = "Input Correct Value"
		// res.Data = err.Error()
		return res, err
	}

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

func UpdateClosingSession(id_session, session string) (Response, error) {
	var res Response
	var sess Session

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

	if sess.DepositDifference > 100000 {
		res.Status = 401
		res.Message = "Too Much"
		// res.Data = err.Error()
		return res, err
	}

	// check, _ := GetTotalIncomePerSession(id_session)
	// incomeData, ok := check.Data.(Session)
	// if !ok {
	// 	res.Status = 500
	// 	res.Message = "Unexpected data format"
	// 	return res, fmt.Errorf("unexpected data format")
	// }

	// if incomeData.TotalIncome != sess.TotalIncome {
	// 	res.Status = 500
	// 	res.Message = "Wrong Total Income"
	// 	return res, fmt.Errorf("input: %d, expected: %d", sess.TotalIncome, incomeData.TotalIncome)
	// }

	query := "UPDATE sessions SET end_time = ?, total_income = ?, expected_closing_cash = ?, actual_closing_cash = ?, actual_difference = ?, deposit_money = ?, deposit_difference =?, closing_notes = ? WHERE session_id = ?"
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
	_, err = stmt.Exec(endTime, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.ClosingNotes, Id)
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

func UpdateSessionData(id_session, session string) (Response, error) {
	var res Response
	var sess Session

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

	check, _ := GetLastSession()

	sessionData, ok := check.Data.(Session)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	layout := "2006-01-02 15:04:05"

	endTime, err := time.Parse(layout, sessionData.EndTime)
	if err != nil {
		res.Status = 401
		res.Message = "Error Parsing Time"
		res.Data = err.Error()
		return res, err
	}

	updateTime, err := time.Parse(layout, sess.LastUpdateTime)
	if err != nil {
		res.Status = 401
		res.Message = "Error Parsing Time"
		res.Data = err.Error()
		return res, err
	}

	duration := updateTime.Sub(endTime)

	if duration > 30*time.Minute {
		res.Status = 401
		res.Message = "Cannot Edit Session"
		// res.Data = err.Error()
		return res, err
	}

	query := "UPDATE sessions SET last_update_time = ?, actual_closing_cash = ?, actual_difference = ?, deposit_money =?, deposit_difference = ?, closing_notes = ? WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	_, err = stmt.Exec(updateTime, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.ClosingNotes, Id)
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

func GetNotVerifiedSession() (Response, error) {
	var res Response
	var sess Session
	var arrSess = []Session{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT session_id, user_id, start_time, end_time, opening_cash, total_income, expected_closing_cash, actual_closing_cash, actual_difference, deposit_money, deposit_difference, opening_notes, closing_notes, last_update_time, status_verify FROM sessions WHERE status_verify = 0 AND actual_closing_cash != 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sess.SessionId, &sess.UserId, &sess.StartTime, &sess.EndTime, &sess.OpeningCash, &sess.TotalIncome, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.OpeningNotes, &sess.ClosingNotes, &sess.LastUpdateTime, &sess.StatusVerify)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSess = append(arrSess, sess)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSess
	return res, nil
}

func VerifySession(id_session string) (Response, error) {
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

	Id, _ := strconv.Atoi(id_session)

	check, _ := GetSessionByID(id_session)
	SessData, ok := check.Data.(Session)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if SessData.SessionId == 0 {
		res.Status = 500
		res.Message = "Session not exist"
		return res, fmt.Errorf("session ID %s not exist", id_session)
	}

	query := "UPDATE sessions SET status_verify = 1 WHERE session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(Id)
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

func GetMemberByID(id_member string) (Response, error) {
	var res Response
	var mbr Members

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT member_id, member_name, member_phone_number, member_points, member_join_date FROM members WHERE member_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_member)
	err = stmt.QueryRow(Id).Scan(&mbr.MemberId, &mbr.MemberName, &mbr.MemberPhoneNumber, &mbr.MemberPoints, &mbr.MemberJoinDate)
	if err != nil {
		if err == sql.ErrNoRows {
            mbr = Members{}
            res.Status = http.StatusOK
            res.Message = "Data Not Exist"
            res.Data = mbr
            return res, nil
        }
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = mbr
	return res, nil
}

func GetMemberByPhoneNumber(phonenumber string) (Response, error) {
	var res Response
	var mbr Members

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT member_id, member_name, member_phone_number, member_points, member_join_date FROM members WHERE member_phone_number = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(phonenumber).Scan(&mbr.MemberId, &mbr.MemberName, &mbr.MemberPhoneNumber, &mbr.MemberPoints, &mbr.MemberJoinDate)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = mbr
	return res, nil
}

func GetAllMember() (Response, error) {
	var res Response
	var mbr Members
	var arrMbr = []Members{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	// query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions"
	query := "SELECT member_id, member_name, member_phone_number, member_points, member_join_date FROM members"

	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&mbr.MemberId, &mbr.MemberName, &mbr.MemberPhoneNumber, &mbr.MemberPoints, &mbr.MemberJoinDate)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrMbr = append(arrMbr, mbr)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrMbr
	return res, nil
}

func InsertNewMember(member string) (Response, error) {
	var res Response
	var mbr Members

	err := json.Unmarshal([]byte(member), &mbr)
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

	check, err := GetMemberByPhoneNumber(mbr.MemberPhoneNumber)
	if err == nil && check.Data != nil {
		res.Status = http.StatusBadRequest
		res.Message = "Phone Number " + mbr.MemberPhoneNumber + " exist"
		return res, nil
	}

	query := "INSERT INTO members(member_name, member_phone_number, member_join_date) VALUES(?, ?, ?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	joinDate, _ := time.Parse("2006-01-02 15:04:05", mbr.MemberJoinDate)
	result, err := stmt.Exec(mbr.MemberName, mbr.MemberPhoneNumber, joinDate)
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
	mbr.MemberId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = mbr
	return res, nil
}

func UpdateMemberPoints(id_member string, points int) (Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "UPDATE members SET member_points = member_points + ? WHERE member_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_member)
	_, err = stmt.Exec(points, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	return res, nil
}

func InsertProductCategory(procat string) (Response, error) {
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

	for _, x := range arrPro {
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

	for i, x := range arrPro {
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

func GetProductByID(id_product, id_user, id_role string) (Response, error) {
	var res Response
	var prd ProductCombine
	var userData UserData

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)
	
	if (id_user != "" || id_role != "") {
		check, _ := GetDataUser(id_user, id_role)
		userData, _ = check.Data.(UserData)
	} 

	query := "SELECT pd.product_detail_id, pd.product_code, pc.product_category_id, pc.product_category_name, pd.product_name, s.supplier_id, s.supplier_name, pd.buy_price, pd.sell_price, pd.min_stock, pd.product_unit, pd.product_timestamp, sw.store_warehouse_id FROM product_details pd JOIN sw_products sw ON pd.product_detail_id = sw.product_detail_id JOIN products_category pc ON pc.product_category_id = pd.product_category_id JOIN suppliers s ON s.supplier_id = pd.supplier_id WHERE pd.product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	err = stmt.QueryRow(Id).Scan(&prd.ProductDetails.ProductDetailId, &prd.ProductDetails.ProductCode, &prd.ProductCategories.ProductCategoryId, &prd.ProductCategories.ProductCategoryName, &prd.ProductDetails.ProductName, &prd.Suppliers.SupplierId, &prd.Suppliers.SupplierName, &prd.ProductDetails.BuyPrice, &prd.ProductDetails.SellPrice, &prd.ProductDetails.MinStock, &prd.ProductDetails.ProductUnit, &prd.ProductDetails.ProductTimeStamp, &prd.ProductDetails.StoreWarehouseID)
	if err != nil {
		fmt.Println("HAHAHHsssssA", err)
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	if userData.UserId != 0 {
		pid := strconv.Itoa(prd.ProductDetails.ProductDetailId)
		wid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ := GetTotalStockByProductIDSWID(pid, wid)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		prd.ProductDetails.ProductStock = stockData.ProductStock
		if stockData.ProductStock > 0 {
			check, _ = GetEarliestEXPByProductID(pid, wid)
			expData, ok := check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
			prd.ProductDetails.ExpiryDate = expData.ExpiredDate
			prd.ProductDetails.ProductBatch = expData.ProductBatch
		}
	}	

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = prd
	return res, nil
}

func GetProductByCode(product_code, id_user, id_role string) (Response, error) {
	var res Response
	var prd ProductCombine

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT pd.product_detail_id, pd.product_code, pc.product_category_id, pc.product_category_name, pd.product_name, s.supplier_id, s.supplier_name, pd.buy_price, pd.sell_price, pd.min_stock, pd.product_unit, pd.product_timestamp, sw.store_warehouse_id FROM product_details pd JOIN sw_products sw ON pd.product_detail_id = sw.product_detail_id JOIN products_category pc ON pc.product_category_id = pd.product_category_id JOIN suppliers s ON s.supplier_id = pd.supplier_id WHERE pd.product_code = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(product_code).Scan(&prd.ProductDetails.ProductDetailId, &prd.ProductDetails.ProductCode, &prd.ProductCategories.ProductCategoryId, &prd.ProductCategories.ProductCategoryName, &prd.ProductDetails.ProductName, &prd.Suppliers.SupplierId, &prd.Suppliers.SupplierName, &prd.ProductDetails.BuyPrice, &prd.ProductDetails.SellPrice, &prd.ProductDetails.MinStock, &prd.ProductDetails.ProductUnit, &prd.ProductDetails.ProductTimeStamp, &prd.ProductDetails.StoreWarehouseID)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	pid := strconv.Itoa(prd.ProductDetails.ProductDetailId)
	wid := strconv.Itoa(userData.StoreWarehouseID)
	check, _ = GetTotalStockByProductIDSWID(pid, wid)
	stockData, ok := check.Data.(StockCards)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	prd.ProductDetails.ProductStock = stockData.ProductStock

	if stockData.ProductStock > 0 {
		check, _ = GetEarliestEXPByProductID(pid, wid)
		expData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		prd.ProductDetails.ExpiryDate = expData.ExpiredDate
		prd.ProductDetails.ProductBatch = expData.ProductBatch
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = prd
	return res, nil
}

func GetProductByName(product_name, id_user, id_role string) (Response, error) {
	var res Response
	var prd ProductCombine
	var arrPrd = []ProductCombine{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT pd.product_detail_id, pd.product_code, pc.product_category_id, pc.product_category_name, pd.product_name, s.supplier_id, s.supplier_name, pd.buy_price, pd.sell_price, pd.min_stock, pd.product_unit, pd.product_timestamp, sw.store_warehouse_id FROM product_details pd JOIN sw_products sw ON pd.product_detail_id = sw.product_detail_id JOIN products_category pc ON pc.product_category_id = pd.product_category_id JOIN suppliers s ON s.supplier_id = pd.supplier_id WHERE pd.product_name LIKE ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	searchName := "%" + product_name + "%"

	rows, err := stmt.Query(searchName)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prd.ProductDetails.ProductDetailId, &prd.ProductDetails.ProductCode, &prd.ProductCategories.ProductCategoryId, &prd.ProductCategories.ProductCategoryName, &prd.ProductDetails.ProductName, &prd.Suppliers.SupplierId, &prd.Suppliers.SupplierName, &prd.ProductDetails.BuyPrice, &prd.ProductDetails.SellPrice, &prd.ProductDetails.MinStock, &prd.ProductDetails.ProductUnit, &prd.ProductDetails.ProductTimeStamp, &prd.ProductDetails.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		pid := strconv.Itoa(prd.ProductDetails.ProductDetailId)
		wid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ = GetTotalStockByProductIDSWID(pid, wid)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		prd.ProductDetails.ProductStock = stockData.ProductStock

		if stockData.ProductStock > 0 {
			check, _ = GetEarliestEXPByProductID(pid, wid)
			expData, ok := check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
			prd.ProductDetails.ExpiryDate = expData.ExpiredDate
			prd.ProductDetails.ProductBatch = expData.ProductBatch
		}

		arrPrd = append(arrPrd, prd)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrd
	return res, nil
}

func GetAllProducts(id_user, id_role string) (Response, error) {
	var res Response
	var prd ProductCombine
	var arrPrd = []ProductCombine{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT pd.product_detail_id, pd.product_code, pc.product_category_id, pc.product_category_name, pd.product_name, s.supplier_id, s.supplier_name, pd.buy_price, pd.sell_price, pd.min_stock, pd.product_unit, pd.product_timestamp, sw.store_warehouse_id FROM product_details pd JOIN sw_products sw ON pd.product_detail_id = sw.product_detail_id JOIN products_category pc ON pc.product_category_id = pd.product_category_id JOIN suppliers s ON s.supplier_id = pd.supplier_id;"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prd.ProductDetails.ProductDetailId, &prd.ProductDetails.ProductCode, &prd.ProductCategories.ProductCategoryId, &prd.ProductCategories.ProductCategoryName, &prd.ProductDetails.ProductName, &prd.Suppliers.SupplierId, &prd.Suppliers.SupplierName, &prd.ProductDetails.BuyPrice, &prd.ProductDetails.SellPrice, &prd.ProductDetails.MinStock, &prd.ProductDetails.ProductUnit, &prd.ProductDetails.ProductTimeStamp, &prd.ProductDetails.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}

		pid := strconv.Itoa(prd.ProductDetails.ProductDetailId)
		wid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ = GetTotalStockByProductIDSWID(pid, wid)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		prd.ProductDetails.ProductStock = stockData.ProductStock

		if stockData.ProductStock > 0 {
			check, _ = GetEarliestEXPByProductID(pid, wid)
			expData, ok := check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
			prd.ProductDetails.ExpiryDate = expData.ExpiredDate
			prd.ProductDetails.ProductBatch = expData.ProductBatch
		}

		arrPrd = append(arrPrd, prd)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrd
	return res, nil
}

func GetAllProductsInStoreWarehouse(id_user, id_role string) (Response, error) {
	var res Response
	var prd ProductCombine
	var arrPrd = []ProductCombine{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT pd.product_detail_id, pd.product_code, pd.product_category_id, pc.product_category_name, pd.product_name, pd.supplier_id, s.supplier_name, pd.buy_price, pd.sell_price, pd.min_stock, pd.product_unit, pd.product_timestamp, sc.expired_date, sc.product_batch FROM product_details pd JOIN stock_cards sc ON pd.product_detail_id = sc.product_detail_id JOIN suppliers s ON s.supplier_id = pd.supplier_id JOIN products_category pc ON pc.product_category_id = pd.product_category_id WHERE sc.store_warehouse_id = ? GROUP BY sc.expired_date"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query(userData.StoreWarehouseID)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prd.ProductDetails.ProductDetailId, &prd.ProductDetails.ProductCode, &prd.ProductCategories.ProductCategoryId, &prd.ProductCategories.ProductCategoryName, &prd.ProductDetails.ProductName, &prd.Suppliers.SupplierId, &prd.Suppliers.SupplierName, &prd.ProductDetails.BuyPrice, &prd.ProductDetails.SellPrice, &prd.ProductDetails.MinStock, &prd.ProductDetails.ProductUnit, &prd.ProductDetails.ProductTimeStamp, &prd.ProductDetails.ExpiryDate, &prd.ProductDetails.ProductBatch)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}

		pid := strconv.Itoa(prd.ProductDetails.ProductDetailId)
		wid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ = GetTotalStockByEXPPIDSWID(pid, wid, prd.ProductDetails.ExpiryDate)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		prd.ProductDetails.ProductStock = stockData.ProductStock

		arrPrd = append(arrPrd, prd)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrd
	return res, nil
}

func InsertProductDetails(product, id_sw string) (Response, error) {
	var res Response
	var code string
	var type_sw string
	var arrPro = []ProductDetails{}

	err := json.Unmarshal([]byte(product), &arrPro)
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

	for _, x := range arrPro {
		query := "SELECT product_code FROM product_details WHERE product_code = ?"
		stmt, _ := con.Prepare(query)
		defer stmt.Close()

		err = stmt.QueryRow(x.ProductCode).Scan(&code)
		if err == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Product Code " + code + " existed"
			return res, nil
		}
	}

	query := "SELECT store_warehouse_type FROM store_warehouses WHERE store_warehouse_id =?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt username check failed"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_sw)
	err = stmt.QueryRow(swid).Scan(&type_sw)

	if err != nil {
		res.Status = http.StatusUnauthorized
		res.Message = "ID Store Warehouse not exist"
		return res, err
	}

	query = "INSERT INTO product_details(product_code, product_category_id, product_name, supplier_id, buy_price, sell_price, min_stock, product_unit, product_timestamp) VALUES(?,?,?,?,?,?,?,?,NOW())"
	stmt, err = con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPro {
		if type_sw == "WAREHOUSE" && x.WarehousePlacement == "" {
			res.Status = http.StatusUnauthorized
			res.Message = "Insert Product Placement"
			return res, err
		}

		result, err := stmt.Exec(x.ProductCode, x.ProductCategoryId, x.ProductName, x.SupplierId, x.BuyPrice, x.SellPrice, x.MinStock, x.ProductUnit)
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
		arrPro[i].ProductDetailId = int(lastId)

		_, _ = InsertSWProducts(id_sw, int(lastId), x.WarehousePlacement)

		data, err := json.Marshal([]map[string]interface{}{{
			"product_detail_id":  lastId,
			"stock_description":  "First Stock",
			"product_batch":      x.ProductBatch,
			"expired_date":       x.ExpiryDate,
			"stock_in":           x.ProductStock,
			"store_warehouse_id": swid,
		}})
		if err != nil {
			res.Status = 401
			res.Message = "json stock card error"
			res.Data = err.Error()
			return res, err
		}
		_, _ = InsertStockCards(string(data))
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPro
	return res, nil
}

func InsertSWProducts(id_sw string, id_product int, placement string) (Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO sw_products(product_detail_id, store_warehouse_id, section_placement) VALUES(?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	sId, _ := strconv.Atoi(id_sw)
	result, err := stmt.Exec(id_product, sId, placement)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = result
	return res, nil
}

func GetTotalOfTransaction(id_transaction int, con *sql.DB) (Response, error) {
	var res Response
	var trd Transaction

	query := "SELECT COALESCE(SUM(total_price),0), COALESCE(SUM(quantity),0) FROM transaction_details WHERE transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(id_transaction).Scan(&trd.TransactionTotalPrice, &trd.TotalItem)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Data = trd
	return res, nil
}

func GetTransactionByID(id_transaction string) (Response, error) {
	var res Response
	var trs TransactionAttribute

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT t.transaction_id, t.transaction_total_price, t.transaction_timestamp, t.transaction_payment_method_id, t.transaction_payment, t.transaction_change, t.transaction_total_item, u.user_id, u.user_fullname, pm.payment_method_name FROM transactions t JOIN payment_method pm ON t.transaction_payment_method_id = pm.payment_method_id JOIN session_transactions st ON t.transaction_id = st.transaction_id JOIN sessions s ON st.session_id = s.session_id JOIN users u ON s.user_id = u.user_id WHERE t.transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_transaction)
	err = stmt.QueryRow(Id).Scan(&trs.Transaction.TransactionId, &trs.Transaction.TransactionTotalPrice, &trs.Transaction.TransactionTimeStamp, &trs.PaymentMethod.PaymentMethodId, &trs.Transaction.TransactionPayment, &trs.Transaction.TransactionChange, &trs.Transaction.TotalItem, &trs.UserData.UserId, &trs.UserData.UserFullName, &trs.PaymentMethod.PaymentMethodName)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = trs
	return res, nil
}

func GetTransactionBySWID(id_sw string) (Response, error) {
	var res Response
	var trs TransactionAttribute
	var arrTrs = []TransactionAttribute{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetStoreWarehouseByID(id_sw)
	swData, ok := check.Data.(StoreWarehouses)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if swData.StoreWarehouseId == 0 {
		res.Status = 500
		res.Message = "Store not exist"
		return res, fmt.Errorf("store ID %s not exist", id_sw)
	}

	if swData.StoreWarehouseType != "STORE" {
		res.Status = 500
		res.Message = "Select a store"
		return res, fmt.Errorf("sw %s is not a store", id_sw)
	}

	query := "SELECT t.transaction_id, t.transaction_total_price, t.transaction_timestamp, t.transaction_payment_method_id, t.transaction_payment, t.transaction_change, t.transaction_total_item, u.user_id, u.user_fullname, pm.payment_method_name, ur.store_warehouse_id FROM transactions t JOIN payment_method pm ON t.transaction_payment_method_id = pm.payment_method_id JOIN session_transactions st ON t.transaction_id = st.transaction_id JOIN sessions s ON st.session_id = s.session_id JOIN users u ON s.user_id = u.user_id JOIN user_roles ur ON ur.user_id = s.user_id WHERE ur.store_warehouse_id = ? AND ur.roles_id = 1 GROUP BY t.transaction_id ASC"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&trs.Transaction.TransactionId, &trs.Transaction.TransactionTotalPrice, &trs.Transaction.TransactionTimeStamp, &trs.PaymentMethod.PaymentMethodId, &trs.Transaction.TransactionPayment, &trs.Transaction.TransactionChange, &trs.Transaction.TotalItem, &trs.UserData.UserId, &trs.UserData.UserFullName, &trs.PaymentMethod.PaymentMethodName, &trs.UserData.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTrs = append(arrTrs, trs)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTrs
	return res, nil
}

func GetLastTransaction() (Response, error) {
	var res Response
	var trs Transaction

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions  ORDER BY transaction_id DESC LIMIT 1"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow().Scan(&trs.TransactionId, &trs.TransactionTotalPrice, &trs.TransactionTimeStamp, &trs.PaymentMethodId, &trs.TransactionPayment, &trs.TransactionChange, &trs.TotalItem)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = trs
	return res, nil
}

func GetAllTransaction() (Response, error) {
	var res Response
	var trs Transaction
	var arrTrs = []Transaction{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	// query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions"
	query := "SELECT t.transaction_id, t.transaction_total_price, t.transaction_timestamp, t.transaction_payment_method_id, t.transaction_payment, t.transaction_change, t.transaction_total_item, u.user_fullname FROM transactions t JOIN session_transactions st ON t.transaction_id = st.transaction_id JOIN sessions s ON st.session_id = s.session_id JOIN users u ON s.user_id = u.user_id"

	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&trs.TransactionId, &trs.TransactionTotalPrice, &trs.TransactionTimeStamp, &trs.PaymentMethodId, &trs.TransactionPayment, &trs.TransactionChange, &trs.TotalItem, &trs.TransactionUser)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTrs = append(arrTrs, trs)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTrs
	return res, nil
}

func GetTransactionDetailByTransactionID(id_transaction string) (Response, error) {
	var res Response
	var trs TransactionDetails
	var arrTrs = []TransactionDetails{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT td.transaction_detail_id, td.transaction_id, td.product_detail_id, pd.product_name, td.promo_product_id, td.quantity, td.sell_price, td.discount_price, td.total_price, td.quantity_free FROM transaction_details td JOIN product_details pd ON td.product_detail_id = pd.product_detail_id WHERE transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_transaction)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&trs.TransactionDetailId, &trs.TransactionId, &trs.ProductDetailId, &trs.ProductDetailName, &trs.PromoProductId, &trs.Quantity, &trs.SellPrice, &trs.DiscountPrice, &trs.TotalPrice, &trs.QuantityFree)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTrs = append(arrTrs, trs)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTrs
	return res, nil
}

func InsertTransactionDetails(transaction, id_user, id_role string) (Response, error) {
	var res Response
	var arrTrd = []TransactionDetails{}

	err := json.Unmarshal([]byte(transaction), &arrTrd)
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

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	for _, x := range arrTrd {
		pid := strconv.Itoa(x.ProductDetailId)
		sid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ := GetTotalStockByProductIDSWID(pid, sid)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format: got %T", check.Data)
		}

		if x.Quantity > stockData.ProductStock {
			res.Status = 500
			res.Message = "Not Enough Stock"
			return res, fmt.Errorf("not enough stock for ID product %d: %f", x.ProductDetailId, stockData.ProductStock)
		}
	}

	check, _ = CreateTransaction()
	transactionData, ok := check.Data.(Transaction)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format: got %T", check.Data)
	}

	query := "INSERT INTO transaction_details(transaction_id, product_detail_id, promo_product_id, quantity, sell_price, discount_price, total_price, quantity_free) VALUES(?,?,?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrTrd {
		result, err := stmt.Exec(transactionData.TransactionId, x.ProductDetailId, x.PromoProductId, x.Quantity, x.SellPrice, x.DiscountPrice, x.TotalPrice, x.QuantityFree)
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
		arrTrd[i].TransactionDetailId = int(lastId)

		data, err := json.Marshal([]map[string]interface{}{{
			"product_detail_id":  x.ProductDetailId,
			"stock_description":  "Purchase",
			"stock_out":          x.Quantity,
			"store_warehouse_id": userData.StoreWarehouseID,
		}})
		if err != nil {
			res.Status = 401
			res.Message = "json stock card error"
			res.Data = err.Error()
			return res, err
		}
		_, _ = InsertStockCards(string(data))
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTrd
	return res, nil
}

func CreateTransaction() (Response, error) {
	var res Response
	var trs Transaction

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO transactions(transaction_timestamp, transaction_payment_method_id) VALUES(NOW(), 1)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec()
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
	trs.TransactionId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = trs
	return res, nil
}

func InsertTransaction(id_transaction, id_session, id_member, transaction string) (Response, error) {
	var res Response
	var trs Transaction

	err := json.Unmarshal([]byte(transaction), &trs)
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

	mid, _ := strconv.Atoi(id_member)
	if mid != 0 {
		check, _ := GetMemberByID(id_member)
		mbrData, ok := check.Data.(Members)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		if mbrData.MemberId == 0 {
			res.Status = 500
			res.Message = "Member Not Existed"
			return res, fmt.Errorf("member ID %s not existed", id_member)
		}

		if mbrData.MemberPoints + trs.MemberPointOut < 0 {
			res.Status = 500
			res.Message = "Not Enough Point"
			return res, fmt.Errorf("not enough point")
		}
	}

	Id, _ := strconv.Atoi(id_transaction)
	check, _ := GetTotalOfTransaction(Id, con)
	sessionData, ok := check.Data.(Transaction)
	if !ok {
		fmt.Print("ERROR", ok)
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	_, _ = InsertSessionTransaction(Id, id_session)

	if mid != 0 {
		_, _ = InsertMemberTransaction(Id, id_member, trs.MemberPointIn, trs.MemberPointOut)
		if trs.MemberPointIn != 0 || trs.MemberPointOut != 0 {
			_, _ = UpdateMemberPoints(id_member, (trs.MemberPointIn + trs.MemberPointOut))
		}
	}

	query := "UPDATE transactions SET transaction_total_price = ?, transaction_timestamp = NOW(), transaction_payment_method_id = ?, transaction_payment = ?, transaction_change = ?, transaction_total_item = ? WHERE transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(sessionData.TransactionTotalPrice, trs.PaymentMethodId, trs.TransactionPayment, trs.TransactionChange, sessionData.TotalItem, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = trs
	return res, nil
}

func GetTransactionIDBySessionID(id_session string) (Response, error) {
	var res Response
	var trs Transaction
	var arrTS = []Transaction{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT t.transaction_id, t.transaction_total_price, t.transaction_timestamp, t.transaction_payment_method_id, t.transaction_payment, t.transaction_change, t.transaction_total_item, u.user_fullname FROM transactions t JOIN session_transactions st ON t.transaction_id = st.transaction_id JOIN sessions s ON st.session_id = s.session_id JOIN users u ON s.user_id = u.user_id WHERE st.session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_session)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&trs.TransactionId, &trs.TransactionTotalPrice, &trs.TransactionTimeStamp, &trs.PaymentMethodId, &trs.TransactionPayment, &trs.TransactionChange, &trs.TotalItem, &trs.TransactionUser)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTS = append(arrTS, trs)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTS
	return res, nil
}

func GetTotalIncomePerSession(id_session string) (Response, error) {
	var res Response
	var sc Session

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT SUM(t.transaction_total_price) FROM transactions t JOIN session_transactions st ON t.transaction_id = st.transaction_id WHERE st.session_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_session)
	err = stmt.QueryRow(pid).Scan(&sc.TotalIncome)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func InsertSessionTransaction(id_transaction int, id_session string) (Response, error) {
	var res Response
	// var trs Transaction

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO session_transactions(session_id, transaction_id) VALUES(?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	sId, _ := strconv.Atoi(id_session)
	result, err := stmt.Exec(sId, id_transaction)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = result
	return res, nil
}

func GetTransactionIDByMemberID(id_member string) (Response, error) {
	var res Response
	var ts TransactionMember
	var arrTS = []TransactionMember{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transaction_id FROM transactions_member WHERE member_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_member)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&ts.TransactionId)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTS = append(arrTS, ts)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTS
	return res, nil
}

func InsertMemberTransaction(id_transaction int, id_member string, mp_in int, mp_out int) (Response, error) {
	var res Response
	// var trs Transaction

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO transactions_member(member_id, transaction_id, member_point_in, member_point_out) VALUES(?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	sId, _ := strconv.Atoi(id_member)
	result, err := stmt.Exec(sId, id_transaction, mp_in, mp_out)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = result
	return res, nil
}

func InsertPromoType(protype string) (Response, error) {
	var res Response
	var arrPrt = []PromoTypes{}

	err := json.Unmarshal([]byte(protype), &arrPrt)
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

	query := "INSERT INTO promo_type(promo_type_name) VALUE (?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPrt {
		result, err := stmt.Exec(x.PromoTypeName)
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
		arrPrt[i].PromoTypeId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrt
	return res, nil
}

func GetPromoByID(id_promo string) (Response, error) {
	var res Response
	var prm Promos

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT promo_id, promo_code, promo_type_id, promo_start_date, promo_end_date, promo_percentage, promo_discount, promo_term_and_cond, x_amount, y_amount FROM promos WHERE promo_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_promo)
	err = stmt.QueryRow(Id).Scan(&prm.PromoId, &prm.PromoCode, &prm.PromoTypeId, &prm.PromoStartDate, &prm.PromoEndDate, &prm.PromoPercentage, &prm.PromoDiscount, &prm.TermAndCond, &prm.XAmount, &prm.YAmount)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = prm
	return res, nil
}

func GetAllPromos() (Response, error) {
	var res Response
	var prm PromoProductsss
	var arrPrm = []PromoProductsss{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT p.product_detail_id, p.product_code, p.product_category_id, p.product_name, p.supplier_id, p.buy_price, p.product_stock, p.expired_date, p.sell_price, p.min_stock, p.product_unit, p.product_timestamp, pr.promo_id, pr.promo_code, pr.promo_type_id, pr.promo_start_date, pr.promo_end_date, pr.promo_percentage, pr.promo_discount, pr.promo_term_and_cond, pr.x_amount, pr.y_amount FROM product_details p JOIN promo_products pp ON p.product_detail_id = pp.product_detail_id JOIN promos pr ON pp.promo_id = pr.promo_id"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prm.ProductDetail.ProductDetailId, &prm.ProductDetail.ProductCode, &prm.ProductDetail.ProductCategoryId, &prm.ProductDetail.ProductName, &prm.ProductDetail.SupplierId, &prm.ProductDetail.BuyPrice, &prm.ProductDetail.ProductStock, &prm.ProductDetail.ExpiryDate, &prm.ProductDetail.SellPrice, &prm.ProductDetail.MinStock, &prm.ProductDetail.ProductUnit, &prm.ProductDetail.ProductTimeStamp, &prm.Promo.PromoId, &prm.Promo.PromoCode, &prm.Promo.PromoTypeId, &prm.Promo.PromoStartDate, &prm.Promo.PromoEndDate, &prm.Promo.PromoPercentage, &prm.Promo.PromoDiscount, &prm.Promo.TermAndCond, &prm.Promo.XAmount, &prm.Promo.YAmount)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrPrm = append(arrPrm, prm)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrm
	return res, nil
}

func GetAllActivePromos() (Response, error) {
	var res Response
	var prm PromoProductsss
	var arrPrm = []PromoProductsss{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT p.product_detail_id, p.product_code, p.product_category_id, p.product_name, p.supplier_id, p.buy_price, p.product_stock, p.expired_date, p.sell_price, p.min_stock, p.product_unit, p.product_timestamp, pr.promo_id, pr.promo_code, pr.promo_type_id, pr.promo_start_date, pr.promo_end_date, pr.promo_percentage, pr.promo_discount, pr.promo_term_and_cond, pr.x_amount, pr.y_amount FROM product_details p JOIN promo_products pp ON p.product_detail_id = pp.product_detail_id JOIN promos pr ON pp.promo_id = pr.promo_id WHERE pr.promo_end_date > NOW()"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prm.ProductDetail.ProductDetailId, &prm.ProductDetail.ProductCode, &prm.ProductDetail.ProductCategoryId, &prm.ProductDetail.ProductName, &prm.ProductDetail.SupplierId, &prm.ProductDetail.BuyPrice, &prm.ProductDetail.ProductStock, &prm.ProductDetail.ExpiryDate, &prm.ProductDetail.SellPrice, &prm.ProductDetail.MinStock, &prm.ProductDetail.ProductUnit, &prm.ProductDetail.ProductTimeStamp, &prm.Promo.PromoId, &prm.Promo.PromoCode, &prm.Promo.PromoTypeId, &prm.Promo.PromoStartDate, &prm.Promo.PromoEndDate, &prm.Promo.PromoPercentage, &prm.Promo.PromoDiscount, &prm.Promo.TermAndCond, &prm.Promo.XAmount, &prm.Promo.YAmount)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrPrm = append(arrPrm, prm)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrm
	return res, nil
}

func GetPromoIDByProductID(id_product string) (Response, error) {
	var res Response
	var pp PromoProducts
	var arrPP = []PromoProducts{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT promo_product_id, product_detail_id, promo_id FROM promo_products WHERE product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&pp.PromoProductId, &pp.ProductDetailId, &pp.PromoId)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrPP = append(arrPP, pp)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPP
	return res, nil
}

func InsertPromos(promo string) (Response, error) {
	var res Response
	var code string
	var arrPrm = []Promos{}

	err := json.Unmarshal([]byte(promo), &arrPrm)
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

	for _, x := range arrPrm {
		query := "SELECT promo_code FROM promos WHERE promo_code = ?"
		stmt, _ := con.Prepare(query)
		defer stmt.Close()

		err = stmt.QueryRow(&x.PromoCode).Scan(&code)
		if err == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Promo Code " + code + " existed"
			return res, nil
		}
	}

	query := "INSERT INTO promos(promo_code, promo_type_id, promo_start_date, promo_end_date, promo_percentage, promo_discount, promo_term_and_cond, x_amount, y_amount) VALUES (?,?,?,?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPrm {
		startDate, _ := time.Parse("2006-01-02", x.PromoStartDate)
		endDate, _ := time.Parse("2006-01-02", x.PromoEndDate)

		if endDate.Before(startDate) {
			res.Status = 401
			res.Message = "End Date must after Start Date"
			return res, nil
		}

		if x.PromoTypeId == 1 && (x.XAmount == 0 || x.YAmount == 0) {
			res.Status = 401
			res.Message = "Input X and Y value"
			return res, nil
		} else if x.PromoTypeId == 2 && x.PromoPercentage == 0 {
			res.Status = 401
			res.Message = "Input Discount Percentage"
			return res, nil
		} else if x.PromoTypeId == 3 && x.PromoDiscount == 0 {
			res.Status = 401
			res.Message = "Input Discount Nominal"
			return res, nil
		}

		result, err := stmt.Exec(x.PromoCode, x.PromoTypeId, startDate, endDate, x.PromoPercentage, x.PromoDiscount, x.TermAndCond, x.XAmount, x.YAmount)
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
		arrPrm[i].PromoId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrm
	return res, nil
}

func InsertPromoProducts(promo string) (Response, error) {
	var res Response
	var arrPrd = []PromoProducts{}

	err := json.Unmarshal([]byte(promo), &arrPrd)
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

	for _, x := range arrPrd {
		pdid := strconv.Itoa(x.ProductDetailId)
		check, err := GetProductByID(pdid, "", "")
		if err != nil || check.Data == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Product ID " + pdid + " not exist"
			return res, nil
		}

		pid := strconv.Itoa(x.PromoId)
		check, err = GetPromoByID(pid)
		if err != nil || check.Data == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Promo ID " + pid + " not exist"
			return res, nil
		}
	}

	query := "INSERT INTO promo_products(product_detail_id, promo_id) VALUES (?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPrd {
		result, err := stmt.Exec(x.ProductDetailId, x.PromoId)
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
		arrPrd[i].PromoProductId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrd
	return res, nil
}

func UpdatePromoToAllProducts(id_promo string) (Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "INSERT INTO promo_products (product_detail_id, promo_id) SELECT product_detail_id, ? FROM product_details"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_promo)

	_, err = stmt.Exec(Id)
	if err != nil {
		res.Status = 401
		res.Message = "Failed to execute SQL statement"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Successfully updated promo for all products"
	res.Data = nil
	return res, nil
}

func GetPaymentMethodByID(id_payment string) (Response, error) {
	var res Response
	var prm PaymentMethod

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT payment_method_id, payment_method_name FROM payment_method WHERE payment_method_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_payment)
	err = stmt.QueryRow(Id).Scan(&prm.PaymentMethodId, &prm.PaymentMethodName)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = prm
	return res, nil
}

func GetAllPaymentMethod() (Response, error) {
	var res Response
	var prm PaymentMethod
	var arrPrm = []PaymentMethod{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT payment_method_id, payment_method_name FROM payment_method"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&prm.PaymentMethodId, &prm.PaymentMethodName)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrPrm = append(arrPrm, prm)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrm
	return res, nil
}

func InsertPaymentMethod(payment string) (Response, error) {
	var res Response
	var arrPay = []PaymentMethod{}

	err := json.Unmarshal([]byte(payment), &arrPay)
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

	query := "INSERT INTO payment_method(payment_method_name) VALUE (?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPay {
		result, err := stmt.Exec(x.PaymentMethodName)
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
		arrPay[i].PaymentMethodId = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPay
	return res, nil
}

func InsertStockCards(stockcard string) (Response, error) {
	var res Response
	var totalStock float64
	var arrSC = []StockCards{}

	err := json.Unmarshal([]byte(stockcard), &arrSC)
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

	query := "INSERT INTO stock_cards(product_detail_id, stock_date, stock_description, product_name, product_batch, product_stock, expired_date, stock_in, stock_out, store_warehouse_id) VALUE (?,NOW(),?,?,?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrSC {
		pid := strconv.Itoa(x.ProductDetailID)
		wid := strconv.Itoa(x.StoreWarehouseID)
		check, _ := GetTotalStockByProductIDSWID(pid, wid)
		SCData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		check, _ = GetProductByID(pid,"","")
		productData, ok := check.Data.(ProductCombine)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		if SCData.ProductStock != 0 {
			check, _ = GetLastProductIDInStockCard(pid, wid)
			lastSCData, ok := check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
			totalStock = lastSCData.ProductStock + x.StockIn - x.StockOut
		} else {
			totalStock = x.StockIn - x.StockOut
		}

		if (x.StockOut > 0 && x.ExpiredDate == "") {

			check, _ = ProcessStockOut(pid, wid, x.StockOut, x.StockDescription, i, arrSC)
			stockData, ok := check.Data.([]StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}

			arrSC = stockData
		} else {
			expiredDate, _ := time.Parse("2006-01-02", x.ExpiredDate)
			result, err := stmt.Exec(x.ProductDetailID, x.StockDescription, productData.ProductDetails.ProductName, x.ProductBatch, totalStock, expiredDate, x.StockIn, x.StockOut, x.StoreWarehouseID)
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
			arrSC[i].StockCardID = int(lastId)
		}
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func ProcessStockOut(pid string, wid string, stockOut float64, desc string, i int, arrSC []StockCards) (Response, error) {
	var res Response
	var totalStock float64

    if stockOut <= 0 {
		res.Status = 401
		res.Message = "stockOut must be greater than zero"
		return res, nil
    }

    con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

    query := "INSERT INTO stock_cards(product_detail_id, stock_date, stock_description, product_name, product_batch, product_stock, expired_date, stock_in, stock_out, store_warehouse_id) VALUES(?,NOW(),?,?,?,?,?,?,?,?)"
	
    stmt, err := con.Prepare(query)
    if err != nil {
		fmt.Print(err)
        res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
    }
    defer stmt.Close()

	check, _ := GetEarliestEXPByProductID(pid, wid)
	expData, ok := check.Data.(StockCards)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

    for stockOut > 0 {
		var stockData StockCards
		if expData.ExpiredDate == "0000-00-00" {
			check, _ := GetTotalStockByEarliestStockDate(pid, wid)
			stockData, ok = check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
		} else {
			check, _ := GetTotalStockByEarliestEXPDate(pid, wid)
			stockData, ok = check.Data.(StockCards)
			if !ok {
				res.Status = 500
				res.Message = "Unexpected data format"
				return res, fmt.Errorf("unexpected data format")
			}
		}

        if stockData.ProductStock == 0 {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("no stock available for product %s", pid)
        }

		check, _ = GetStockCardByProductID(pid)
		SCData, ok := check.Data.([]StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		if len(SCData) == 0 {
			res.Status = 500
			res.Message = "Stock Empty"
			return res, fmt.Errorf("unexpected data format")
		} 

		check, _ = GetLastProductIDInStockCard(pid, wid)
		lastSCData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

        deductedStock := math.Min(float64(stockOut), float64(stockData.ProductStock))
		totalStock = lastSCData.ProductStock - deductedStock

        expiredDate, _ := time.Parse("2006-01-02", stockData.ExpiredDate)
        result, err := stmt.Exec(pid, desc, stockData.ProductName, stockData.ProductBatch, totalStock, expiredDate, 0, int(deductedStock), wid)
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
		arrSC[i].StockCardID = int(lastId)

        stockOut -= deductedStock
    }
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC

    return res, nil
}

func GetAllStockCard() (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id ORDER BY sc.stock_card_id ASC"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByID(id_stockcard string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.stock_card_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_stockcard)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	found := false
	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.ProductUnit, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
		found = true
	}

	if !found {
		res.Status = 401
		res.Message = "no rows"
		res.Data = nil
		return res, nil
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByProductID(id_product string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByEXPDate(id_product, expdate string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.product_detail_id = ? AND sc.expired_date = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	rows, err := stmt.Query(Id, expdate)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByStoreWarehouse(id_warehouse string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	wId, _ := strconv.Atoi(id_warehouse)
	rows, err := stmt.Query(wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByPIDStoreWarehouse(id_product, id_warehouse string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.product_detail_id = ? AND sc.store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	wId, _ := strconv.Atoi(id_warehouse)
	rows, err := stmt.Query(Id, wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByStoreWarehouseEXPDate(id_warehouse, exp_date string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.expired_date = ? AND sc.store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	wId, _ := strconv.Atoi(id_warehouse)
	rows, err := stmt.Query(exp_date, wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetStockCardByStoreWarehouseBatch(id_warehouse, batch string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.product_batch = ? AND sc.store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	wId, _ := strconv.Atoi(id_warehouse)
	rows, err := stmt.Query(batch, wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

// Ngambil data terakhir dari id_product tertentu
func GetLastProductIDInStockCard(id_product, id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.stock_card_id, sc.product_detail_id, sc.stock_date, sc.stock_description, sc.product_name, sc.product_batch, sc.product_stock, sc.expired_date, sc.stock_in, sc.stock_out, sc.store_warehouse_id, pd.product_unit FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.product_detail_id = ? AND sc.store_warehouse_id = ? ORDER BY sc.stock_card_id DESC LIMIT 1"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	wid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(pid, wid).Scan(&sc.StockCardID, &sc.ProductDetailID, &sc.StockDate, &sc.StockDescription, &sc.ProductName, &sc.ProductBatch, &sc.ProductStock, &sc.ExpiredDate, &sc.StockIn, &sc.StockOut, &sc.StoreWarehouseID, &sc.ProductUnit)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetEarliestEXPByProductID(id_product, id_sw string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT MIN(expired_date), product_batch FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY expired_date HAVING SUM(stock_in) - SUM(stock_out) > 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_sw)
	err = stmt.QueryRow(pid, swid).Scan(&sc.ExpiredDate, &sc.ProductBatch)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = ""
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetEarliestStockDateByProductID(id_product, id_sw string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT MIN(stock_date), product_batch FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY stock_date HAVING SUM(stock_in) - SUM(stock_out) > 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_sw)
	err = stmt.QueryRow(pid, swid).Scan(&sc.StockDate, &sc.ProductBatch)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = ""
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetAllEXPDateByProductID(id_product string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT expired_date FROM stock_cards WHERE product_detail_id = ? GROUP BY expired_date"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	wId, _ := strconv.Atoi(id_product)
	rows, err := stmt.Query(wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.ExpiredDate)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetAllEXPDateByProductIDSWID(id_product, id_sw string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetStoreWarehouseByID(id_sw)
	swData, ok := check.Data.(StoreWarehouses)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if swData.StoreWarehouseId == 0 {
		res.Status = 500
		res.Message = "Store/Warehouse not exist"
		return res, fmt.Errorf("store/warehouse ID %s not exist", id_sw)
	}

	query := "SELECT expired_date FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY expired_date"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pId, _ := strconv.Atoi(id_product)
	wId, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(pId, wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.ExpiredDate)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetAllBatchByProductID(id_product string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT product_batch FROM stock_cards WHERE product_detail_id = ? GROUP BY product_batch"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	wId, _ := strconv.Atoi(id_product)
	rows, err := stmt.Query(wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.ProductBatch)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetAllBatchByProductIDSWID(id_product, id_sw string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetStoreWarehouseByID(id_sw)
	swData, ok := check.Data.(StoreWarehouses)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if swData.StoreWarehouseId == 0 {
		res.Status = 500
		res.Message = "Store/Warehouse not exist"
		return res, fmt.Errorf("store/warehouse ID %s not exist", id_sw)
	}

	query := "SELECT product_batch FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY product_batch"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pId, _ := strconv.Atoi(id_product)
	wId, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(pId, wId)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.ProductBatch)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetTotalStockByProductID(id_product string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	err = stmt.QueryRow(pid).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByProductIDSWID(id_product, id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(pid, swid).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByEXPPIDSWID(id_product, id_storewarehouse, exp_date string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? AND expired_date = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(pid, swid, exp_date).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByBatchSWID(batch, id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_batch = ? AND store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(batch, swid).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByBatchPIDSWID(id_product, id_storewarehouse, batch string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? AND product_batch = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(pid, swid, batch).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByBatchEXPPIDSWID(id_product, id_storewarehouse, exp_date, batch string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT COALESCE(SUM(stock_in) - SUM(stock_out), 0) FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? AND expired_date = ? AND product_batch = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(pid, swid, exp_date, batch).Scan(&sc.ProductStock)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByEarliestEXPDate(id_product, id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetEarliestEXPByProductID(id_product, id_storewarehouse)
	expData, ok := check.Data.(StockCards)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT product_name, SUM(stock_in) - SUM(stock_out), expired_date, product_batch FROM stock_cards WHERE expired_date = ? AND product_detail_id = ? AND store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(expData.ExpiredDate, pid, swid).Scan(&sc.ProductName, &sc.ProductStock, &sc.ExpiredDate, &sc.ProductBatch)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetTotalStockByEarliestStockDate(id_product, id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockCards

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetEarliestStockDateByProductID(id_product, id_storewarehouse)
	expData, ok := check.Data.(StockCards)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "SELECT product_name, SUM(stock_in) - SUM(stock_out), stock_date, product_batch FROM stock_cards WHERE stock_date = ? AND product_detail_id = ? AND store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	err = stmt.QueryRow(expData.StockDate, pid, swid).Scan(&sc.ProductName, &sc.ProductStock, &sc.ExpiredDate, &sc.ProductBatch)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sc
	return res, nil
}

func GetProductForTransferNote(id_product string, id_storewarehouse string, quantity string) (Response, error) {
	var res Response
	var sc StockCards
	var arrSC = []StockCards{}
	var result = []StockCards{}
	var query string

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetEarliestEXPByProductID(id_product, id_storewarehouse)
	expData, ok := check.Data.(StockCards)
	fmt.Println(expData, check)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if expData.ExpiredDate == "0000-00-00" {
		query = "SELECT product_detail_id, store_warehouse_id, stock_date, expired_date, product_batch, SUM(stock_in) - SUM(stock_out) AS available_stock FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY stock_date, product_batch ASC"
	} else {
		query = "SELECT product_detail_id, store_warehouse_id, stock_date, expired_date, product_batch, SUM(stock_in) - SUM(stock_out) AS available_stock FROM stock_cards WHERE product_detail_id = ? AND store_warehouse_id = ? GROUP BY expired_date, product_batch ASC"
	}

	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pId, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_storewarehouse)
	qty, _ := strconv.ParseFloat(quantity, 64)
	rows, err := stmt.Query(pId, swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.ProductDetailID, &sc.StoreWarehouseID, &sc.StockDate, &sc.ExpiredDate, &sc.ProductBatch, &sc.ProductStock)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	for _, stock := range arrSC {
        if stock.ProductStock <= 0 {
            continue
        }

		take := math.Min(stock.ProductStock, qty)
		result = append(result, StockCards{
            ProductDetailID:   stock.ProductDetailID,
            ProductStock:    take,
			StockDate: stock.StockDate,
            ExpiredDate: stock.ExpiredDate,
			ProductBatch: stock.ProductBatch,
			StoreWarehouseID: stock.StoreWarehouseID,
        })

		qty -= take

		if qty == 0 {
            break
        }
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = result
	return res, nil
}

func GetDataforStockOpname() (Response, error) {
	var res Response
	var delo StockOpname
	var arrDel = []StockOpname{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.product_detail_id, pd.product_name, sc.product_batch, sc.expired_date, pd.product_unit, sc.store_warehouse_id FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id GROUP BY sc.product_detail_id, sc.store_warehouse_id, sc.product_batch, sc.expired_date ORDER BY sc.store_warehouse_id, sc.product_batch, sc.expired_date"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.ProductDetailID, &delo.ProductName, &delo.Batch, &delo.ExpiredDate, &delo.UnitType, &delo.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		pid := strconv.Itoa(delo.ProductDetailID)
		swid := strconv.Itoa(delo.StoreWarehouseID)
		check, _ := GetTotalStockByBatchEXPPIDSWID(pid, swid, delo.ExpiredDate, delo.Batch)
		SCData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		delo.ExpectedStock = SCData.ProductStock

		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetDataforStockOpnameBySWID(id_storewarehouse string) (Response, error) {
	var res Response
	var delo StockOpname
	var arrDel = []StockOpname{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sc.product_detail_id, pd.product_name, sc.product_batch, sc.expired_date, pd.product_unit, sc.store_warehouse_id FROM stock_cards sc JOIN product_details pd ON sc.product_detail_id = pd.product_detail_id WHERE sc.store_warehouse_id = ? GROUP BY sc.product_detail_id, sc.store_warehouse_id, sc.product_batch, sc.expired_date ORDER BY sc.product_batch, sc.expired_date"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_storewarehouse)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.ProductDetailID, &delo.ProductName, &delo.Batch, &delo.ExpiredDate, &delo.UnitType, &delo.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		pid := strconv.Itoa(delo.ProductDetailID)
		sw_id := strconv.Itoa(delo.StoreWarehouseID)
		check, _ := GetTotalStockByBatchEXPPIDSWID(pid, sw_id, delo.ExpiredDate, delo.Batch)
		SCData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		delo.ExpectedStock = SCData.ProductStock

		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetStockOpnameBySWID(id_storewarehouse string) (Response, error) {
	var res Response
	var sc StockOpname
	var arrSC = []StockOpname{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT stock_opname_id, product_detail_id, batch, expired_date, expected_stock, actual_stock, unit_type, timestamp, store_warehouse_id FROM stock_opname WHERE store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_storewarehouse)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockOpnameID, &sc.ProductDetailID, &sc.Batch, &sc.ExpiredDate, &sc.ExpectedStock, &sc.ActualStock, &sc.UnitType, &sc.Timestamp, &sc.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func GetAllStockOpname() (Response, error) {
	var res Response
	var sc StockOpname
	var arrSC = []StockOpname{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT stock_opname_id, product_detail_id, batch, expired_date, expected_stock, actual_stock, unit_type, timestamp, store_warehouse_id FROM stock_opname"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sc.StockOpnameID, &sc.ProductDetailID, &sc.Batch, &sc.ExpiredDate, &sc.ExpectedStock, &sc.ActualStock, &sc.UnitType, &sc.Timestamp, &sc.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSC = append(arrSC, sc)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSC
	return res, nil
}

func InsertStockOpname(opname string) (Response, error) {
	var res Response
	var arrPay = []StockOpname{}

	err := json.Unmarshal([]byte(opname), &arrPay)
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

	query := "INSERT INTO stock_opname(product_detail_id, batch, expired_date, expected_stock, actual_stock, unit_type, timestamp, store_warehouse_id) VALUE (?,?,?,?,?,?,NOW(),?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPay {
		exp, _ := time.Parse("2006-01-02", x.ExpiredDate)

		pid := strconv.Itoa(x.ProductDetailID)
		sw_id := strconv.Itoa(x.StoreWarehouseID)
		check, _ := GetTotalStockByBatchEXPPIDSWID(pid, sw_id, x.ExpiredDate, x.Batch)
		SCData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}

		result, err := stmt.Exec(x.ProductDetailID, x.Batch, exp, SCData.ProductStock, x.ActualStock, x.UnitType, x.StoreWarehouseID)
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
		arrPay[i].ProductDetailID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPay
	return res, nil
}

func CheckMinStock(id_product, id_storewarehouse string) (Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetTotalStockByProductIDSWID(id_product, id_storewarehouse)
	stockData, ok := check.Data.(StockCards)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	check, _ = GetProductByID(id_product, "", "")
	productData, ok := check.Data.(ProductDetails)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if stockData.ProductStock < productData.MinStock {
		res.Status = http.StatusOK
		res.Message = "Low Stock"
		res.Data = false
	} else {
		res.Status = http.StatusOK
		res.Message = "Enough Stock"
		res.Data = true
	}

	return res, nil
}

func GetTransferNoteByID(id_tn string) (Response, error) {
	var res Response
	var tranote TransferNotes

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transfer_note_id, sw_from, sw_to, created_at, status_verify, status_send, user_id_from FROM transfer_notes WHERE transfer_note_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_tn)
	err = stmt.QueryRow(swid).Scan(&tranote.TransferNoteID, &tranote.StoreWarehouseFrom, &tranote.StoreWarehouseTo, &tranote.CreatedAt, &tranote.StatusVerify, &tranote.StatusSend, &tranote.UserIDFrom)
	if err != nil {
		if err == sql.ErrNoRows {
			tranote = TransferNotes{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = tranote
			return res, nil
		}
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func GetLastTransferNote() (Response, error) {
	var res Response
	var tranote TransferNotes

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transfer_note_id, sw_from, sw_to, created_at, status_verify, status_send, user_id_from FROM transfer_notes ORDER BY transfer_note_id DESC LIMIT 1"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow().Scan(&tranote.TransferNoteID, &tranote.StoreWarehouseFrom, &tranote.StoreWarehouseTo, &tranote.CreatedAt, &tranote.StatusVerify, &tranote.StatusSend, &tranote.UserIDFrom)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func GetAllTransferNotes() (Response, error) {
	var res Response
	var tranote TransferNotes
	var arrTN = []TransferNotes{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transfer_note_id, sw_from, sw_to, created_at, status_verify, status_send, user_id_from FROM transfer_notes"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&tranote.TransferNoteID, &tranote.StoreWarehouseFrom, &tranote.StoreWarehouseTo, &tranote.CreatedAt, &tranote.StatusVerify, &tranote.StatusSend, &tranote.UserIDFrom)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTN = append(arrTN, tranote)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTN
	return res, nil
}

func GetTransferNoteDetailByTNID(id_tn string) (Response, error) {
	var res Response
	var tranote TransferNoteDetails
	var arrTN = []TransferNoteDetails{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetTransferNoteByID(id_tn)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_tn)
	}

	query := "SELECT tn.transfer_note_detail_id, tn.transfer_note_id, tn.product_detail_id, pd.product_name, tn.batch, tn.expired_date, tn.quantity FROM transfer_notes_details tn JOIN product_details pd ON tn.product_detail_id = pd.product_detail_id WHERE transfer_note_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_tn)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&tranote.TransferNoteDetailID, &tranote.TransferNoteID, &tranote.ProductDetailID, &tranote.ProductName, &tranote.Batch, &tranote.ExpiredDate, &tranote.Quantity)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTN = append(arrTN, tranote)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTN
	return res, nil
}

func CreateTransferNotes(id_user, id_role string) (Response, error) {
	var res Response
	var tranote TransferNotes

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "INSERT INTO transfer_notes(created_at, status_verify, status_send, sw_from) VALUES(NOW(), 0, 0, ?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(userData.StoreWarehouseID)
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
	tranote.TransferNoteID = int(lastId)
	tranote.StoreWarehouseFrom = userData.StoreWarehouseID

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func InsertTransferNoteDetails(transfernotes, id_user, id_role string) (Response, error) {
	var res Response
	var arrTN = []TransferNoteDetails{}

	err := json.Unmarshal([]byte(transfernotes), &arrTN)
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

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if userData.UserId == 0 {
		res.Status = 500
		res.Message = "User not exist"
		return res, fmt.Errorf("user ID %s role ID %s not exist", id_user, id_role)
	}

	for _, x := range arrTN {
		pid := strconv.Itoa(x.ProductDetailID)
		wid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ := GetTotalStockByEXPPIDSWID(pid, wid, x.ExpiredDate)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			fmt.Println("HHAsss")
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format: got %T", check.Data)
		}

		if x.Quantity > stockData.ProductStock {
			res.Status = 500
			res.Message = "Not Enough Stock"
			return res, fmt.Errorf("not enough stock %s: %f", pid, stockData.ProductStock)
		}
	}

	check, _ = CreateTransferNotes(id_user, id_role)
	TraNoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format: got %T", check.Data)
	}

	query := "INSERT INTO transfer_notes_details(transfer_note_id, product_detail_id, batch, quantity, expired_date) VALUES(?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrTN {
		result, err := stmt.Exec(TraNoteData.TransferNoteID, x.ProductDetailID, x.Batch, x.Quantity, x.ExpiredDate)
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
		arrTN[i].TransferNoteDetailID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTN
	return res, nil
}

func InsertTransferNotes(id_transfernote, transfernote string) (Response, error) {
	var res Response
	var tranote TransferNotes

	err := json.Unmarshal([]byte(transfernote), &tranote)
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

	Id, _ := strconv.Atoi(id_transfernote)

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_transfernote)
	}

	query := "UPDATE transfer_notes SET sw_to = ?, created_at = NOW(), user_id_from = ? WHERE transfer_note_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(tranote.StoreWarehouseTo, tranote.UserIDFrom, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func InsertProductToTransferNoteDetails(transfernotes, id_transfernote string) (Response, error) {
	var res Response
	var arrTN = []TransferNoteDetails{}

	err := json.Unmarshal([]byte(transfernotes), &arrTN)
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

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_transfernote)
	}
	
	for _, x := range arrTN {
		pid := strconv.Itoa(x.ProductDetailID)
		wid := strconv.Itoa(tranoteData.StoreWarehouseFrom)
		check, _ := GetTotalStockByEXPPIDSWID(pid, wid, x.ExpiredDate)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format: got %T", check.Data)
		}

		if x.Quantity > stockData.ProductStock {
			res.Status = 500
			res.Message = "Not Enough Stock"
			return res, fmt.Errorf("not enough stock %s: %f", pid, stockData.ProductStock)
		}
	}

	query := "INSERT INTO transfer_notes_details(transfer_note_id, product_detail_id, batch, quantity, expired_date) VALUES(?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrTN {
		result, err := stmt.Exec(tranoteData.TransferNoteID, x.ProductDetailID, x.Batch, x.Quantity, x.ExpiredDate)
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
		arrTN[i].TransferNoteDetailID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTN
	return res, nil
}

func UpdateProductQtyTransferNote(id_transfernote, id_product, quantity string) (Response, error) {
	var res Response
	var tranote TransferNotes

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	tid, _ := strconv.Atoi(id_transfernote)
	pid, _ := strconv.Atoi(id_product)
	qty, _ := strconv.Atoi(quantity)

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_transfernote)
	}

	query := "UPDATE transfer_notes_details SET quantity = ? WHERE transfer_note_id = ? AND product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(qty, tid, pid)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func DelProductFromTransferNote(id_transfernote, id_product string)(Response, error) {
	var res Response

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	
	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_transfernote)
	}

	query := "DELETE FROM transfer_notes_details WHERE transfer_note_id = ? AND product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	tid, _ := strconv.Atoi(id_transfernote)
	pid, _ := strconv.Atoi(id_product)
	_, err = stmt.Exec(tid, pid)
	if err != nil {
		res.Status = 401
		res.Message = "failed"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = "Berhasil"
	return res, nil
}

func VerifyTransferNotes(id_transfernote string) (Response, error) {
	var res Response
	var tranote TransferNotes

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	Id, _ := strconv.Atoi(id_transfernote)

	check, _ := GetTransferNoteByID(id_transfernote)
	DoData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "UPDATE transfer_notes SET status_verify = 1 WHERE transfer_note_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	check, _ = GetTransferNoteDetailByTNID(id_transfernote)
	DodData, ok := check.Data.([]TransferNoteDetails)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	dataSlice := make([]map[string]interface{}, len(DodData))

	for i, item := range DodData {
		dataSlice[i] = map[string]interface{}{
			"product_detail_id":  item.ProductDetailID,      
			"stock_description":  "Moving",
			"expired_date":		item.ExpiredDate, 
			"product_batch": 	item.Batch,            
			"stock_out":          item.Quantity,            
			"store_warehouse_id": DoData.StoreWarehouseFrom,
		}
	}

	data, err := json.Marshal(dataSlice)
	if err != nil {
		res.Status = 401
		res.Message = "json stock card error"
		res.Data = err.Error()
		return res, err
	}

	_, err = InsertStockCards(string(data))
	if err != nil {
		res.Status = 401
		res.Message = "Insert stock card error"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func GetNotVerifiedTransferNote() (Response, error) {
	var res Response
	var tranote TransferNotes
	var arrTN = []TransferNotes{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transfer_note_id, sw_from, sw_to, created_at, status_verify, status_send, user_id_from FROM transfer_notes WHERE status_verify = 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&tranote.TransferNoteID, &tranote.StoreWarehouseFrom, &tranote.StoreWarehouseTo, &tranote.CreatedAt, &tranote.StatusVerify, &tranote.StatusSend, &tranote.UserIDFrom)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrTN = append(arrTN, tranote)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrTN
	return res, nil
}

func GetDeliveryOrderByID(id_do string) (Response, error) {
	var res Response
	var delo DeliveryOrders

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders WHERE delivery_order_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_do)
	err = stmt.QueryRow(swid).Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = delo
	return res, nil
}

func GetDeliveryOrderBySWFromID(id_sw string) (Response, error) {
	var res Response
	var delo DeliveryOrders
	var arrDel = []DeliveryOrders{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders WHERE sw_from = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetDOFromSWIDToSWID(id_sw_from, id_sw_to string) (Response, error) {
	var res Response
	var delo DeliveryOrders
	var arrDel = []DeliveryOrders{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders WHERE sw_from = ? AND sw_to = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swidfr, _ := strconv.Atoi(id_sw_from)
	swidto, _ := strconv.Atoi(id_sw_to)
	rows, err := stmt.Query(swidfr, swidto)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetDeliveryOrderDetailByDOID(id_do string) (Response, error) {
	var res Response
	var delo DeliveryOrderDetails
	var arrDel = []DeliveryOrderDetails{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_detail_id, delivery_order_id, product_detail_id, product_name, quantity, expired_date, batch FROM delivery_order_details WHERE delivery_order_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_do)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.DeliveryOrderDetailID, &delo.DeliveryOrderID, &delo.ProductDetailID, &delo.ProductName, &delo.Quantity, &delo.ExpiredDate, &delo.Batch)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetLastDeliveryOrder() (Response, error) {
	var res Response
	var delo DeliveryOrders

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders ORDER BY delivery_order_id DESC LIMIT 1"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	err = stmt.QueryRow().Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = delo
	return res, nil
}

func GetDeliveryOrderByTNID(id_tn string) (Response, error) {
	var res Response
	var delo DeliveryOrders
	var arrDel = []DeliveryOrders{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetTransferNoteByID(id_tn)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if tranoteData.TransferNoteID == 0 {
		res.Status = 500
		res.Message = "Transfer Note not exist"
		return res, fmt.Errorf("transfer note ID %s not exist", id_tn)
	}

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders WHERE transfer_note_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_tn)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func CreateDeliveryOrders(id_transfernote string) (Response, error) {
	var res Response
	var delo DeliveryOrders

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "INSERT INTO delivery_orders(order_timestamp, status_accept, sw_from, sw_to, transfer_note_id) VALUES(NOW(), 0, ?, ?, ?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(tranoteData.StoreWarehouseFrom, tranoteData.StoreWarehouseTo, tranoteData.TransferNoteID)
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
	delo.DeliveryOrderID = int(lastId)
	delo.StoreWarehouseFrom = tranoteData.StoreWarehouseFrom
	delo.StoreWarehouseTo = tranoteData.StoreWarehouseTo

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = delo
	return res, nil
}

func InsertDeliveryOrderDetails(deliveryorder, id_transfernote string) (Response, error) {
	var res Response
	var arrDel = []DeliveryOrderDetails{}

	err := json.Unmarshal([]byte(deliveryorder), &arrDel)
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

	check, _ := GetTransferNoteByID(id_transfernote)
	tranoteData, ok := check.Data.(TransferNotes)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	for _, x := range arrDel {
		pid := strconv.Itoa(x.ProductDetailID)
		wid := strconv.Itoa(tranoteData.StoreWarehouseFrom)
		check, _ := GetTotalStockByEXPPIDSWID(pid, wid, x.ExpiredDate)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format: got %T", check.Data)
		}

		if x.Quantity > stockData.ProductStock {
			res.Status = 500
			res.Message = "Not Enough Stock"
			return res, fmt.Errorf("not enough stock %s: %f", pid, stockData.ProductStock)
		}
	}

	check, _ = CreateDeliveryOrders(id_transfernote)
	DelOrderData, ok := check.Data.(DeliveryOrders)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format: got %T", check.Data)
	}

	query := "INSERT INTO delivery_order_details(delivery_order_id, product_detail_id, product_name, quantity, expired_date, batch) VALUES(?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrDel {
		pid := strconv.Itoa(x.ProductDetailID)
		check, _ = GetProductByID(pid, "", "")
		productData, ok := check.Data.(ProductDetails)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		
		// sw_from := strconv.Itoa(DelOrderData.StoreWarehouseFrom)

		// check, _ = GetEarliestEXPByProductID(pid, sw_from)
		// expData, ok := check.Data.(StockCards)
		// if !ok {
		// 	res.Status = 500
		// 	res.Message = "Unexpected data format"
		// 	return res, fmt.Errorf("unexpected data format")
		// }

		result, err := stmt.Exec(DelOrderData.DeliveryOrderID, x.ProductDetailID, productData.ProductName, x.Quantity, x.ExpiredDate, x.Batch)
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
		arrDel[i].DeliveryOrderDetailID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func InsertDeliveryOrders(id_deliveryorder, deliveryorder string) (Response, error) {
	var res Response
	var delo DeliveryOrders

	err := json.Unmarshal([]byte(deliveryorder), &delo)
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

	Id, _ := strconv.Atoi(id_deliveryorder)

	query := "UPDATE delivery_orders SET order_timestamp = NOW(), user_id_from = ? WHERE delivery_order_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(delo.UserIDFrom, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = delo
	return res, nil
}

func GetStockLeftInTransferNotes(id_product, id_transfernote string) (Response, error) {
	var res Response
	var tranote TransferNoteDetails
	var temp  float64

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT SUM(dod.quantity) FROM delivery_orders do JOIN delivery_order_details dod ON do.delivery_order_id = dod.delivery_order_id WHERE do.transfer_note_id = ? AND dod.product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	pid, _ := strconv.Atoi(id_product)
	swid, _ := strconv.Atoi(id_transfernote)
	err = stmt.QueryRow(swid, pid).Scan(&temp)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	query = "SELECT quantity FROM transfer_notes_details WHERE product_detail_id = ?"
	stmt, err = con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	} 
	defer stmt.Close()

	err = stmt.QueryRow(pid).Scan(&tranote.Quantity)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	tranote.Quantity = tranote.Quantity - temp

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = tranote
	return res, nil
}

func AcceptDeliveryOrders(id_deliveryorder, id_user_to string) (Response, error) {
	var res Response
	var delo DeliveryOrders

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	Id, _ := strconv.Atoi(id_deliveryorder)
	uid, _ := strconv.Atoi(id_user_to)

	check, _ := GetDeliveryOrderByID(id_deliveryorder)
	DoData, ok := check.Data.(DeliveryOrders)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "UPDATE delivery_orders SET status_accept = 1, user_id_to = ? WHERE delivery_order_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(uid, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	check, _ = GetDeliveryOrderDetailByDOID(id_deliveryorder)
	DodData, _ := check.Data.([]DeliveryOrderDetails)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	dataSlice := make([]map[string]interface{}, len(DodData))

	for i, item := range DodData {
		dataSlice[i] = map[string]interface{}{
			"product_detail_id":  item.ProductDetailID,      
			"stock_description":  "Moving",  
			"expired_date":		item.ExpiredDate,
			"product_batch":	item.Batch,             
			"stock_in":          item.Quantity,            
			"store_warehouse_id": DoData.StoreWarehouseTo,
		}
	}

	data, err := json.Marshal(dataSlice)
	if err != nil {
		res.Status = 401
		res.Message = "json stock card error"
		res.Data = err.Error()
		return res, err
	}

	_, err = InsertStockCards(string(data))
	if err != nil {
		res.Status = 401
		res.Message = "Insert stock card error"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = delo
	return res, nil
}

func GetNotAcceptedDeliveryOrder() (Response, error) {
	var res Response
	var delo DeliveryOrders
	var arrDel = []DeliveryOrders{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT delivery_order_id, sw_from, sw_to, order_timestamp, status_accept, accept_timestamp, user_id_from, user_id_to, transfer_note_id FROM delivery_orders WHERE status_accept = 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&delo.DeliveryOrderID, &delo.StoreWarehouseFrom, &delo.StoreWarehouseTo, &delo.OrderTimestamp, &delo.StatusAccept, &delo.AcceptTimestamp, &delo.UserIDFrom, &delo.UserIDTo, &delo.TransferNoteID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrDel = append(arrDel, delo)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrDel
	return res, nil
}

func GetAllAddStock() (Response, error) {
	var res Response
	var adds AddStockWH
	var arrAdds = []AddStockWH{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT add_stock_wh_id, delivery_order_supplier_id, supplier_id, timestamp, status_verify, user_id, store_warehouse_id  FROM add_stock_wh GROUP BY add_stock_wh_id ASC"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&adds.AddStockWHID, &adds.DeliveryOrderSupplier, &adds.SupplierID, &adds.Timestamp, &adds.StatusVerify, &adds.UserID, &adds.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrAdds = append(arrAdds, adds)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrAdds
	return res, nil
}

func GetAddStockByID(id_as string) (Response, error) {
	var res Response
	var adds AddStockWH

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT add_stock_wh_id, delivery_order_supplier_id, supplier_id, timestamp, status_verify, user_id, store_warehouse_id  FROM add_stock_wh WHERE add_stock_wh_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_as)
	err = stmt.QueryRow(swid).Scan(&adds.AddStockWHID, &adds.DeliveryOrderSupplier, &adds.SupplierID, &adds.Timestamp, &adds.StatusVerify, &adds.UserID, &adds.StoreWarehouseID)
	if err != nil {
		if err == sql.ErrNoRows {
			adds = AddStockWH{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = adds
			return res, nil
		}
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = adds
	return res, nil
}

func GetAddStockDetailByASID(id_as string) (Response, error) {
	var res Response
	var adds AddStockWHDetails
	var arrAdds = []AddStockWHDetails{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetAddStockByID(id_as)
	AddSData, ok := check.Data.(AddStockWH)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if AddSData.AddStockWHID == 0 {
		res.Status = 500
		res.Message = "Add Stock not exist"
		return res, fmt.Errorf("add stock ID %s not exist", id_as)
	}

	query := "SELECT add_stock_wh_detail_id, add_stock_wh_id, product_detail_id, batch, expired_date, quantity, section_placement FROM add_stock_wh_detail WHERE add_stock_wh_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_as)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&adds.AddStockWHDetailID, &adds.ProductDetailID, &adds.ProductDetailID, &adds.Batch, &adds.ExpiredDate, &adds.AddQty, &adds.SectionPlacement)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrAdds = append(arrAdds, adds)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrAdds
	return res, nil
}

func CreateAddStock(id_user, id_role string) (Response, error) {
	var res Response
	var adds AddStockWH

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "INSERT INTO add_stock_wh(status_verify, user_id, store_warehouse_id) VALUES(0, ?, ?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(userData.UserId, userData.StoreWarehouseID)
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
	adds.AddStockWHID = int(lastId)
	adds.StoreWarehouseID = userData.StoreWarehouseID

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = adds
	return res, nil
}

func InsertAddStockDetails(addstock, id_user, id_role string) (Response, error) {
	var res Response
	var arrAdd = []AddStockWHDetails{}

	err := json.Unmarshal([]byte(addstock), &arrAdd)
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

	check, _ := CreateAddStock(id_user, id_role)
	AddSData, ok := check.Data.(AddStockWH)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format: got %T", check.Data)
	}

	query := "INSERT INTO add_stock_wh_detail(add_stock_wh_id, product_detail_id, batch, quantity, expired_date, section_placement) VALUES(?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrAdd {
		result, err := stmt.Exec(AddSData.AddStockWHID, x.ProductDetailID, x.Batch, x.AddQty, x.ExpiredDate, x.SectionPlacement)
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
		arrAdd[i].AddStockWHDetailID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrAdd
	return res, nil
}

func InsertAddStock(id_addstock, addstock string) (Response, error) {
	var res Response
	var adds AddStockWH

	err := json.Unmarshal([]byte(addstock), &adds)
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

	sid := strconv.Itoa(adds.SupplierID)
	check, _ := GetSupplierByID(sid)
	suppData, ok := check.Data.(Suppliers)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if suppData.SupplierId == 0 {
		res.Status = 500
		res.Message = "Supplier not exist"
		return res, fmt.Errorf("supplier ID %s not exist", sid)
	}

	Id, _ := strconv.Atoi(id_addstock)

	query := "UPDATE add_stock_wh SET timestamp = NOW(), delivery_order_supplier_id = ?, supplier_id = ? WHERE add_stock_wh_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(adds.DeliveryOrderSupplier, adds.SupplierID, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = adds
	return res, nil
}

func GetNotVerifiedAddStock() (Response, error) {
	var res Response
	var adds AddStockWH
	var arrAdds = []AddStockWH{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT add_stock_wh_id, delivery_order_supplier_id, supplier_id, timestamp, status_verify, user_id, store_warehouse_id  FROM add_stock_wh WHERE status_verify = 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&adds.AddStockWHID, &adds.DeliveryOrderSupplier, &adds.SupplierID, &adds.Timestamp, &adds.StatusVerify, &adds.UserID, &adds.StoreWarehouseID)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrAdds = append(arrAdds, adds)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrAdds
	return res, nil
}

func VerifyAddStock(id_addstock string) (Response, error) {
	var res Response
	var adds AddStockWH

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	Id, _ := strconv.Atoi(id_addstock)

	check, _ := GetAddStockByID(id_addstock)
	addsData, ok := check.Data.(AddStockWH)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	if addsData.AddStockWHID == 0 {
		res.Status = 500
		res.Message = "Add Stock not Exist"
		return res, fmt.Errorf("add stock ID %s not exist", id_addstock)
	}

	query := "UPDATE add_stock_wh SET status_verify = 1 WHERE add_stock_wh_id  = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}
	check, _ = GetAddStockDetailByASID(id_addstock)
	DodData, _ := check.Data.([]AddStockWHDetails)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	dataSlice := make([]map[string]interface{}, len(DodData))

	for i, item := range DodData {
		dataSlice[i] = map[string]interface{}{
			"product_detail_id":  item.ProductDetailID,      
			"stock_description":  "Stock In",  
			"expired_date":		item.ExpiredDate,
			"product_batch":	item.Batch,             
			"stock_in":          item.AddQty,            
			"store_warehouse_id": addsData.StoreWarehouseID,
		}
	}

	data, err := json.Marshal(dataSlice)
	if err != nil {
		res.Status = 401
		res.Message = "json stock card error"
		res.Data = err.Error()
		return res, err
	}

	_, err = InsertStockCards(string(data))
	if err != nil {
		res.Status = 401
		res.Message = "Insert stock card error"
		res.Data = err.Error()
		return res, err
	}

	for _, item := range DodData {
		fmt.Println(item.SectionPlacement)
		swid := strconv.Itoa(addsData.StoreWarehouseID)
		_,_ = InsertSWProducts(swid, item.ProductDetailID, item.SectionPlacement)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = adds
	return res, nil
}

func GetAllSubtractStock() (Response, error) {
	var res Response
	var sub SubtractStock
	var arrSub = []SubtractStock{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT subtract_stock_id, product_detail_id, batch, subtract_quantity, expired_date, status_verify, notes, user_id, store_warehouse_id, timestamp FROM subtract_stock"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sub.SubtractStockID, &sub.ProductDetailID, &sub.Batch, &sub.SubtractQty, &sub.ExpiredDate, &sub.StatusVerify, &sub.Notes, &sub.UserID, &sub.StoreWarehouseID, &sub.Timestamp)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSub = append(arrSub, sub)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSub
	return res, nil
}

func GetSubtractStockByID(id_as string) (Response, error) {
	var res Response
	var sub SubtractStock

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT subtract_stock_id, product_detail_id, batch, subtract_quantity, expired_date, status_verify, notes, user_id, store_warehouse_id, timestamp FROM subtract_stock WHERE subtract_stock_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_as)
	err = stmt.QueryRow(swid).Scan(&sub.SubtractStockID, &sub.ProductDetailID, &sub.Batch, &sub.SubtractQty, &sub.ExpiredDate, &sub.StatusVerify, &sub.Notes, &sub.UserID, &sub.StoreWarehouseID, &sub.Timestamp)
	if err != nil {
		if err == sql.ErrNoRows {
			sub = SubtractStock{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = sub
			return res, nil
		}
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sub
	return res, nil
}

func GetSubtractStockBySWID(id_sw string) (Response, error) {
	var res Response
	var sub SubtractStock
	var arrSub = []SubtractStock{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	check, _ := GetStoreWarehouseByID(id_sw)
	swData, ok := check.Data.(StoreWarehouses)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	if swData.StoreWarehouseId == 0 {
		res.Status = 500
		res.Message = "Store/Warehouse not exist"
		return res, fmt.Errorf("store/warehouse ID %s not exist", id_sw)
	}

	query := "SELECT subtract_stock_id, product_detail_id, batch, subtract_quantity, expired_date, status_verify, notes, user_id, store_warehouse_id, timestamp FROM subtract_stock WHERE store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	swid, _ := strconv.Atoi(id_sw)
	rows, err := stmt.Query(swid)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sub.SubtractStockID, &sub.ProductDetailID, &sub.Batch, &sub.SubtractQty, &sub.ExpiredDate, &sub.StatusVerify, &sub.Notes, &sub.UserID, &sub.StoreWarehouseID, &sub.Timestamp)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSub = append(arrSub, sub)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSub
	return res, nil
}

func InsertSubtractStock(subtract, id_user, id_role string) (Response, error) {
	var res Response
	var arrSub = []SubtractStock{}

	err := json.Unmarshal([]byte(subtract), &arrSub)
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

	check, _ := GetDataUser(id_user, id_role)
	userData, ok := check.Data.(UserData)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	for _, x := range arrSub {
		pid := strconv.Itoa(x.ProductDetailID)
		sid := strconv.Itoa(userData.StoreWarehouseID)
		check, _ := GetTotalStockByProductIDSWID(pid, sid)
		stockData, ok := check.Data.(StockCards)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format: got %T", check.Data)
		}

		if x.SubtractQty > stockData.ProductStock {
			res.Status = 500
			res.Message = "Not Enough Stock"
			return res, fmt.Errorf("not enough stock for ID product %d: %f", x.ProductDetailID, stockData.ProductStock)
		}
	}

	query := "INSERT INTO subtract_stock(product_detail_id, batch, subtract_quantity, expired_date, status_verify, notes, user_id, store_warehouse_id, timestamp) VALUES(?,?,?,?,0,?,?,?,NOW())"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	uid, _ := strconv.Atoi(id_user)
	for i, x := range arrSub {
		result, err := stmt.Exec(x.ProductDetailID, x.Batch, x.SubtractQty, x.ExpiredDate, x.Notes, uid, userData.StoreWarehouseID)
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
		arrSub[i].SubtractStockID = int(lastId)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSub
	return res, nil
}

func GetNotVerifiedSubtractStock() (Response, error) {
	var res Response
	var sub SubtractStock
	var arrSub = []SubtractStock{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT subtract_stock_id, product_detail_id, batch, subtract_quantity, expired_date, status_verify, notes, user_id, store_warehouse_id, timestamp FROM subtract_stock WHERE status_verify = 0"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&sub.SubtractStockID, &sub.ProductDetailID, &sub.Batch, &sub.SubtractQty, &sub.ExpiredDate, &sub.StatusVerify, &sub.Notes, &sub.UserID, &sub.StoreWarehouseID, &sub.Timestamp)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrSub = append(arrSub, sub)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSub
	return res, nil
}

func VerifySubtractStock(id_subtract string) (Response, error) {
	var res Response
	var sub SubtractStock

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	Id, _ := strconv.Atoi(id_subtract)

	check, _ := GetSubtractStockByID(id_subtract)
	subData, ok := check.Data.(SubtractStock)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}
	if subData.SubtractStockID == 0 {
		res.Status = 500
		res.Message = "Subtract Stock not Exist"
		return res, fmt.Errorf("subtract stock ID %s not exist", id_subtract)
	}

	query := "UPDATE subtract_stock SET status_verify = 1 WHERE subtract_stock_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	_, err = stmt.Exec(Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	data, err := json.Marshal([]map[string]interface{}{{
		"product_detail_id":  subData.ProductDetailID,      
		"stock_description":  "Stock Out",  
		"expired_date":		subData.ExpiredDate,
		"product_batch":	subData.Batch,             
		"stock_out":          subData.SubtractQty,            
		"store_warehouse_id": subData.StoreWarehouseID,
	}})
	if err != nil {
		res.Status = 401
		res.Message = "json stock card error"
		res.Data = err.Error()
		return res, err
	}
	_, _ = InsertStockCards(string(data))

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sub
	return res, nil
}

func GetStoreWarehouseByUIDRID(id_user, id_role string) (Response, error) {
	var res Response
	var wrh StoreWarehouses

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT sw.store_warehouse_id, sw.store_warehouse_type, sw.store_warehouse_name, sw.store_warehouse_address, sw.store_warehouse_phone_number FROM store_warehouses sw JOIN user_roles ur ON sw.store_warehouse_id = ur.store_warehouse_id WHERE ur.user_id = ? AND ur.roles_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_user)
	rid, _ := strconv.Atoi(id_role)
	err = stmt.QueryRow(Id, rid).Scan(&wrh.StoreWarehouseId, &wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
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

func GetStoreWarehouseByID(id_warehouse string) (Response, error) {
	var res Response
	var wrh StoreWarehouses

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT store_warehouse_id, store_warehouse_type, store_warehouse_name, store_warehouse_address, store_warehouse_phone_number FROM store_warehouses WHERE store_warehouse_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_warehouse)
	err = stmt.QueryRow(Id).Scan(&wrh.StoreWarehouseId, &wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
	if err != nil {
		if err == sql.ErrNoRows {
			wrh = StoreWarehouses{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = wrh
			return res, nil
		}
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

func GetStoreWarehouseByName(sw_name string) (Response, error) {
	var res Response
	var wrh StoreWarehouses
	var arrSW = []StoreWarehouses{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT store_warehouse_id, store_warehouse_type, store_warehouse_name, store_warehouse_address, store_warehouse_phone_number FROM store_warehouses WHERE store_warehouse_name LIKE ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	searchName := "%" + sw_name + "%"

	rows, err := stmt.Query(searchName)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&wrh.StoreWarehouseId, &wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}

		arrSW = append(arrSW, wrh)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrSW
	return res, nil
}

func GetAllByStoreWarehouseType(sw_type string) (Response, error) {
	var res Response
	var wrh StoreWarehouses
	var arrWrh = []StoreWarehouses{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT store_warehouse_id, store_warehouse_type, store_warehouse_name, store_warehouse_address, store_warehouse_phone_number FROM store_warehouses WHERE store_warehouse_type = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query(sw_type)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&wrh.StoreWarehouseId, &wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrWrh = append(arrWrh, wrh)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrWrh
	return res, nil
}

func GetAllStoreWarehouse() (Response, error) {
	var res Response
	var wrh StoreWarehouses
	var arrWrh = []StoreWarehouses{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT store_warehouse_id, store_warehouse_type, store_warehouse_name, store_warehouse_address, store_warehouse_phone_number FROM store_warehouses"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&wrh.StoreWarehouseId, &wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrWrh = append(arrWrh, wrh)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrWrh
	return res, nil
}

func InsertStoreWarehouse(warehouse string) (Response, error) {
	var res Response
	var wrh StoreWarehouses

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

	query := "INSERT INTO store_warehouses(store_warehouse_type, store_warehouse_name, store_warehouse_address, store_warehouse_phone_number) VALUES (?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(&wrh.StoreWarehouseType, &wrh.StoreWarehouseName, &wrh.StoreWarehouseAddress, &wrh.StoreWarehousePhoneNumber)
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

	wrh.StoreWarehouseId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = wrh
	return res, nil
}

func GetNotificationByRoleId(id_role string) (Response, error) {
	var res Response
	var not NotifUser
	var arrNot = []NotifUser{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT n.notification_id, n.user_id, u.user_fullname, n.roles_id, r.roles_name, n.timestamp, n.description, n.notif_type_id, nt.notification_name FROM notifications n JOIN notification_type nt ON n.notif_type_id = nt.notification_type_id JOIN users u ON n.user_id = u.user_id JOIN roles r ON r.roles_id = n.roles_id WHERE n.roles_id = ? ORDER BY n.timestamp DESC"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_role)
	rows, err := stmt.Query(Id)
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&not.Notifications.NotificationID, &not.Notifications.UserID, &not.UserData.UserFullName, &not.Notifications.RolesID, &not.UserData.RoleName, &not.Notifications.Timestamp, &not.Notifications.Description, &not.Notifications.NotificationTypeID, &not.Notifications.NotificationTypeName)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrNot = append(arrNot, not)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrNot
	return res, nil
}

func GetAllNotification() (Response, error) {
	var res Response
	var not NotifUser
	var arrNot = []NotifUser{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT n.notification_id, n.user_id, u.user_fullname, n.roles_id, r.roles_name, n.timestamp, n.description, n.notif_type_id, nt.notification_name FROM notifications n JOIN notification_type nt ON n.notif_type_id = nt.notification_type_id JOIN users u ON n.user_id = u.user_id JOIN roles r ON r.roles_id = n.roles_id ORDER BY n.timestamp DESC;"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()
	rows, err := stmt.Query()
	if err != nil {
		res.Status = 401
		res.Message = "rows gagal"
		res.Data = err.Error()
		return res, err
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&not.Notifications.NotificationID, &not.Notifications.UserID, &not.UserData.UserFullName, &not.Notifications.RolesID, &not.UserData.RoleName, &not.Notifications.Timestamp, &not.Notifications.Description, &not.Notifications.NotificationTypeID, &not.Notifications.NotificationTypeName)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}

		uid := strconv.Itoa(not.Notifications.UserID)
		rid := strconv.Itoa(not.Notifications.RolesID)
		check, _ := GetDataUser(uid, rid)
		userData, ok := check.Data.(UserData)
		if !ok {
			res.Status = 500
			res.Message = "Unexpected data format"
			return res, fmt.Errorf("unexpected data format")
		}
		not.UserData.RoleName = userData.RoleName
		not.UserData.StoreWarehouseID = userData.StoreWarehouseID
		arrNot = append(arrNot, not)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrNot
	return res, nil
}

func InsertNotification(notification string) (Response, error) {
	var res Response
	var not Notifications

	err := json.Unmarshal([]byte(notification), &not)
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

	query := "INSERT INTO notifications(user_id, roles_id, timestamp, description, notif_type_id) VALUES (?,?,NOW(),?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(&not.UserID, &not.RolesID, &not.Description, &not.NotificationTypeID)
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

	not.NotificationID = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = not
	return res, nil
}

func InsertRoles(roles string) (Response, error) {
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

	for _, x := range arrRole {
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

	for i, x := range arrRole {
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

func InsertPrivileges(priv string) (Response, error) {
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

	for _, x := range arrPrv {
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

	for i, x := range arrPrv {
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

func InsertRolesDefault(roled string) (Response, error) {
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

	for _, x := range arrRD {
		subid := strconv.Itoa(x.RolesId)
		check, err := GetRolesByID(subid)
		if err != nil || check.Data == nil {
			res.Status = http.StatusBadRequest
			res.Message = "Roles ID " + subid + " not exist"
			return res, nil
		}

		tchid := strconv.Itoa(x.PrivilegesId)
		check, err = GetPrivilegesByID(tchid)
		if err != nil || check.Data == nil {
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

	for i, x := range arrRD {
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

func GetSupplierByID(id_supplier string) (Response, error) {
	var res Response
	var supp Suppliers

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT supplier_id, supplier_name, supplier_phone_number, supplier_address FROM suppliers WHERE supplier_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_supplier)
	err = stmt.QueryRow(Id).Scan(&supp.SupplierId, &supp.SupplierName, &supp.SupplierPhoneNumber, &supp.SupplierAddress)
	if err != nil {
		if err == sql.ErrNoRows {
			supp = Suppliers{}
			res.Status = http.StatusOK
			res.Message = "Data Not Exist"
			res.Data = supp
			return res, nil
		}
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = supp
	return res, nil
}

func InsertSupplier(supplier string) (Response, error) {
	var res Response
	var sup Suppliers

	err := json.Unmarshal([]byte(supplier), &sup)
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

	query := "INSERT INTO suppliers(supplier_name, supplier_phone_number, supplier_address) VALUES(?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	result, err := stmt.Exec(sup.SupplierName, sup.SupplierPhoneNumber, sup.SupplierAddress)
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
	sup.SupplierId = int(lastId)

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = sup
	return res, nil
}
