package jobs

import (
	"fmt"
	"log"
)

type Rule struct {
	target  string
	prereqs []string
	recipe  string
}

type Node struct {
	name     string
	children []*Node
	parents  []*Node
	rule     *Rule
}

func (node *Node) Exec() {
	if node.rule == nil {
		fmt.Printf("Confirm leaf: %s\n", node.name)
		return
	}
	rule := node.rule
	fmt.Printf("%s <- %v\n", rule.target, rule.prereqs)
	fmt.Printf("Running: %s\n", rule.recipe)
}

type Tree struct {
	lookup map[string]*Node
	root   *Node
}

func NewTree() *Tree {
	return &Tree{lookup: make(map[string]*Node)}
}

func BuildTree(rules []*Rule) *Tree {
	tree := NewTree()
	for _, rule := range rules {
		tree.AddRule(rule)
	}

	var roots []*Node
	for _, node := range tree.lookup {
		if len(node.parents) == 0 {
			roots = append(roots, node)
		}
	}

	switch len(roots) {
	case 0:
		log.Printf("Circular reference in tree (at root).")
	case 1:
		tree.root = roots[0]
	default:
		var prereqs []string
		for _, node := range roots {
			prereqs = append(prereqs, node.name)
		}
		virtualRoot := &Rule{"virtual_root", prereqs, "# build all roots."}
		tree.root = tree.AddRule(virtualRoot)
	}
	return tree
}

// BuildSync runs all the execution commands synchronously using DFS
func (node *Node) BuildSync() {
	for _, child := range node.children {
		child.BuildSync()
	}
	node.Exec()
}

func (tree *Tree) AddRule(rule *Rule) *Node {
	if tree.lookup[rule.target] != nil {
		log.Printf("Duplicate rule for %s", rule.target)
		return nil
	}
	node := tree.Ensure(rule.target)
	node.rule = rule
	for _, pre := range rule.prereqs {
		child := tree.Ensure(pre)
		node.children = append(node.children, child)
		child.parents = append(child.parents, node)
	}
	return node
}

func (tree *Tree) Ensure(name string) *Node {
	if tree.lookup[name] == nil {
		tree.lookup[name] = &Node{name: name}
	}
	return tree.lookup[name]
}
