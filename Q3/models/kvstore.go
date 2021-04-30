package models

import (
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/sirupsen/logrus"
)

type Config struct {
	Table  string
	Region string
	Log    *logrus.Logger
}

type KVStore struct {
	Instance *dynamodb.DynamoDB
	Config   Config
}
