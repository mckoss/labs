CC=gcc
CFLAGS := -std=c99 -g -O3 -I/opt/AMD-APP-SDK-v2.7-RC-lnx64/include/CL/ -pthread -D_BSD_SOURCE

all: difference difference_ocl

difference : difference.o
	$(CC) -o difference difference.o -lm -pthread

difference_ocl : difference_ocl.o ocl_errors.o
	$(CC) -o difference_ocl difference_ocl.o ocl_errors.o -lc -lOpenCL

difference_go: difference.go
	go build -o difference_go difference.go

clean:
	rm -f difference difference_ocl difference_go *.o
