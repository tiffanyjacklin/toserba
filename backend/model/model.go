package model

import (
	"TemplateProject/db"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"strconv"
	"time"
)

func createFileLog(namFile string) {

	// deteksi apakah file sudah ada
	var _, err = os.Stat(namFile)

	// buat file baru jika belum ada
	if os.IsNotExist(err) {
		file, err := os.Create(namFile)
		if err != nil {
			return
		}
		defer file.Close()
	}

	//fmt.Println("==> file berhasil dibuat", path)
}

func InsertLog(Ip string, namaApi string, lenRes interface{}, lenParam int) error {

	now := time.Now()
	namaFile := now.Format("20060102")
	ts := now.Format("2006-01-02 15:04:05")
	path := "log/aplikasi/" + namaFile + ".txt"
	createFileLog(path)
	jsonData, err := json.Marshal(lenRes)
	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	lenPara := strconv.Itoa(lenParam)
	var lenR string
	var jsonObjs interface{}
	switch v := lenRes.(type) {
	case string:
		fmt.Println("Response:", v)
		lenR = "1"
	default:
		json.Unmarshal(jsonData, &jsonObjs)
		objSlice, ok := jsonObjs.([]interface{})
		if !ok {
			fmt.Println("cannot convert the JSON objects")
			lenR = "1"
			//os.Exit(1)
		} else {
			lenR = strconv.Itoa(len(objSlice))
		}

	}

	format := "{<" + ts + ">;Ip:" + Ip + ";Nama API:" + namaApi + ";lenRespon:" + lenR + ";LenParam:" + lenPara + ";}"
	f, err := os.OpenFile(path,
		os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Println(err)
		return err
	}
	defer f.Close()
	if _, err := f.WriteString(format + "\n"); err != nil {
		log.Println(err)
		return err
	}
	return nil
}

func UploadFotoFolder(file *multipart.FileHeader, id int64, folder string) (Response, error) {
	var res Response
	log.Println("Upload Foto")
	//source
	src, err := file.Open()
	if err != nil {
		log.Println(err.Error())
		return res, err
	}
	defer src.Close()
	nId := strconv.Itoa(int(id))
	// Destination
	dst, err := os.Create("uploads/" + folder + "/" + file.Filename)
	if err != nil {
		return res, err
	}

	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		log.Println(err.Error())
		return res, err
	}
	dst.Close()
	if err = os.Rename("uploads/"+folder+"/"+file.Filename, "uploads/"+folder+"/"+folder+"-"+nId+".png"); err != nil {
		log.Println(err.Error())
		return res, err
	}

	err = UpdateDataFoto(folder, "foto", int(id))
	if err != nil {
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Sukses Upload Foto"
	res.Data = file.Filename

	return res, nil
}

func UploadFile(file *multipart.FileHeader, kolom_name string, kolom_id string, id string, folder string) (Response, error) {
	var res Response
	log.Println("Upload Foto")
	nId, _ := strconv.Atoi(id)
	pathFile := "uploads/" + folder + "/" + file.Filename
	//source
	src, err := file.Open()
	if err != nil {
		log.Println(err.Error())
		return res, err
	}
	defer src.Close()
	// Destination
	dst, err := os.Create(pathFile)
	if err != nil {
		return res, err
	}

	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		log.Println(err.Error())
		return res, err
	}
	dst.Close()

	err = UpdateDataFotoPath(folder, kolom_name ,pathFile, kolom_id, nId)
	if err != nil {
		return res, err
	}

	res.Status = http.StatusOK
	res.Message = "Sukses Upload Foto"
	res.Data = file.Filename

	return res, nil
}

func GetPhoto(path string, id string) string {
	result := "uploads/" + path + "/" + path + "-" + id + ".png"
	fmt.Println(result)
	return result
}

func UpdateDataFoto(tabel string,  kolom string,  id int) error {
	log.Println("mengubah status foto di DB")
	con, err := db.DbConnection()
	defer db.DbClose(con)
	if err != nil {
		log.Println("error: " + err.Error())
		return err
	}
	// var query string 

	query := fmt.Sprintf("UPDATE %s SET %s='%s' where id = %d", tabel, kolom, "ada", id)

	rows, err := con.Query(query)
	if err == nil {
		return err
	}
	defer rows.Close()
	if err != nil {
		return err
	}
	defer con.Close()
	fmt.Println("status foto di edit")
	return nil
}

func UpdateDataFotoPath(tabel string, kolom string, path string, kolom_id string, id int) error {
	log.Println("mengubah status foto di DB")
	con, err := db.DbConnection()
	defer db.DbClose(con)
	if err != nil {
		log.Println("errorrr: " + err.Error())
		return err
	}

	query := fmt.Sprintf("UPDATE %s SET %s='%s' where %s_id = %d", tabel, kolom, path, kolom_id, id)

	rows, err := con.Query(query)
	if err != nil {
		log.Println("kolom", kolom)
		log.Println("error row: " + err.Error())
		return err
	}
	defer rows.Close()
	if err != nil {
		return err
	}
	defer con.Close()
	fmt.Println("status foto di edit")
	return nil
}

func ReadJSONFile (path string, obj any) (any, error) {
	fileData, err := os.ReadFile(path)
	if err != nil {
		return obj, err
	}

	err = json.Unmarshal(fileData, &obj)
	if err != nil {
		return obj, err
	}
	return obj, nil
}

func ReadConfigFile()(Response, error) {
	var res Response
	var conf interface{}
	var err error
	conf, err = ReadJSONFile("model/config.json", conf)
	if err != nil {
		res.Status = 401
		res.Message = "gagal mengambil config"
		res.Data = err.Error()
		return res, err
	}

	res.Status = 200
	res.Message = "Berhasil"
	res.Data = conf
	return res, nil
}