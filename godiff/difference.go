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
	var doContinue bool
	var prefix []int

	flag.BoolVar(&doContinue, "continue", false, "Continue beyond prefix point.")
	flag.Usage = usage
	flag.Parse()

	// <k-start>
	if flag.NArg() >= 1 {
		start, err = strconv.Atoi(flag.Arg(0))
		if err != nil || start < minK || start > maxK {
			fmt.Fprintf(os.Stderr, "'%s' is not a valid start size.\n", flag.Arg(0))
			usage()
		}
	}

	// <k-start> <k-end>
	if flag.NArg() == 2 {
		end, err = strconv.Atoi(flag.Arg(1))
		if err != nil || end < start || end > maxK {
			fmt.Fprintf(os.Stderr, "'%s' is not a valid ending size.\n", flag.Arg(0))
			usage()
		}
	}

	// <k> <prefix 0> <prefix 1> ...
	if flag.NArg() > 2 {
		for i := 1; i < flag.NArg(); i++ {
			var p int

			p, err = strconv.Atoi(flag.Arg(1))
			if err != nil || p < 0 || p > maxK {
				fmt.Fprintf(os.Stderr, "'%s' is not a valid number.", flag.Arg(i))
				usage()
			}
			prefix = append(prefix, p)
		}
	} else {
		prefix = make([]int, 2)
		prefix[0] = 0
		prefix[1] = 1
	}

	fmt.Fprintf(os.Stderr, "Searching for difference sets between %d and %d elements.\n", start, end)
	fmt.Fprintf(os.Stderr, "Prefix: ")
	WriteInts(os.Stderr, prefix)
	fmt.Fprintf(os.Stderr, "\n")

	powers := primePowers(maxK)
	for i := 0; i < len(powers); i++ {
		ds := newDiffSet(powers[0]+1, prefix)

		if ds.k < start {
			continue
		}

		if ds.k > end {
			break
		}

		ds.WriteInfo(os.Stderr)
		ds.Find()
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: difference [k-start] [k-end]]\n")
	fmt.Fprintf(os.Stderr, "       difference [-c] [k] [prefix1 prefix 2 ...]\n")
	fmt.Fprintf(os.Stderr, "Find difference sets of order k.\n\n")
	flag.PrintDefaults()
	os.Exit(1)
}

type Status int

const (
	Idle Status = iota
	Running
	Complete
)

type diffSet struct {
	status      Status
	k           int
	v           int
	trials      int
	prefixSize  int
	targetDepth int
	current     int
	low         int
	s           []int
	diffs       []bool
}

func newDiffSet(k int, prefix []int) *diffSet {
	v := k*(k-1) + 1
	initial := make([]int, k)

	for i := 0; i < len(prefix); i++ {
		initial[i] = prefix[i]
	}

	ds := diffSet{
		k:     k,
		v:     v,
		s:     initial,
		diffs: make([]bool, v/2+1),
	}

	ds.diffs[0] = true

	for p := range prefix {
		ds.push(p)
	}

	return &ds
}

func (ds *diffSet) WriteInfo(w io.Writer) {
	fmt.Fprintf(w, "\nDifference set (k = %d, v = %d, lambda = 1):\n", ds.k, ds.v)
}

func (ds *diffSet) WriteTrace(w io.Writer) {
	var completeString string
	if ds.status == Complete {
		completeString = "*"
	}

	var solvedString string
	if ds.current == ds.k {
		solvedString = " SOLVED"
	}

	fmt.Fprintf(w, "%s: (%d, %d) @%s: ", completeString, ds.k, ds.v, ds.trials)
	fmt.Fprintf(w, "%d%v", ds.current, ds.s)
	fmt.Fprintf(w, " (low = %d)%s\n", ds.low, solvedString)
}

func (ds *diffSet) Find() {
	ds.SearchNext(ds.s[ds.current-1] + ds.low + 1)
}

func (ds *diffSet) SearchNext(candidate int) {
	for {
		ds.WriteTrace(os.Stderr)
		if ds.current == ds.targetDepth || ds.current == ds.k {
			ds.status = Complete
			return
		}

		ds.trials++

		if ds.push(candidate) {
			candidate += ds.low + 1
			continue
		}

		candidate++

		if candidate+(ds.low+1)*(ds.k-ds.current-1) >= ds.v-ds.low {
			candidate = ds.pop() + 1
		}
	}
}

func (ds *diffSet) push(a int) bool {
	fmt.Fprintf(os.Stderr, "push %d\n", a)
	if a >= ds.v {
		return false
	}

	for i := 0; i < ds.current; i++ {
		d := a - ds.s[i]
		if d < 0 {
			d += ds.v
		}
		if d > ds.v/2 {
			d = ds.v - d
		}
		if ds.diffs[d] {
			for j := 0; j < i; j++ {
				d = a - ds.s[i]
				if d < 0 {
					d += ds.v
				}
				if d > ds.v/2 {
					d = ds.v - d
				}
				ds.diffs[d] = false
			}
			return false
		}
		ds.diffs[d] = true
	}
	fmt.Fprintf(os.Stderr, "len(s) = %d, current = %d, a = %d\n", len(ds.s), ds.current, a)
	ds.s[ds.current] = a
	ds.current++
	fmt.Fprintf(os.Stderr, "len(s) = %d, current = %d, a = %d\n", len(ds.s), ds.current, a)

	fmt.Fprintf(os.Stderr, "len(diffs) = %d\n", len(ds.diffs))
	for ds.low < ds.v/2 && ds.diffs[ds.low+1] {
		ds.low++
	}

	return true
}

func (ds *diffSet) pop() int {
	ds.current--
	a := ds.s[ds.current]
	for i := 0; i < ds.current; i++ {
		d := a - ds.s[i]
		if d < 0 {
			d += ds.v
		}
		if d > ds.v/2 {
			d = ds.v - d
		}
		ds.diffs[d] = false
		if d <= ds.low {
			ds.low = d - 1
		}
	}
	return a
}

// primePowers returns 1 and all prime powers less than or equal to max.
func primePowers(max int) []int {
	s := make([]bool, max)
	var powers []int
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

// WriteInts writes a comma separated slice of ints.
func WriteInts(w io.Writer, a []int) {
	sep := ""
	for _, n := range a {
		fmt.Fprintf(w, "%s%d", sep, n)
		sep = ", "
	}
}
