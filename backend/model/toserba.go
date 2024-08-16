package model

import (
	"TemplateProject/db"
	"database/sql"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"net/smtp"
	"strconv"
	"time"
)

func GenerateOTP () string {
	// var res Response
    otp := rand.Intn(9000) + 100000

    return strconv.Itoa(otp)
}

func SendEmail (toEmail, otp string) error {
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

func AccountSendOTP (id_user string) (Response, error) {
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

func ResetOTP (id_user int, res Response, con *sql.DB) (Response, error) {
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

func OTPVerification (id_user, vOtp string) (Response, error) {
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

	query := "SELECT s.session_id, s.user_id, u.user_fullname ,s.start_time, s.end_time, s.opening_cash, s.total_income, s.expected_closing_cash, s.actual_closing_cash, s.actual_difference, s.deposit_money, s.deposit_difference, s.opening_notes, s.closing_notes, s.last_update_time FROM sessions s JOIN users u ON s.user_id = u.user_id"
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
		fmt.Println(sessionData.DepositDifference, sess.OpeningCash)
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

	query := "UPDATE sessions SET end_time = ?, expected_closing_cash = ?, actual_closing_cash = ?, actual_difference = ?, deposit_money = ?, deposit_difference =?, closing_notes = ? WHERE session_id = ?"
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
	_, err = stmt.Exec(endTime, &sess.ExpectedClosingCash, &sess.ActualClosingCash, &sess.ActualDifference, &sess.DepositMoney, &sess.DepositDifference, &sess.ClosingNotes, Id)
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

	fmt.Println(endTime, updateTime, duration)

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

func GetProductByID(id_product string) (Response, error) {
	var res Response
	var prd ProductDetails

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT product_detail_id, product_code, product_category_id, product_name, supplier_id, product_batch, buy_price, sell_price, expiry_date, min_stock, product_stock, product_unit, product_timestamp FROM product_details WHERE product_detail_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_product)
	err = stmt.QueryRow(Id).Scan(&prd.ProductDetailId, &prd.ProductCode, &prd.ProductCategoryId, &prd.ProductName, &prd.SupplierId, &prd.ProductBatch, &prd.BuyPrice, &prd.SellPrice, &prd.ExpiryDate, &prd.MinStock, &prd.ProductStock, &prd.ProductUnit, &prd.ProductTimeStamp)
	if err != nil {
		res.Status = 401
		res.Message = "Data Not Exist"
		res.Data = err.Error()
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = prd
	return res, nil
}

func GetAllProducts() (Response, error) {
	var res Response
	var prd ProductDetails
	var arrPrd = []ProductDetails{}

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT product_detail_id, product_code, product_category_id, product_name, supplier_id, product_batch, buy_price, sell_price, expiry_date, min_stock, product_stock, product_unit, product_timestamp FROM product_details"
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
		err = rows.Scan(&prd.ProductDetailId, &prd.ProductCode, &prd.ProductCategoryId, &prd.ProductName, &prd.SupplierId, &prd.ProductBatch, &prd.BuyPrice, &prd.SellPrice, &prd.ExpiryDate, &prd.MinStock, &prd.ProductStock, &prd.ProductUnit, &prd.ProductTimeStamp)
		if err != nil {
			res.Status = 401
			res.Message = "rows scan"
			res.Data = err.Error()
			return res, err
		}
		arrPrd = append(arrPrd, prd)
	}
	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPrd
	return res, nil
}

func InsertProductDetails(product string) (Response, error) {
	var res Response
	var code string
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

	query := "INSERT INTO product_details(product_code, product_category_id, product_name, supplier_id, product_batch, buy_price, sell_price, expiry_date, min_stock, product_stock, product_unit, product_timestamp) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrPro {
		timeStamp, _ := time.Parse("2006-01-02 15:04:05", x.ProductTimeStamp)
		result, err := stmt.Exec(x.ProductCode, x.ProductCategoryId, x.ProductName, x.SupplierId, x.ProductBatch, x.BuyPrice, x.SellPrice, x.ExpiryDate, x.MinStock, x.ProductStock, x.ProductUnit, timeStamp)
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
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = arrPro
	return res, nil
}

func GetTotalOfTransaction(id_transaction int, con *sql.DB) (Response, error) {
	var res Response
	var trd Transaction

	query := "SELECT SUM(total_price), SUM(quantity) FROM transaction_details WHERE transaction_id = ?"
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
	var trs Transaction

	con, err := db.DbConnection()
	if err != nil {
		res.Status = 401
		res.Message = "gagal membuka koneksi database"
		res.Data = err.Error()
		return res, err
	}
	defer db.DbClose(con)

	query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions WHERE transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	Id, _ := strconv.Atoi(id_transaction)
	err = stmt.QueryRow(Id).Scan(&trs.TransactionId, &trs.TransactionTotalPrice, &trs.TransactionTimeStamp, &trs.PaymentMethodId, &trs.TransactionPayment, &trs.TransactionChange, &trs.TotalItem)
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

	query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions ORDER BY transaction_id DESC LIMIT 1"
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

	query := "SELECT transaction_id, transaction_total_price, transaction_timestamp, transaction_payment_method_id, transaction_payment, transaction_change, transaction_total_item FROM transactions"
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
		err = rows.Scan(&trs.TransactionId, &trs.TransactionTotalPrice, &trs.TransactionTimeStamp, &trs.PaymentMethodId, &trs.TransactionPayment, &trs.TransactionChange, &trs.TotalItem)
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

func InsertTransactionDetails(transaction string) (Response, error) {
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

	check, _ := CreateTransaction()

	transactionData, ok := check.Data.(Transaction)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format: got %T", check.Data)
	}

	query := "INSERT INTO transaction_details(transaction_id, product_detail_id, promo_product_id, quantity, sell_price, discount_price, total_price) VALUES(?,?,?,?,?,?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	for i, x := range arrTrd{
		fmt.Println(transactionData.TransactionId)
		result, err := stmt.Exec(transactionData.TransactionId, x.ProductDetailId, x.PromoProductId, x.Quantity, x.SellPrice, x.DiscountPrice, x.TotalPrice)
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

func UpdateTransaction(id_transaction, id_session, id_member, transaction string) (Response, error) {
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
	
	Id, _ := strconv.Atoi(id_transaction)

	check, _ := GetTotalOfTransaction(Id, con)

	sessionData, ok := check.Data.(Transaction)
	if !ok {
		res.Status = 500
		res.Message = "Unexpected data format"
		return res, fmt.Errorf("unexpected data format")
	}

	query := "UPDATE transactions SET transaction_total_price = ?, transaction_timestamp = ?, transaction_payment_method_id = ?, transaction_payment = ?, transaction_change = ?, transaction_total_item = ? WHERE transaction_id = ?"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	timeStamp, _ := time.Parse("2006-01-02 15:04:05", trs.TransactionTimeStamp)
	_, err = stmt.Exec(sessionData.TransactionTotalPrice, timeStamp, trs.PaymentMethodId, trs.TransactionPayment, trs.TransactionChange, sessionData.TotalItem, Id)
	if err != nil {
		res.Status = 401
		res.Message = "exec gagal"
		res.Data = err.Error()
		return res, err
	}

	_, _ = InsertSessionTransaction(trs.TransactionId, id_session)

	mid, _ := strconv.Atoi(id_member)
	if mid != 0 {
		_, _ = InsertMemberTransaction(trs.TransactionId, id_member)
	}

	res.Status = http.StatusOK
	res.Message = "Berhasil"
	res.Data = trs
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

func InsertMemberTransaction(id_transaction int, id_member string) (Response, error) {
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

	query := "INSERT INTO transactions_member(member_id, transaction_id) VALUES(?,?)"
	stmt, err := con.Prepare(query)
	if err != nil {
		res.Status = 401
		res.Message = "stmt gagal"
		res.Data = err.Error()
		return res, err
	}
	defer stmt.Close()

	sId, _ := strconv.Atoi(id_member)
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

func InsertPromoProducts(promo string)(Response, error) {
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

	for _ ,x := range arrPrd {
		pdid := strconv.Itoa(x.ProductDetailId)
		check, err := GetProductByID(pdid)
		if (err != nil || check.Data == nil) {
			res.Status = http.StatusBadRequest
			res.Message = "Product ID " + pdid + " not exist"
			return res, nil
		}

		pid := strconv.Itoa(x.PromoId)
		check, err = GetPromoByID(pid)
		if (err != nil || check.Data == nil) {
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

	for i ,x := range arrPrd {
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

func GetStoreByID(id_store string) (Response, error) {
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
