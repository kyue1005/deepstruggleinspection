package main

import (
	"flag"
	"log"
	"net/http"
	"strconv"

	l "github.com/kyue1005/deepstruggleinspection/Q3/logger"
	"github.com/kyue1005/deepstruggleinspection/Q3/shortener"
	"github.com/sirupsen/logrus"
)

var (
	table      string
	region     string
	domain     string
	configPort int
	keylength  int
	logger     *logrus.Logger
)

func init() {
	flag.StringVar(&domain, "d", "", "short url domain")
	flag.StringVar(&table, "t", "", "dynamodb table name (required)")
	flag.StringVar(&region, "r", "us-east-1", "dynamodb aws region (required)")
	flag.IntVar(&keylength, "l", 9, "length of shorten key")
	flag.IntVar(&configPort, "p", 8080, "config HTTP server port")
	flag.Parse()
	validateInput()

	logger = l.New(logrus.InfoLevel)
}

func validateInput() {
	if len(table) == 0 {
		log.Fatal("missing short url domain name")
	}

	if len(table) == 0 {
		log.Fatal("missing dynamodb table name")
	}

	if len(region) == 0 {
		log.Fatal("missing dynamodb aws region")
	}
}

func main() {
	flag.Parse()

	s := shortener.New(shortener.Config{
		Table:     table,
		Region:    region,
		Domain:    domain,
		KeyLength: keylength,
		Log:       logger,
	})

	srv := &http.Server{
		Addr:    ":" + strconv.Itoa(configPort),
		Handler: s.Router,
	}

	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
