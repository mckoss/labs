package jobs

import (
	"reflect"
	"testing"
)

var tests []*Rule = []*Rule{
	&Rule{
		target:  "target",
		prereqs: []string{"one", "two", "three"},
		recipe:  "build-1"},
}

var diamond []*Rule = []*Rule{
	&Rule{
		target:  "root",
		prereqs: []string{"B", "C"},
		recipe:  "merge",
	},
	&Rule{
		target:  "B",
		prereqs: []string{"A"},
		recipe:  "split",
	},
	&Rule{
		target:  "C",
		prereqs: []string{"A"},
		recipe:  "split",
	},
}

func TestBuildTree(t *testing.T) {
	tree := BuildTree(tests)
	expect(t, "tree", tree.root.name, "target")
	expect(t, "nodes", len(tree.lookup), 4)
	expect(t, "children", len(tree.root.children), 3)
	expect(t, "parent", len(tree.Ensure("one").parents), 1)
	expect(t, "root", tree.Ensure("one").parents[0], tree.root)
}

func ExampleBuildSync() {
	tree := BuildTree(tests)
	tree.BuildSync()
	// Output:
	// Confirm leaf: one
	// Confirm leaf: two
	// Confirm leaf: three
	// target <- [one two three]
	// Running: build-1
}

func ExampleBuildSyncDiamond() {
	tree := BuildTree(diamond)
	tree.BuildSync()
	// Output:
	// Confirm leaf: A
	// B <- [A]
	// Running: split
	// C <- [A]
	// Running: split
	// root <- [B C]
	// Running: merge
}

func ExampleBuildAsync() {
	tree := BuildTree(tests)
	tree.BuildAsync()
	// Output:
	// Confirm leaf: one
	// Confirm leaf: two
	// Confirm leaf: three
	// target <- [one two three]
	// Running: build-1
}
func ExampleBuildAsyncDiamond() {
	tree := BuildTree(diamond)
	tree.BuildAsync()
	// Output:
	// Confirm leaf: A
	// B <- [A]
	// Running: split
	// C <- [A]
	// Running: split
	// root <- [B C]
	// Running: merge
}

func expect(t *testing.T, what string, got, expected interface{}) {
	if !reflect.DeepEqual(got, expected) {
		t.Errorf("Expected %s == %v(%T) but got %v(%T).\n", what, expected, expected, got, got)
	}
}
