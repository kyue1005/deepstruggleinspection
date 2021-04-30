package shortener

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/kyue1005/deepstruggleinspection/Q3/models"
	"github.com/sirupsen/logrus"
)

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
	s.Router.GET("/:key", s.redirect)
	s.Router.HandleMethodNotAllowed = false

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

func (s *Shortener) redirect(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	log := s.Config.Log
	key := ps.ByName("key")
	u, err := s.ShortUrlMap.GetItem("key", key)
	if err != nil {
		log.Error(err.Error())
		w.WriteHeader(500)
		return
	}

	if u.SrcUrl == "" {
		log.Info("whwhw")
		log.Warn(fmt.Sprintf("no url mapped to request: %s", key))
		w.WriteHeader(404)
		return
	}

	http.Redirect(w, r, u.SrcUrl, http.StatusNotModified)
}

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
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
