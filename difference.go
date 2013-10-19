/* ================================================================
   difference.c - Difference Set generator.

   Calculate difference sets of various sizes - using threading library
   to maximize CPU cores in the search.

   This program implements exhaustive search and ensures finding the
   difference set with smallest topological value.

   Copyright 2013, Mike Koss

   Todo:

   - Option to continue search from a pause point (not a required prefix)
   - Option to return all solutions (not just first found).
`================================================================== */
package main

import (
	"flag"
	"fmt"
	"strconv"
	"os"
)

const (
	minK = 2
	maxK = 103
)

func main() {
	var err error;
	var	start int = 2
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
			fmt.Printf("'%s' is not a valid start number.\n", flag.Arg(0))
			usage()
		}
	}
	if flag.NArg() >= 2 {

	}
	fmt.Printf("Searching for difference sets between %d and %d elements.\n", start, end)
	/*
	       parser.add_argument("--start", default=3, type=int,
	                       help="Starting point for size (k) of difference set search.")
	   parser.add_argument("--end", default=103, type=int,
	                       help="Ending point for size of difference set search.")
	   parser.add_argument("--all", action="store_true",
	                       help="Find all difference sets (does not stop a first solution.")
	   parser.add_argument("prefix", default=[0, 1], type=int, nargs='*',
	                       help="Search all solutions that have given prefix.")
	   args = parser.parse_args()
	*/
}

func usage() {
    fmt.Fprintf(os.Stderr, "Usage: difference [k-start] [k-end]]\n");
    fmt.Fprintf(os.Stderr, "       difference [-c] [k] [prefix1 prefix 2 ...]\n");
    fmt.Fprintf(os.Stderr, "Find difference sets of order k.\n\n");
    flag.PrintDefaults()
	os.Exit(1)
}
