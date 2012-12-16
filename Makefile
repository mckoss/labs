CC=gcc
CFLAGS := -std=c99 -g -lm

all: difference

difference : difference.o
	$(CC) -o difference difference.o -lm

clean:
	rm -f difference *.o
