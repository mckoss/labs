package jobs

import (
	"fmt"
	"log"
	"os"
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
	require  chan bool
	visited  bool
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
	ready  chan bool
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

func (tree *Tree) BuildSync() {
	for _, node := range tree.lookup {
		node.visited = false
	}
	tree.root.BuildSync()
}

func (tree *Tree) BuildAsync() {
	ready := make(chan bool)
	for _, node := range tree.lookup {
		node.require = make(chan bool)
	}
	for _, node := range tree.lookup {
		if node == tree.root {
			go node.BuildAsync(ready)
		} else {
			go node.BuildAsync(nil)
		}
	}
	<-ready
}

func (tree *Tree) AddRule(rule *Rule) *Node {
	node := tree.Ensure(rule.target)
	if node.rule != nil {
		log.Printf("Duplicate rule for %s", rule.target)
		return nil
	}
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

func (node *Node) BuildAsync(ready chan<- bool) {
	node.WaitForChildren()
	node.Exec()
	for _, parent := range node.parents {
		fmt.Fprintf(os.Stderr, "Signal %s -> %s\n", node.name, parent.name)
		parent.require <- true
	}
	if ready != nil {
		ready <- true
	}
}

func (node *Node) WaitForChildren() {
	require := len(node.children)
	if require == 0 {
		return
	}
	fmt.Fprintf(os.Stderr, "%s is waiting ...\n", node.name)
	for _ = range node.require {
		require--
		fmt.Fprintf(os.Stderr, "%s: %d deps left.\n", node.name, require)
		if require < 0 {
			panic("Too many dependencies.")
		}
		if require == 0 {
			return
		}
	}
}

// BuildSync runs all the execution commands synchronously using DFS
func (node *Node) BuildSync() {
	if node.visited {
		return
	}
	for _, child := range node.children {
		child.BuildSync()
	}
	node.Exec()
	node.visited = true
}
