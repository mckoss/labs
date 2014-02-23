package doer

import (
	"encoding/json"
	"fmt"
	"testing"
)

type Doer interface {
	New() Doer
	Do(Context) (interface{}, error)
}

type APIHandler struct {
	Doer
}

type Context struct {
}

func (h APIHandler) Serve(req []byte) (err error) {
	c := Context{}

	fmt.Printf("Request: %s\n", req)

	doer := h.Doer.New()
	err = json.Unmarshal(req, doer)
	if err != nil {
		fmt.Printf("Unmarhsal error: %s\n", err)
		return
	} else {
		fmt.Printf("Unmarshaled: %T: %v\n", doer, doer)
	}

	resp, err := doer.Do(c)
	bytes, _ := json.MarshalIndent(resp, "", "  ")

	fmt.Printf("Response: %T: %v\n", resp, resp)
	fmt.Printf("JSON: %s\n", bytes)
	return
}

type Command struct {
	X string   `json:"x"`
	Y int64    `json:"y"`
	Z []string `json:"z"`
}

type Result struct {
	Status string `json:"status"`
	Error  string `json:"error,omitempty"`
	Answer string `json:"answer"`
}

func (cmd *Command) New() Doer {
	return new(Command)
}

func (cmd *Command) Do(c Context) (resp interface{}, err error) {
	resp = Result{Status: "ok", Answer: fmt.Sprintf("%s: %d", cmd.X, cmd.Y)}
	return
}

func (Command) GetRequest() interface{} {
	return Command{}
}

func TestDoer(t *testing.T) {
	commandHandler := APIHandler{new(Command)}

	commandHandler.Serve([]byte(`{"x": "hi", "y": 123, "z": ["a", "b"]}`))
}
