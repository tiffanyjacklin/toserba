package db

import (
	"context"
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"strconv"
	"time"
)

const (
	username = "root"
	password = "admin"
	hostname = "localhost"
	port     = "3306"
	dbname   = "toserba"
)

var OpenCon = 0

func DbClose(con *sql.DB) {
	con.Close()
	OpenCon -= 1
	fmt.Printf("%c%c", 13, 13)
	fmt.Print("Open Con <" + strconv.Itoa(OpenCon) + ">")
}

func DbConnection() (*sql.DB, error) {
	connectionString := username + ":" + password + "@tcp(" + hostname + ":" + port + ")/" + dbname + "?parseTime=true"
	db, err := sql.Open("mysql", connectionString)
	if err != nil {
		log.Printf("Error %s when opening DB\n", err)
		return nil, err
	}
	err = db.Ping()

	if err != nil {
		fmt.Println("Err :", err)
		fmt.Println("titdak dapat membuka koneksi")
		return nil, err
	}

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(time.Minute * 1)

	ctx, cancelfunc := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancelfunc()
	err = db.PingContext(ctx)
	if err != nil {
		log.Printf("Errors %s pinging DB", err)
		return nil, err
	}
	//log.Printf("Connected to DB %s successfully\n", dbname)
	OpenCon += 1
	fmt.Printf("%c%c", 13, 13)
	fmt.Print("Open Con <" + strconv.Itoa(OpenCon) + ">")
	return db, nil
}
