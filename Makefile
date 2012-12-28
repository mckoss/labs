CC=gcc
CFLAGS := -std=c99 -O3

all: difference difference_ocl

difference_ocl : difference_ocl.o
	$(CC) -o difference_ocl difference_ocl.o -lc -framework OpenCL

difference : difference.o
	$(CC) -o difference difference.o -lm

clean:
	rm -f difference difference_ocl *.o
