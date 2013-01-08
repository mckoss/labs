CC=gcc
CFLAGS := -std=c99 -g -O3

all: difference difference_ocl

difference_ocl : difference_ocl.o ocl_errors.o
	$(CC) -o difference_ocl difference_ocl.o ocl_errors.o -lc -framework OpenCL

difference : difference.o
	$(CC) -o difference difference.o -lm

clean:
	rm -f difference difference_ocl *.o
