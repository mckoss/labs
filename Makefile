CC=gcc
CFLAGS := -std=c99 -g
# CFLAGS := -std=c99 -g

difference: difference.o

clean:
	rm -f difference *.o
