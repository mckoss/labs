# Makefile for m94 cipher machine models.
# For fastest build on quad-proc, use:
#   make -j4

#
# M94 Cipher Device
#
NUMBERS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

WHEELS=$(foreach n, $(NUMBERS), m94-$(n).stl)
M94_FILES=$(WHEELS) bar.stl m94-14-repl.stl all-wheels.zip multi-1.stl multi-2.stl

m94: $(M94_FILES)

m94-%-repl.stl: m94.scad
	openscad -o $@ -D 'REPLICA = true' -D 'WHEEL = $*' $<

m94-%.stl: m94.scad
	openscad -o $@ -D 'WHEEL = $*' $<

bar.stl: m94.scad
	openscad -o $@ -D 'WHEEL = 0' $<

multi-%.stl: multi-print.scad $(WHEELS)
	openscad -o $@ -D 'GROUP = $*' $<

all-wheels.zip: $(WHEELS) bar.stl
	zip all-wheels $^


#
# 3D Chrome Logo
#
SIZE=50
COLORS=red yellow green blue
HEMISPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE).stl)
SPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE)s.stl)
CHROME_FILES=$(HEMISPHERES) $(SPHERES)

chrome: $(CHROME_FILES)

chrome-%-$(SIZE)s.stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'HEMISPHERE = false' $<

chrome-%-$(SIZE).stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'HEMISPHERE = true' $<


#
# Filament Shelf Parts
#
SHELF_FILES=spool-shelf-1.stl spool-shelf-2.stl spool-shelf-3.stl spool-post.stl spool-post-mirror.stl \
            spool-test-shelf.stl

shelf: $(SHELF_FILES)

spool-shelf-%.stl: spool-shelf.scad
	openscad -o $@ -D 'PART = "shelf"' -D 'SPOOLS = $*' $<

spool-%.stl: spool-shelf.scad
	openscad -o $@ -D 'PART = "$*"' $<


# Generic stl file builder
%.stl : %.scad
	openscad -o $@ $<

clean:
	rm -f $(M94_FILES) $(CHROME_FILES) $(SHELF_FILES)
