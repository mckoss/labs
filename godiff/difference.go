/*
difference.go performs a brute force search for difference sets.

A (cyclic) difference set is a collection of, k, integers whose pair-wise
differences (mod v) are all unique.  For example, for these values of k
these are the smallest (topological sorted order) difference sets as discovered
by this program:

    (k, v)      search trials   set...
    -----------------------------------------------------------------------------------------------
    (2, 3)                @0:   0,   1
    (3, 7)                @0:   0,   1,   3
    (4, 13)               @0:   0,   1,   3,   9
    (5, 21)              @81:   0,   1,   4,  14,  16
    (6, 31)              @75:   0,   1,   3,   8,  12,  18
    (8, 57)          @10,081:   0,   1,   3,  13,  32,  36,  43,  52
    (9, 73)           @1,145:   0,   1,   3,   7,  15,  31,  36,  54,  63
    (10, 91)         @71,618:   0,   1,   3,   9,  27,  49,  56,  61,  77,  81
    (12, 133)    @24,252,618:   0,   1,   3,  12,  20,  34,  38,  81,  88,  94, 104, 109
    (14, 183) @3,726,545,288:   0,   1,   3,  16,  23,  28,  42,  76,  82,  86, 119, 137, 154, 175
    (17, 273) @7,772,026,631:   0,   1,   3,   7,  15,  31,  63,  90, 116, 127, 136, 181, 194, 204,
                              233, 238, 255
    (18, 307)               :   0,   1,   3,  21,  25,  31,  68,  77,  91, 170, 177, 185, 196, 212,
                              225, 257, 269, 274

This program will search in parrallel using as many CPU cores as are available
on the current machine.

References:
http://en.wikipedia.org/wiki/Difference_set

La Jolla Difference Set Repository:
http://www.ccrwest.org/diffsets/diff_sets/baumert.html

The difference sets found by this program are represented by lambda == 1.

Copyright 2013, Mike Koss

*/
package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"math"
	"os"
	"os/signal"
	"runtime"
	"sort"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

const (
	minK             = 2
	maxK             = 103
	progressInterval = 1 * time.Second
)

func main() {
	var err error
	start := minK
	end := maxK
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

type workerConnection struct {
	id        int
	workQueue chan *diffSet
	results   chan *diffSet
	progress  chan *diffSet
	shutdown  chan bool
}

func newWorkerConnection(id int) *workerConnection {
	return &workerConnection{
		id:        id,
		workQueue: make(chan *diffSet, 1),
		results:   make(chan *diffSet),
		progress:  make(chan *diffSet, 1),
		shutdown:  make(chan bool, 1),
	}
}

func workManager(
	start, end int,
	prefix []int,
	requests chan workerConnection,
) {
	var wgManager sync.WaitGroup
	var wgWorkers sync.WaitGroup

	sets, pass := setGenerator(start, end, prefix)

	completedTrials := make([]int64, maxK)
	results := make(chan *diffSet)
	go func() {
		wgManager.Add(1)
		defer wgManager.Done()

		for result := range results {
			result.trials = completedTrials[result.k]
			fmt.Fprintln(os.Stdout, result)
		}
	}()

	type Progress struct {
		id int
		*diffSet
	}
	progressChannel := make(chan Progress)
	statistics := make([]*diffSet, runtime.NumCPU())
	var lastTrials int64
	var statMutex sync.Mutex
	go func() {
		for _ = range time.Tick(progressInterval) {
			statMutex.Lock()
			var sumTrials int64
			for i := 0; i < len(completedTrials); i++ {
				sumTrials += completedTrials[i]
			}
			for id := 0; id < len(statistics); id++ {
				ds := statistics[id]
				if ds != nil {
					fmt.Fprintf(os.Stderr, "%d: %s\n", id, ds)
					sumTrials += int64(ds.trials)
				}
			}
			fmt.Fprintf(os.Stderr, "Search rate: %s/sec (Total: %s)\n\n",
				commas(int(sumTrials-lastTrials)/int(progressInterval/time.Second)),
				commas(int(sumTrials)),
			)
			lastTrials = sumTrials
			statMutex.Unlock()
		}
	}()
	go func() {
		wgManager.Add(1)
		defer wgManager.Done()

		for p := range progressChannel {
			statMutex.Lock()
			statistics[p.id] = p.diffSet
			statMutex.Unlock()
		}
	}()

	var shuttingDown bool
	go func() {
		signals := make(chan os.Signal, 1)
		signal.Notify(signals, os.Interrupt)
		<-signals
		fmt.Fprintf(os.Stderr, "Shutting down ...\n")
		pass(maxK + 1)
		shuttingDown = true
		return
	}()

	var closer sync.Once
	for worker := range requests {
		// Process progress
		go func(worker workerConnection) {
			wgWorkers.Add(1)
			defer wgWorkers.Done()
			for ds := range worker.progress {
				progressChannel <- Progress{worker.id, ds}
				if shuttingDown {
					worker.shutdown <- true
				}
			}
		}(worker)

		// Process work
		go func(worker workerConnection) {
			wgWorkers.Add(1)
			defer wgWorkers.Done()

			kSolved := 0
			for ds := range sets {
				// Generator can have one excess set of the passed size
				if ds.k <= kSolved {
					continue
				}
				// workQueue has 1 buffer so no need to call async.
				worker.workQueue <- ds

				result := <-worker.results

				atomic.AddInt64(&completedTrials[result.k], int64(result.trials))
				statMutex.Lock()
				statistics[worker.id] = nil
				statMutex.Unlock()

				if result.IsSolved() {
					kSolved = result.k
					pass(kSolved)
					results <- result
				}
			}
			close(worker.workQueue)
			closer.Do(func() { close(requests) })
		}(worker)
	}
	wgWorkers.Wait()
	close(results)
	close(progressChannel)
	wgManager.Wait()
}

func setGenerator(start, end int, prefix []int) (<-chan *diffSet, func(int)) {
	var pass int
	sets := make(chan *diffSet)

	if len(prefix) < 2 || prefix[0] != 0 || prefix[1] != 1 {
		var buf bytes.Buffer
		WriteInts(&buf, prefix)
		panic(fmt.Sprintf("Invalid set prefix: %s\n", buf.String()))
	}
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
			if dsParent.targetDepth > k {
				dsParent.targetDepth = k
			}
			if dsParent.targetDepth < (k-4)/2 {
				dsParent.targetDepth = (k - 4) / 2
			}
			dsParent.Find(nil)
			for {
				if k <= pass {
					break
				}

				if dsParent.current != dsParent.targetDepth ||
					dsParent.s[1] != 1 {
					break
				}
				dsCopy := dsParent.copy()
				dsCopy.trials = 0
				dsCopy.start = time.Now()
				sets <- dsCopy
				if dsCopy.IsSolved() {
					break
				}
				dsParent.SearchNext(dsParent.pop()+1, nil)
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

	for ds := range conn.workQueue {
		// fmt.Fprintf(os.Stderr, "Working(%d): %s\n", id, ds)
		ds.Find(conn)
		// Signals completion of work, even if not solved.
		conn.results <- ds.copy()
	}
	close(conn.results)
	close(conn.progress)
}

type diffSet struct {
	k           int    // Number of elements in set
	v           int    // Modulus of differences (k * (k-1) + 1)
	trials      int64  // Number of trial so far
	targetDepth int    // Stop executing when current == targetDepth
	current     int    // s[0:current] is current search prefix
	low         int    // the largest i s.t. all diffs[i] == true
	s           []int  // Provisional difference set values
	diffs       []bool // Current differences covered by provisional set
	start       time.Time
}

func newDiffSet(k int, prefix []int) *diffSet {
	v := k*(k-1) + 1

	ds := diffSet{
		k:     k,
		v:     v,
		diffs: make([]bool, v/2+1),
		start: time.Now(),
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

func (ds *diffSet) copy() *diffSet {
	dsCopy := *ds
	dsCopy.s = make([]int, ds.k)
	copy(dsCopy.s, ds.s)
	dsCopy.diffs = make([]bool, ds.v/2+1)
	copy(dsCopy.diffs, ds.diffs)
	return &dsCopy
}

func (ds *diffSet) String() string {
	var buf bytes.Buffer
	ds.WriteTrace(&buf)
	return buf.String()
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
	fmt.Fprintf(w, " (low = %d, target = %d)%s", ds.low, ds.targetDepth, solvedString)
}

// Find the targetDepth or solution with prefix of current set.
func (ds *diffSet) Find(conn *workerConnection) {
	if ds.current <= 1 {
		panic(fmt.Sprintf("Illegal call to Find: %s", ds))
	}
	ds.SearchNext(ds.s[ds.current-1]+ds.low+1, conn)
}

func (ds *diffSet) SearchNext(candidate int, conn *workerConnection) {
	for {
		if ds.IsSolved() {
			return
		}

		ds.trials++
		if conn != nil && ds.trials%10000000 == 0 {
			conn.progress <- ds.copy()
			select {
			case <-conn.shutdown:
				return
			default:
			}
			runtime.Gosched()
		}

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
	/*
	   debugStatus := func() {
	       fmt.Fprintf(os.Stderr, "push(%d) -> %v\n", a, ok)
	   }
	   defer debugStatus()
	*/
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
		panic("pop error: " + ds.String())
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
		fmt.Fprintf(w, "%s%3d", sep, n)
		sep = ", "
	}
}

// commas converts integer to thousand-separated string
func commas(v interface{}) string {
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
