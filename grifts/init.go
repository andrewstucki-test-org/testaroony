package grifts

import (
  "github.com/gobuffalo/buffalo"
	"github.com/andrewstucki-test-org/example/actions"
)

func init() {
  buffalo.Grifts(actions.App())
}
