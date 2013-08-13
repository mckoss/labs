# Makefile for m94 cipher machine models.
# use:
#   make -j4
# for faster execution since openscad is single threaded.

NUMBERS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

WHEELS=$(foreach n, $(NUMBERS), m94-$(n).stl)

m94: $(WHEELS) bar.stl m94-14-repl.stl all-wheels.zip multi-1.stl multi-2.stl

SIZE=50

COLORS=red yellow green blue
HEMISPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE).stl)
SPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE)s.stl)

chrome: $(HEMISPHERES) $(SPHERES)

clean:
	rm -f $(m94) $(chrome)

m94-%-repl.stl: m94.scad
	openscad -o $@ -D 'REPLICA = true' -D 'WHEEL = $*' $<

m94-%.stl: m94.scad
	openscad -o $@ -D 'WHEEL = $*' $<

bar.stl: m94.scad
	openscad -o $@ -D 'WHEEL = 0' $<

multi-%.stl: multi-print.scad $(WHEELS)
	openscad -o $@ -D 'GROUP = $*' $<

chrome-%-$(SIZE)s.stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'HEMISPHERE = false' $<

chrome-%-$(SIZE).stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'HEMISPHERE = true' $<

%.stl : %.scad
	openscad -o $@ $<

all-wheels.zip: $(WHEELS) bar.stl
	zip all-wheels $^
