package shortener

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/julienschmidt/httprouter"
	"github.com/kyue1005/deepstruggleinspection/Q3/models"
	"github.com/sirupsen/logrus"
)

type Rule struct {
	IP     string `json:"ip"`
	Limit  int    `json:"limit"`
	Time   int    `json:"time"`
	Count  int
	Create time.Time
}

type Rules struct {
	List []Rule `json:"rules"`
}

type Config struct {
	Log       *logrus.Logger
	Table     string
	Region    string
	Domain    string
	KeyLength int
}

type Shortener struct {
	Router      *httprouter.Router
	Config      Config
	ShortUrlMap models.KVStore
}

var effectiveRule []*Rule

func init() {
	rand.Seed(time.Now().UnixNano())
}

func New(cfg Config) Shortener {
	router := httprouter.New()

	m := models.NewShortUrlMap(models.Config{
		Table:  cfg.Table,
		Region: cfg.Region,
		Log:    cfg.Log,
	})

	s := Shortener{
		Router:      router,
		Config:      cfg,
		ShortUrlMap: m,
	}

	s.Router.POST("/newurl", s.shorten)
	s.Router.POST("/ratelimit", s.ratelimit)
	s.Router.GET("/:key", s.redirect)

	return s
}

func (s *Shortener) shorten(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	log := s.Config.Log
	type req struct {
		Url string `json:"url"`
	}

	decoder := json.NewDecoder(r.Body)
	var j req
	err := decoder.Decode(&j)
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	u, err := s.ShortUrlMap.GetItem("url", j.Url)
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	key := u.ShortKey
	if key == "" {
		// Make sure key is not duplicated
		for {
			key = randString(s.Config.KeyLength)
			u, err := s.ShortUrlMap.GetItem("key", key)
			if err != nil {
				log.Error(err.Error())
				w.WriteHeader(500)
				return
			}
			if u.SrcUrl == "" {
				break
			}
		}

		item := models.ShortUrlMap{
			ShortKey: key,
			SrcUrl:   j.Url,
		}

		_, err = s.ShortUrlMap.Insert(item)
		if err != nil {
			log.Error(err.Error())
			w.WriteHeader(500)
			return
		}
	}

	type rsp struct {
		Url      string `json:"url"`
		ShortUrl string `json:"shortenUrl"`
	}

	su := fmt.Sprintf("%s/%s", s.Config.Domain, key)

	json, err := json.Marshal(&rsp{
		Url:      j.Url,
		ShortUrl: su,
	})
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	w.Write(json)
}

func (s *Shortener) ratelimit(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	log := s.Config.Log

	decoder := json.NewDecoder(r.Body)
	var j Rules
	err := decoder.Decode(&j)
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	for _, item := range j.List {
		effectiveRule = append(effectiveRule, &Rule{
			IP:     item.IP,
			Limit:  item.Limit,
			Time:   item.Time,
			Count:  0,
			Create: time.Now(),
		})
	}

	reqIP := r.Header.Get("X-REAL-IP")

	for _, item := range effectiveRule {
		ruleExpired := (item.Create.Unix()*1000+int64(item.Time) < time.Now().Unix()*1000)

		if !ruleExpired && item.IP == reqIP {
			log.Info("hit")
			item.Count = item.Count + 1

			if item.Count > item.Limit {
				http.Error(w, http.StatusText(http.StatusTooManyRequests), http.StatusTooManyRequests)
				return
			}
		}
	}
	w.Write([]byte("Rule Received"))
}

func (s *Shortener) redirect(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	log := s.Config.Log
	key := ps.ByName("key")

	if key == "healthz" {
		w.Write([]byte("OK"))
		return
	}

	u, err := s.ShortUrlMap.GetItem("key", key)
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	if u.SrcUrl == "" {
		log.Warn(fmt.Sprintf("no url mapped to request: %s", key))
		w.WriteHeader(404)
		return
	}

	http.Redirect(w, r, u.SrcUrl, http.StatusNotModified)
}

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
const (
	letterIdxBits = 6                    // 6 bits to represent a letter index
	letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
	letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
)

func randString(n int) string {
	b := make([]byte, n)
	// A rand.Int63() generates 63 random bits, enough for letterIdxMax letters!
	for i, cache, remain := n-1, rand.Int63(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = rand.Int63(), letterIdxMax
		}
		if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
			b[i] = letterBytes[idx]
			i--
		}
		cache >>= letterIdxBits
		remain--
	}

	return string(b)
}
