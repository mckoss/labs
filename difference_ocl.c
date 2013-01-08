#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ocl_errors.h"
#include <math.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <OpenCL/opencl.h>

#define CHECK_ERROR(clFunc) \
    if (err) { \
        printf("%s error '%s' (%d)\n", #clFunc, get_opencl_error(err), err); \
        return EXIT_FAILURE; \
    }

#define OCLFunc(clFunc, ...) \
    clFunc(__VA_ARGS__, &err); \
    CHECK_ERROR(clFunc)

#define OCLErr(clFunc, ...) \
    err = clFunc(__VA_ARGS__); \
    CHECK_ERROR(clFunc)

#define MAX_SOURCE 24000


int main(int argc, char *argv[]) {
    int err;
    cl_device_id device_id;

    if (argc != 2) {
        printf("Usage: %s <k>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int k;
    sscanf(argv[1], "%d", &k);

    int results_size = sizeof(int) * k;
    int *results = malloc(results_size);

    FILE *fp;
    int cb;
    char *KernelSource;

    fp = fopen("difference.ocl", "r");
    if (!fp) {
        printf("Can't open file.");
        return EXIT_FAILURE;
    }
    KernelSource = (char *) malloc(MAX_SOURCE);
    cb = fread(KernelSource, 1, MAX_SOURCE, fp);
    KernelSource[cb] = 0;
    fclose(fp);

    OCLErr(clGetDeviceIDs, NULL, CL_DEVICE_TYPE_GPU, 1, &device_id, NULL);
    cl_context context = OCLFunc(clCreateContext, 0, 1, &device_id, NULL, NULL);
    cl_command_queue commands = OCLFunc(clCreateCommandQueue, context, device_id, 0);
    cl_program program = OCLFunc(clCreateProgramWithSource, context, 1, (const char **) & KernelSource, NULL);
    err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (err) {
        char buffer[2048];
        size_t len;
        printf("Failed to build program.");

        clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        return EXIT_FAILURE;
    }

    cl_kernel kernel = OCLFunc(clCreateKernel, program, "kmain");
    cl_mem output = OCLFunc(clCreateBuffer, context, CL_MEM_WRITE_ONLY, results_size, NULL);

    OCLErr(clSetKernelArg, kernel, 0, sizeof(k), &k);
    OCLErr(clSetKernelArg, kernel, 1, sizeof(cl_mem), &output);

    size_t local;
    OCLErr(clGetKernelWorkGroupInfo, kernel, device_id, CL_KERNEL_WORK_GROUP_SIZE, sizeof(local), &local, NULL);

    printf("Local workgroup size: %zu\n", local);

    printf("Searching of k=%d, m=%d\n", k, k * (k - 1) + 1);

    OCLErr(clEnqueueNDRangeKernel, commands, kernel, 1, NULL, &local, &local, 0, NULL, NULL);
    clFinish(commands);

    OCLErr(clEnqueueReadBuffer, commands, output, CL_TRUE, 0, results_size, results, 0, NULL, NULL );

    for (int i = 0; i < k; i++) {
        printf("%d ", results[i]);
    }
    printf("\n");

    clReleaseMemObject(output);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    return 0;
}
