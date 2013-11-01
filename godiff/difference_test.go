package main

import (
	"bytes"
	"fmt"
	"reflect"
	"testing"
)

func TestWriteInts(t *testing.T) {
	var buf bytes.Buffer

	var writeIntsTests = []struct {
		input    []int32
		expected string
	}{
		{[]int32{}, ""},
		{[]int32{1}, "  1"},
		{[]int32{1, 2, 3}, "  1,   2,   3"},
		{[]int32{1, 12, 3}, "  1,  12,   3"},
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
	ds := newDiffSet(3, []int32{0, 1})
	expect(t, "k", ds.k, 3)
	expect(t, "v", ds.v, int32(7))
	expect(t, "trials", ds.trials, int64(0))
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 2)
	expect(t, "s", ds.s, []int32{0, 1, 0})
}

func TestDiffSets_Find3(t *testing.T) {
	ds := newDiffSet(3, []int32{0, 1})
	ds.Find(nil, nil)
	expect(t, "k", ds.k, 3)
	expect(t, "v", ds.v, int32(7))
	expect(t, "trials", ds.trials, int64(1))
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 3)
	expect(t, "s", ds.s, []int32{0, 1, 3})
}

func TestDiffSets_Find4(t *testing.T) {
	ds := newDiffSet(4, []int32{0, 1})
	ds.Find(nil, nil)
	expect(t, "k", ds.k, 4)
	expect(t, "v", ds.v, int32(13))
	expect(t, "trials", ds.trials, int64(4))
	expect(t, "targetDepth", ds.targetDepth, 0)
	expect(t, "current", ds.current, 4)
	expect(t, "s", ds.s, []int32{0, 1, 3, 9})
}

func TestCommas(t *testing.T) {
	commasTests := []struct {
		value    int
		expected string
	}{
		{0, "0"},
		{1, "1"},
		{12, "12"},
		{123, "123"},
		{1234, "1,234"},
		{12345, "12,345"},
		{123456, "123,456"},
		{1234567, "1,234,567"},
	}
	for _, test := range commasTests {
		expect(t, fmt.Sprintf("%d", test.value), commas(test.value), test.expected)
	}
}

func TestSetGenerator(t *testing.T) {
	expect := []string{
		"( 2,   3)   0,   1",
		"( 3,   7)   0,   1,   3",
		"( 4,  13)   0,   1,   3,   9",
		"( 5,  21)   0,   1,   3,   7 (low = 4, target = 4)",
		"( 5,  21)   0,   1,   3,   8 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,   9 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  10 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  13 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  14 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  15 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  16 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  17 (low = 5, target = 4)",
		"( 5,  21)   0,   1,   4,   6 (low = 6, target = 4)",
		"( 5,  21)   0,   1,   4,   9 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   4,  10 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   4,  12 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   4,  14 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   4,  15 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   4,  16 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   5,   7 (low = 2, target = 4)",
		"( 5,  21)   0,   1,   5,   8 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   5,  12 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   5,  14 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   5,  15 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   6,   8 (low = 2, target = 4)",
		"( 5,  21)   0,   1,   6,   9 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   6,  10 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   6,  13 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   7,   9 (low = 2, target = 4)",
		"( 5,  21)   0,   1,   7,  10 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   7,  12 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   7,  17 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   7,  18 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   7,  19 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   8,  10 (low = 2, target = 4)",
		"( 5,  21)   0,   1,   8,  12 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   8,  17 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   8,  18 (low = 1, target = 4)",
		"( 5,  21)   0,   1,   8,  19 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   9,  16 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  10,  14 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  10,  15 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  10,  17 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  10,  18 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  12,  14 (low = 2, target = 4)",
		"( 5,  21)   0,   1,  12,  15 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  12,  16 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  13,  15 (low = 2, target = 4)",
		"( 5,  21)   0,   1,  13,  16 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  14,  16 (low = 2, target = 4)",
		"( 5,  21)   0,   1,  14,  17 (low = 1, target = 4)",
		"( 5,  21)   0,   1,  15,  17 (low = 2, target = 4)",
		"( 5,  21)   0,   1,  16,  18 (low = 6, target = 4)",
	}
	sets, _ := setGenerator(2, 5, []int32{0, 1})
	for _, s := range expect {
		set := <-sets
		if set.String() != s {
			t.Errorf("Generated %q, but expected %q.\n", set.String(), s)
		}
		if set.targetDepth > set.k && set.targetDepth != 4 {
			t.Errorf("Invalid target depth %d.", set.targetDepth)
		}
	}
	count := 0
	for set := range sets {
		count++
		if count > 1 || set.current != 1 || set.s[0] != 0 {
			t.Errorf("Generating unexpected set: %q", set.String())
		}
	}
}

func TestSetGeneratorAdvance(t *testing.T) {
	expect := []string{
		"( 5,  21)   0,   1,   3,   7 (low = 4, target = 4)",
		"( 5,  21)   0,   1,   3,   8 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,   9 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  10 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  13 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  14 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  15 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  16 (low = 3, target = 4)",
		"( 5,  21)   0,   1,   3,  17 (low = 5, target = 4)",
		"( 5,  21)   0,   1,   4,   6 (low = 6, target = 4)",
		"( 5,  21)   0,   1,   4,   9 (low = 1, target = 4)",
		// advance called here
		//"( 5,  21)   0,   1,   4,  10 (low = 1, target = 4)",
		//"( 5,  21)   0,   1,   4,  12 (low = 1, target = 4)",
		//"( 5,  21)   0,   1,   4,  14 (low = 1, target = 4)",
		"( 6,  31)   0,   1,   3,   7 (low = 4, target = 4)",
	}
	sets, pass := setGenerator(5, 6, []int32{0, 1})
	for _, s := range expect {
		set := <-sets
		// Depending on timing, we can get one extra old set
		if set.s[2] == 4 && set.s[3] == 10 {
			continue
		}
		if set.String() != s {
			t.Errorf("Generated %q, but expected %q.\n", set.String(), s)
		}
		if set.s[2] == 4 && set.s[3] == 9 {
			pass(5)
		}
	}
}

func expect(t *testing.T, what string, got, expected interface{}) {
	if !reflect.DeepEqual(got, expected) {
		t.Errorf("Expected %s == %v(%T) but got %v(%T).\n", what, expected, expected, got, got)
	}
}
