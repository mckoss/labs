# Makefile for m94 cipher machine models.
# For fastest build on quad-proc, use:
#   make -j4

#
# M94 Cipher Device
#
NUMBERS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

WHEELS=$(foreach n, $(NUMBERS), m94-$(n).stl)
REPWHEELS=$(foreach n, $(NUMBERS), m94-$(n)-repl.stl)
M94_FILES=$(WHEELS) bar.stl m94-14-repl.stl all-wheels.zip multi-1.stl multi-2.stl

m94: $(M94_FILES)
m94r: $(REPWHEELS) bar.stl

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
# 3D Chrome Ball
#
SIZE=50
COLORS=red yellow green blue
HEMISPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE).stl)
SPHERES=$(foreach color, $(COLORS), chrome-$(color)-$(SIZE)s.stl)
CHROME_FILES=$(HEMISPHERES) $(SPHERES)

chrome: $(CHROME_FILES)

chrome-%-$(SIZE)s.stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'SPHERE_PORTION = 0.9' $<

chrome-%-$(SIZE).stl: chrome.scad
	openscad -o $@ -D 'OUTER = $(SIZE)' -D 'PART = "$*"' -D 'SPHERE_PORTION = 0.5' $<

#
# Wheelchair lock
#
CHAIR_PARTS=bracket piston receiver
CHAIR_FILES=$(foreach part, $(CHAIR_PARTS), chair-$(part).stl)

chair-lock: $(CHAIR_FILES)
	echo $(CHAIR_FILES)

chair-%.stl: chair-lock.scad
	openscad -o $@ -D 'PART = "$*"' $<

#
# GDG DevFest 2013 Chrome Ball
#
DEVFEST_FILES=$(foreach color, $(COLORS), devfest-$(color).stl)

devfest: $(DEVFEST_FILES)

devfest-%.stl: gdg-devfest.scad chrome.scad
	openscad -o $@ -D 'PART = "$*"' -D 'SPHERE_PORTION = 0.9' $<


#
# Chrome Summit 2013 Chrome Ball
#
SUMMIT_FILES=$(foreach color, $(COLORS), summit-$(color).stl)

summit: $(SUMMIT_FILES)

summit-%.stl: chrome-summit.scad chrome.scad
	openscad -o $@ -D 'PART = "$*"' -D 'SPHERE_PORTION = 0.9' $<


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

#
# Yes and No sculpture
# Inspired by Marcus Raetz
# http://www.maricazottino.com/blog/yesno-sculpture-by-markus-raetz/
#
YES_FILES=yes-and-no-build.stl yes-and-no-show.stl
yes-and-no: $(YES_FILES)

yes-and-no-%.stl: yes-and-no.scad
	openscad -o $@ -D 'PART = "$*"' $<

#
# 2014 Xmas Ornaments
#
XMAS_PARTS=ball tree onion ALL
XMAS_FILES=$(foreach part, $(XMAS_PARTS), xmas-2014-$(part).stl)
xmas-2014: $(XMAS_FILES)

xmas-2014-%.stl: xmas-2014.scad
	openscad -o $@ -D 'PART = "$*"' $<

#
# Platonic solids
#
PLATONIC_PARTS=cube tetrahedron octahedron dodecahedron icosahedron
PLATONIC_FILES=$(foreach part, $(PLATONIC_PARTS), platonic-$(part).stl)
platonic: $(PLATONIC_FILES)

platonic-%.stl: platonic.scad
	openscad -o $@ -D 'PART = "$*"' $<

#
# Cookie Cutters
#

COOKIES=club diamond heart spade bitcoin shuttle bug hawaii hula
LARGE_COOKIES=lily gabe hula
COOKIE_FILES=$(foreach cookie, $(COOKIES), cookie-$(cookie).stl) \
	$(foreach cookie, $(LARGE_COOKIES), cookie-$(cookie)-2x.stl)

cookies: $(COOKIE_FILES)

cookie-%.stl: cookie-cutter.scad %.dxf
	openscad -o $@ -D 'FILE = "$*.dxf"' $<

cookie-%-2x.stl: cookie-cutter.scad %.dxf
	openscad -o $@ -D 'FILE = "$*.dxf"' -D 'SCALE = 2' $<

# Generic file transformation rules
%.stl : %.scad
	openscad -o $@ $<

%.eps: %.svg
	inkscape -E $@ $<

%.dxf: %.eps
	pstoedit -dt -f "dxf:-polyaslines -mm" $< $@

clean:
	rm -f $(M94_FILES) $(CHROME_FILES) $(SHELF_FILES) $(YES_FILES)
