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

// Global Counters
#define NUM_COUNTERS 20
#define SOLVED 0

const char *counter_labels[NUM_COUNTERS] = {
    "Solutions",
    "Solution steps",
    "Workers",
    "Global Steps",
    "k > MAX_SET",
    "Prefix Invalid",
    "Static choice invalid",
    "Exhausted search",
    "Hit max search limit",
    "Pruned",
    "Data"
};

void commas(int num, char *buff);
void insert_string(char *buff, char *s);

int main(int argc, char *argv[]) {
    int err;
    cl_device_id device_id;

    if (argc < 2) {
        printf("Usage: %s K [prefix, ...]\n", argv[0]);
        exit(1);
    }

    int k;
    sscanf(argv[1], "%d", &k);

    int prefix_buffer[20];
    for (int i = 2; i < argc; i++) {
        sscanf(argv[i], "%d", &prefix_buffer[i-2]);
    }
    int prefix_size = argc - 2;

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
    global[0] = 512 * 100;

    cl_mem prefix = OCLFunc(clCreateBuffer, context, CL_MEM_READ_ONLY, sizeof(int) * k, NULL);
    cl_mem counters = OCLFunc(clCreateBuffer, context, CL_MEM_READ_WRITE, sizeof(int) * NUM_COUNTERS, NULL);
    cl_mem output = OCLFunc(clCreateBuffer, context, CL_MEM_WRITE_ONLY, sizeof(int) * k, NULL);

    if (prefix_size > 0) {
        OCLErr(clEnqueueWriteBuffer, commands, prefix, CL_TRUE, 0,
               sizeof(int) * prefix_size, prefix_buffer, 0, NULL, NULL);
    }

    // kmain args
    int iarg = 0;
    KernelArg(k);
    KernelArg(prefix_size);
    KernelArg(prefix);
    KernelArg(counters);
    KernelArg(output);

    // Args:
    // command_queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size,
    // num_events_in_wait_list,event_wait_list, event
    OCLErr(clEnqueueNDRangeKernel, commands, kernel, 1, NULL, global, NULL, 0, NULL, NULL);
    clFinish(commands);

    int *output_buffer = malloc(sizeof(int) * k);
    if (output_buffer == 0) {
        printf("Could not allocate output buffer.");
        exit(1);
    }
    OCLErr(clEnqueueReadBuffer, commands, output, CL_TRUE, 0,
           sizeof(int) * k, output_buffer, 0, NULL, NULL );

    for (int i = 0; i < k; i++) {
        printf("%d ", output_buffer[i]);
    }
    printf("\n");

    int counters_buffer[NUM_COUNTERS];
    OCLErr(clEnqueueReadBuffer, commands, counters, CL_TRUE, 0,
           sizeof(int) * NUM_COUNTERS, counters_buffer, 0, NULL, NULL );

    for (int i = 0; i < NUM_COUNTERS; i++) {
        char num_buff[20];
        commas(counters_buffer[i], num_buff);
        printf("%s: %s\n", counter_labels[i], num_buff);
    }

    clReleaseMemObject(output);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    return 0;
}

void commas(int num, char *buff) {
    sprintf(buff, "%d", num);
    char *end = buff + strlen(buff) - 3;
    while (end > buff) {
        insert_string(end, ",");
        end -= 3;
    }
}

void insert_string(char *buff, char *s) {
    int cch = strlen(s);

    char *pchFrom = buff + strlen(buff);
    char *pchTo = pchFrom + cch;
    while (pchFrom >= buff) {
        *pchTo-- = *pchFrom--;
    }
    pchFrom = s + cch - 1;
    while (pchTo >= buff) {
        *pchTo-- = *pchFrom--;
    }
}
