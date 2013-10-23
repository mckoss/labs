package main

import (
	"bytes"
	"testing"
)

func TestWriteInts(t *testing.T) {
	var buf bytes.Buffer

	var writeIntsTests = []struct {
		input    []int
		expected string
	}{
		{[]int{}, ""},
		{[]int{1}, "1"},
		{[]int{1, 2, 3}, "1, 2, 3"},
	}

	for _, wt := range writeIntsTests {
		buf.Reset()
		WriteInts(&buf, wt.input)
		if buf.String() != wt.expected {
			t.Errorf("Got %q expected %q", buf.String(), wt.expected)
		}
	}
}
