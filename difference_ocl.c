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
        exit(1); \
    }

#define OCLFunc(clFunc, ...) \
    clFunc(__VA_ARGS__, &err); \
    CHECK_ERROR(clFunc)

#define OCLErr(clFunc, ...) \
    err = clFunc(__VA_ARGS__); \
    CHECK_ERROR(clFunc)

#define KernelArg(name) \
    OCLErr(clSetKernelArg, kernel, iarg++, sizeof(name), &name);

#define MAX_SOURCE 24000


int main(int argc, char *argv[]) {
    int err;
    cl_device_id device_id;

    if (argc != 2) {
        printf("Usage: %s <k>\n", argv[0]);
        exit(1);
    }

    int k;
    sscanf(argv[1], "%d", &k);

    printf("Size of int: %zd.\n", sizeof(int));

    FILE *fp;
    int cb;
    char *KernelSource;

    fp = fopen("difference.ocl", "r");
    if (!fp) {
        printf("Can't open file.");
        exit(1);
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
        char buffer[4096];
        size_t len;
        printf("Failed to build program.");

        clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        exit(1);
    }

    size_t m = k * (k - 1) + 1;
    printf("Searching for difference set(k=%d, m=%zd)\n", k, m);

    cl_kernel kernel = OCLFunc(clCreateKernel, program, "kmain");

    size_t max_group_size;
    OCLErr(clGetKernelWorkGroupInfo, kernel, device_id,
           CL_KERNEL_WORK_GROUP_SIZE, sizeof(max_group_size), &max_group_size, NULL);
    printf("Max workgroup size: %zu\n", max_group_size);

    size_t global[1];
    global[0] = m - 3;

    cl_mem prefix = OCLFunc(clCreateBuffer, context, CL_MEM_READ_ONLY, sizeof(int) * k, NULL);
    cl_mem counters = OCLFunc(clCreateBuffer, context, CL_MEM_READ_WRITE, sizeof(int), NULL);
    cl_mem status = OCLFunc(clCreateBuffer, context, CL_MEM_WRITE_ONLY, sizeof(int) * max_group_size, NULL);
    cl_mem output = OCLFunc(clCreateBuffer, context, CL_MEM_WRITE_ONLY, sizeof(int) * k, NULL);
    int prefix_size = 0;

    printf("1\n");

    // kmain args
    int iarg = 0;
    KernelArg(k);
    KernelArg(prefix_size);
    KernelArg(prefix);
    KernelArg(counters);
    KernelArg(status);
    KernelArg(output);

    printf("2\n");

    // Args:
    // command_queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size,
    // num_events_in_wait_list,event_wait_list, event
    OCLErr(clEnqueueNDRangeKernel, commands, kernel, 1, NULL, global, NULL, 0, NULL, NULL);
    clFinish(commands);

    printf("3\n");

    int *output_buffer = malloc(sizeof(int) * k);
    if (output_buffer == 0) {
        printf("Could not allocate output buffer.");
        exit(1);
    }
    OCLErr(clEnqueueReadBuffer, commands, output, CL_TRUE, 0, sizeof(int) * k, output_buffer, 0, NULL, NULL );

    int counters_buffer[1];
    OCLErr(clEnqueueReadBuffer, commands, counters, CL_TRUE, 0, sizeof(int), counters_buffer, 0, NULL, NULL );

    printf("Found %d solutions.\n", counters_buffer[0]);

    int *status_buffer = malloc(sizeof(int) * max_group_size);
    if (status_buffer == 0) {
        printf("Could not allocate status buffer.");
        exit(1);
    }
    OCLErr(clEnqueueReadBuffer, commands, status, CL_TRUE, 0, sizeof(int) * max_group_size,
           status_buffer, 0, NULL, NULL );

    for (int i = 0; i < k; i++) {
        printf("%d ", output_buffer[i]);
    }
    printf("\n");

    printf("Worker status:\n");
    for (int i = 0; i < max_group_size; i++) {
        if (i % 16 == 0) {
            printf("\n%04d: ", i);
        }
        printf("%5d ", status_buffer[i]);
    }
    printf("\n");

    clReleaseMemObject(output);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    return 0;
}
