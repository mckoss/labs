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
	"bytes"
	"flag"
	"fmt"
	"io"
	"math"
	"os"
	"runtime"
	"sort"
	"strconv"
	"sync"
)

const (
	minK = 2
	maxK = 103
)

type diffSet struct {
	k           int    // Number of elements in set
	v           int    // Modulus of differences (k * (k-1) + 1)
	trials      int    // Number of trial so far
	targetDepth int    // Stop executing when current == targetDepth
	current     int    // s[0:current] is current search prefix
	low         int    // the largest i s.t. all diffs[i] == true
	s           []int  // Provisional difference set values
	diffs       []bool // Current differences covered by provisional set
}

type workerConnection struct {
	id        int
	keepAlive chan bool
	workQueue chan diffSet
	results   chan diffSet
	status    chan string
}

func newWorkerConnection(id int) *workerConnection {
	return &workerConnection{
		id:        id,
		keepAlive: make(chan bool),
		workQueue: make(chan diffSet, 1),
		results:   make(chan diffSet),
		status:    make(chan string),
	}
}

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
		end = start
		for i := 1; i < flag.NArg(); i++ {
			var p int

			p, err = strconv.Atoi(flag.Arg(i))
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

	maxWorkers := runtime.NumCPU()
	fmt.Fprintf(os.Stderr, "Running on %d CPUs.\n", maxWorkers)
	runtime.GOMAXPROCS(maxWorkers)

	requests := make(chan workerConnection)

	for i := 0; i < maxWorkers; i++ {
		go worker(i, requests)
	}

	workManager(start, end, prefix, requests)
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: difference [k-start] [k-end]]\n")
	fmt.Fprintf(os.Stderr, "       difference [-c] [k] [prefix1 prefix 2 ...]\n")
	fmt.Fprintf(os.Stderr, "Find difference sets of order k.\n\n")
	flag.PrintDefaults()
	os.Exit(1)
}

func workManager(
	start, end int,
	prefix []int,
	requests chan workerConnection,
) {
	var wg sync.WaitGroup

	sets, pass := setGenerator(start, end, prefix)

	// Syncronize trace and results output
	type Trace struct {
		id int
		string
	}
	traces := make(chan Trace)
	results := make(chan string)
	go func() {
		wg.Add(1)
		for trace := range traces {
			fmt.Fprintf(os.Stderr, "%d: %s\n", trace.id, trace.string)
		}
		wg.Done()
	}()
	go func() {
		wg.Add(1)
		for result := range results {
			fmt.Fprintln(os.Stdout, result)
		}
		wg.Done()
	}()

	var closer sync.Once
	for worker := range requests {
		traces <- Trace{worker.id, "connecting..."}

		// Process status messages
		go func(worker workerConnection) {
			wg.Add(1)
			for status := range worker.status {
				traces <- Trace{worker.id, status}
			}
			wg.Done()
		}(worker)

		// Process work
		go func(worker workerConnection) {
			wg.Add(1)
			for ds := range sets {
				// workQueue has 1 buffer so no need to call async.
				worker.workQueue <- ds

				result := <-worker.results

				if result.IsSolved() {
					var buf bytes.Buffer
					pass(result.k)
					result.WriteTrace(&buf)
					results <- buf.String()
				}
			}
			close(worker.workQueue)
			closer.Do(func() { close(requests) })
			wg.Done()
		}(worker)
	}
	close(traces)
	close(results)
	wg.Wait()
}

func setGenerator(start, end int, prefix []int) (<-chan diffSet, func(int)) {
	var pass int
	sets := make(chan diffSet)
	go func() {
		powers := primePowers(maxK)
		for i := 0; i < len(powers); i++ {
			k := powers[i] + 1
			if k < start || k <= pass {
				continue
			}

			if k > end {
				break
			}

			dsParent := newDiffSet(k, prefix)
			dsParent.targetDepth = len(prefix) + 2
			if dsParent.targetDepth > dsParent.k {
				dsParent.targetDepth = dsParent.k
			}
			dsParent.Find()
			for {
				if dsParent.k <= pass {
					break
				}

				dsCopy := *newDiffSet(k, dsParent.s[0:dsParent.current])
				dsCopy.targetDepth = dsParent.targetDepth
				if dsParent.current != dsParent.targetDepth ||
					dsParent.s[1] != 1 {
					break
				}
				sets <- dsCopy
				if dsCopy.IsSolved() {
					break
				}
				dsParent.SearchNext(dsParent.pop() + 1)
			}
		}
		close(sets)
	}()

	// Generator controller function - kick to next k.
	doPass := func(k int) {
		if k > pass {
			pass = k
		}
	}
	return sets, doPass
}

func worker(
	id int,
	requests chan<- workerConnection,
) {
	conn := newWorkerConnection(id)
	requests <- *conn
	conn.status <- "starting..."

	for ds := range conn.workQueue {
		ds.Find()
		conn.results <- ds
	}
	close(conn.status)
}

func newDiffSet(k int, prefix []int) *diffSet {
	v := k*(k-1) + 1

	ds := diffSet{
		k:     k,
		v:     v,
		diffs: make([]bool, v/2+1),
	}

	ds.s = make([]int, k)

	ds.diffs[0] = true

	for _, p := range prefix {
		if !ds.push(p) {
			return nil
		}
	}

	return &ds
}

func (ds *diffSet) WriteInfo(w io.Writer) {
	fmt.Fprintf(w, "\nDifference set (k = %d, v = %d, lambda = 1):\n", ds.k, ds.v)
}

func (ds *diffSet) WriteTrace(w io.Writer) {
	var solvedString string
	if ds.IsSolved() {
		solvedString = " SOLVED"
	}

	fmt.Fprintf(w, "(%d, %d) @%s: ", ds.k, ds.v, commas(ds.trials))
	WriteInts(w, ds.s[0:ds.current])
	fmt.Fprintf(w, " (low = %d)%s", ds.low, solvedString)
}

// Find the targetDepth or solution with prefix of current set.
func (ds *diffSet) Find() {
	if ds.current <= 1 {
		var buf bytes.Buffer
		ds.WriteTrace(&buf)
		panic(fmt.Sprintf("Illegal call to Find: %s", buf.String()))
	}
	ds.SearchNext(ds.s[ds.current-1] + ds.low + 1)
}

func (ds *diffSet) SearchNext(candidate int) {
	for {
		// ds.WriteTrace(os.Stderr)
		if ds.IsSolved() {
			return
		}

		ds.trials++

		if ds.push(candidate) {
			if ds.current == ds.targetDepth {
				return
			}
			candidate += ds.low + 1
			continue
		}

		candidate++

		if candidate+(ds.low+1)*(ds.k-ds.current-1) >= ds.v-ds.low {
			candidate = ds.pop() + 1
		}
	}
}

func (ds *diffSet) IsSolved() bool {
	return ds.current == ds.k
}

func (ds *diffSet) push(a int) (ok bool) {
	//debugStatus := func() {
	//	fmt.Fprintf(os.Stderr, "push(%d) -> %v\n", a, ok)
	//}
	//defer debugStatus()
	if a >= ds.v {
		return
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
				d = a - ds.s[j]
				if d < 0 {
					d += ds.v
				}
				if d > ds.v/2 {
					d = ds.v - d
				}
				ds.diffs[d] = false
			}
			return
		}
		ds.diffs[d] = true
	}
	ds.s[ds.current] = a
	ds.current++

	for ds.low < ds.v/2 && ds.diffs[ds.low+1] {
		ds.low++
	}

	ok = true
	return
}

func (ds *diffSet) pop() int {
	ds.current--
	if ds.current < 0 {
		panic("pop error")
	}
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

// commas converts integer to thousand-seperated string
func commas(v int) string {
	s := fmt.Sprintf("%d", v)
	chars := len(s)
	result := ""
	for i, ch := range s {
		result += string(ch)
		if (chars-i)%3 == 1 && (chars-i) != 1 {
			result += ","
		}
	}
	return result
}
