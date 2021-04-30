package log

import (
	"github.com/sirupsen/logrus"
	log "github.com/sirupsen/logrus"
)

func New(level log.Level) *log.Logger {
	log := logrus.New()

	// Only log the warning severity or above.
	log.SetLevel(level)

	return log
}
