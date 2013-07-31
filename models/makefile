# Makefile for m94 cipher machine models.
# use:
#   make -j4
# for faster execution since openscad is single threaded.

NUMBERS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

WHEELS=$(foreach n, $(NUMBERS), m94-$(n).stl)

EVERYTHING=$(WHEELS) bar.stl m94-14-repl.stl all-wheels.zip 4x4-1.stl 4x4-2.stl

all: $(EVERYTHING)

clean:
	rm -f $(EVERYTHING)

m94-%-repl.stl: m94.scad
	openscad -o $@ -D 'REPLICA = true' -D 'WHEEL = $*' m94.scad

m94-%.stl: m94.scad
	openscad -o $@ -D 'WHEEL = $*' m94.scad

bar.stl: m94.scad
	openscad -o $@ -D 'WHEEL = 0' m94.scad

4x4-1.stl: $(WHEELS) 4x4.scad
	openscad -o 4x4-1.stl -D 'START = 1' 4x4.scad

4x4-2.stl: $(WHEELS) 4x4.scad
	openscad -o 4x4-2.stl -D 'START = 17' 4x4.scad

all-wheels.zip: $(WHEELS) bar.stl
	zip all-wheels $^
