/* ================================================================
   difference.go - Difference Set generator.

   Calculate difference sets of various sizes - using threading library
   to maximize CPU cores in the search.

   This program implements exhaustive search and ensures finding the
   difference set with smallest topological value.

   Copyright 2013, Mike Koss

   Todo:

   - Option to return all solutions (not just first found).
`================================================================== */
package main

import (
	"flag"
	"fmt"
	"io"
	"math"
	"os"
	"sort"
	"strconv"
)

const (
	minK = 2
	maxK = 103
)

func main() {
	var err error
	var start int = 2
	var end int = 103
	var showHelp bool
	var doContinue bool

	flag.BoolVar(&showHelp, "help", false, "Show command usage.")
	flag.BoolVar(&doContinue, "continue", false, "Continue beyond prefix point.")
	flag.Parse()

	if showHelp {
		usage()
	}

	if flag.NArg() >= 1 {
		start, err = strconv.Atoi(flag.Arg(0))
		if err != nil || start < minK || start > maxK {
			fmt.Printf("'%s' is not a valid start size.\n", flag.Arg(0))
			usage()
		}
	}
	if flag.NArg() >= 2 {
		end, err = strconv.Atoi(flag.Arg(1))
		if err != nil || end < start || end > maxK {
			fmt.Printf("'%s' is not a valid ending size.\n", flag.Arg(0))
			usage()
		}
	}

	fmt.Printf("Searching for difference sets between %d and %d elements.\n", start, end)
	powers := primePowers(maxK)
	for i := 0; i < len(powers); i++ {
		ds := newDiffSet(powers[i] + 1)

		if ds.k < start {
			continue
		}

		if ds.k > end {
			break
		}

		ds.WriteInfo(os.Stderr)
		ds.SearchNext()
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: difference [k-start] [k-end]]\n")
	fmt.Fprintf(os.Stderr, "       difference [-c] [k] [prefix1 prefix 2 ...]\n")
	fmt.Fprintf(os.Stderr, "Find difference sets of order k.\n\n")
	flag.PrintDefaults()
	os.Exit(1)
}

type diffSet struct {
	k           int
	v           int
	trials      int
	prefixSize  int
	targetDepth int
	s           []int
	diffs       []bool
}

func newDiffSet(k int) *diffSet {
	v := k*(k-1) + 1
	return &diffSet{
		k:     k,
		v:     v,
		s:     make([]int, k),
		diffs: make([]bool, v/2),
	}
}

func (ds *diffSet) WriteInfo(w io.Writer) {
	fmt.Fprintf(w, "\nDifference set (k = %d, v = %d, lambda = 1):\n", ds.k, ds.v)
}

func (ds *diffSet) SearchNext() {

}

// primePowers returns 1 and all prime powers less than or equal to max.
func primePowers(max int) []int {
	s := make([]bool, max)
	powers := make([]int, 0)
	sq := int(math.Sqrt(float64(max)))

	powers = append(powers, 1)
	for i := 2; i < max; i++ {
		if s[i] {
			continue
		}
		powers = append(powers, i)
		if i > sq {
			continue
		}
		for j := i * i; j < max; j += i {
			s[j] = true
		}
		for power := i * i; power < max; power *= i {
			powers = append(powers, power)
		}
	}

	sort.Ints(powers)

	return powers
}
