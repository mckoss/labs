CC=gcc
CFLAGS := -std=c99

difference: difference.o

clean:
	rm -f difference *.o
