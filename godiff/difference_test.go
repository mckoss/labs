package main

import (
	"bytes"
	"reflect"
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

func TestDiffSets_new(t *testing.T) {
	ds := newDiffSet(3, []int{0, 1})
	expect(t, "status", ds.status, Idle)
	expect(t, "k", ds.k, 3)
	expect(t, "v", ds.v, 7)
	expect(t, "trials", ds.trials, 0)
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 2)
	expect(t, "s", ds.s, []int{0, 1, 0})
}

func TestDiffSets_Find3(t *testing.T) {
	ds := newDiffSet(3, []int{0, 1})
	ds.Find()
	expect(t, "status", ds.status, Complete)
	expect(t, "k", ds.k, 3)
	expect(t, "v", ds.v, 7)
	expect(t, "trials", ds.trials, 1)
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 3)
	expect(t, "s", ds.s, []int{0, 1, 3})
}

func TestDiffSets_Find4(t *testing.T) {
	ds := newDiffSet(4, []int{0, 1})
	ds.Find()
	expect(t, "status", ds.status, Complete)
	expect(t, "k", ds.k, 4)
	expect(t, "v", ds.v, 13)
	expect(t, "trials", ds.trials, 4)
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 4)
	expect(t, "s", ds.s, []int{0, 1, 3, 9})
}

func expect(t *testing.T, what string, got, expected interface{}) {
	if !reflect.DeepEqual(got, expected) {
		t.Errorf("Expected %s == %v but got %v.\n", what, expected, got)
	}
}
