package jobs

import (
	"reflect"
	"testing"
)

var tests []*Rule = []*Rule{
	&Rule{target: "target",
		prereqs: []string{"one", "two", "three"},
		recipe:  "build-1"},
}

func TestBuildTree(t *testing.T) {
	tree := BuildTree(tests)
	expect(t, "tree", tree.root.name, "target")
	expect(t, "children", len(tree.root.children), 3)
	expect(t, "parent", len(tree.Ensure("one").parents), 1)
	expect(t, "root", tree.Ensure("one").parents[0], tree.root)
}

func ExampleBuildTree() {
	tree := BuildTree(tests)
	tree.root.BuildSync()
	// Output:
	// Confirm leaf: one
	// Confirm leaf: two
	// Confirm leaf: three
	// target <- [one two three]
	// Running: build-1
}

func expect(t *testing.T, what string, got, expected interface{}) {
	if !reflect.DeepEqual(got, expected) {
		t.Errorf("Expected %s == %v(%T) but got %v(%T).\n", what, expected, expected, got, got)
	}
}
