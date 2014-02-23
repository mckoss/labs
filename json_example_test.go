package main

import (
	"encoding/json"
	"fmt"
	"reflect"
	"testing"
)

func main() {
	fmt.Printf("Hello, world - %s.\n", 123)
}

func TestJSONMarshal(t *testing.T) {
	tests := []interface{}{
		TestStruct{},
		JustInterface(),
		JustPInterface(),
	}
	for _, test := range tests {
		bytes, _ := json.MarshalIndent(test, "", "  ")
		fmt.Printf("JSON: (%T) %s\n", test, bytes)
	}
	// Force output
	t.Fatal()
}

func TestJSONUnmarshal(t *testing.T) {
	var test TestStruct
	json.Unmarshal([]byte(`{"foo": "one", "bar": "two", "bazz": 33}`), &test)
	fmt.Printf("Struct: %t\n", test)
	json.Unmarshal([]byte(`{"bazz": 34, "extra": false}`), &test)
	fmt.Printf("Struct: %t\n", test)
	json.Unmarshal([]byte(`{"nums": [7, 6, 5]}`), &test)
	fmt.Printf("Struct: %t\n", test)
	err := json.Unmarshal([]byte(`{"map": {"a": 99, "b": "98"}}`), &test)
	fmt.Printf("Struct: %s, %t\n", err, test)
	t.Fatal()
}

func TestDowncast(t *testing.T) {
	test := JustInterface()
	fmt.Printf("Test %t\n", test)
	bytes, _ := json.MarshalIndent(test, "", "  ")
	var generic interface{}
	json.Unmarshal(bytes, &generic)
	fmt.Printf("Generic: %t\n", generic)
	t.Fatal()
}

type TestStruct struct {
	Foo  string           `json:"foo"`
	Bar  string           `json:"bar,omitempty"`
	Bazz int64            `json:"bazz"`
	Nums []int64          `json:"nums"`
	Map  map[string]int64 `json:"map"`
}

func JustInterface() interface{} {
	return TestStruct{"one", "two", 3, []int64{1, 2, 3}, map[string]int64{"a": 1}}
}

func JustPInterface() interface{} {
	return new(TestStruct)
}

func expect(t *testing.T, what string, got, expected interface{}) {
	if !reflect.DeepEqual(got, expected) {
		t.Errorf("Expected %s == %v(%T) but got %v(%T).\n", what, expected, expected, got, got)
	}
}
