package models

import (
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/expression"
)

type ShortUrlMap struct {
	ShortKey string `json:"key"`
	SrcUrl   string `json:"url"`
}

func NewShortUrlMap(cfg Config) KVStore {
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(cfg.Region)}),
	)

	return KVStore{
		Instance: dynamodb.New(sess),
		Config:   cfg,
	}
}

func (k KVStore) GetItem(t interface{}, i interface{}) (ShortUrlMap, error) {
	filt := expression.Name(t.(string)).Equal(expression.Value(i.(string)))
	proj := expression.NamesList(expression.Name("key"), expression.Name("url"))
	expr, err := expression.NewBuilder().WithFilter(filt).WithProjection(proj).Build()
	if err != nil {
		log.Fatalf("Got error building expression: %s", err)
	}
	result, err := k.Instance.Scan(&dynamodb.ScanInput{
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		FilterExpression:          expr.Filter(),
		ProjectionExpression:      expr.Projection(),
		TableName:                 aws.String(k.Config.Table),
	})
	if err != nil {
		return ShortUrlMap{}, err
	}

	u := ShortUrlMap{}

	for _, i := range result.Items {
		err = dynamodbattribute.UnmarshalMap(i, &u)
		if err != nil {
			return ShortUrlMap{}, err
		}
	}

	return u, nil
}

func (k KVStore) Insert(i interface{}) (interface{}, error) {
	av, err := dynamodbattribute.MarshalMap(i)
	if err != nil {
		return nil, err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(k.Config.Table),
	}

	_, err = k.Instance.PutItem(input)
	if err != nil {
		return nil, err
	}

	return i, nil
}
