#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ocl_errors.h"
#include <math.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

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
#define MAX_DEVICES 4

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

char *commas(int num, char *buff);
void insert_string(char *buff, char *s);

int main(int argc, char *argv[]) {
    int err;

    if (argc < 2) {
        printf("Usage: %s K [prefix, ...]\n", argv[0]);
        exit(1);
    }

    int k;
    sscanf(argv[1], "%d", &k);

    int prefix_buffer[40];
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

    cl_platform_id platform_ids[4];
    cl_uint num_platforms;
    char info_buffer[128];
    int info_num;
    size_t size;

#define print_platform_string(id, name) \
    OCLErr(clGetPlatformInfo, id, name, sizeof(info_buffer), (void *) info_buffer, &size); \
    printf(#name ": %s\n", info_buffer)

#define print_device_string(id, name) \
    OCLErr(clGetDeviceInfo, id, name, sizeof(info_buffer), (void *) info_buffer, &size); \
    printf(#name ": %s\n", info_buffer)

#define print_device_num(id, name) \
    OCLErr(clGetDeviceInfo, id, name, sizeof(int), &info_num, &size); \
    printf(#name ": %d\n", info_num);

    OCLErr(clGetPlatformIDs, 4, platform_ids, &num_platforms);
    for (int i = 0; i < num_platforms; i++) {
        print_platform_string(platform_ids[i], CL_PLATFORM_NAME);
    }

    // TODO: Support more than 1 device
    cl_device_id device_ids[MAX_DEVICES];
    cl_uint num_devices;
    OCLErr(clGetDeviceIDs, platform_ids[0], CL_DEVICE_TYPE_GPU,
           MAX_DEVICES, device_ids, &num_devices);
    for (int i = 0; i < num_devices; i++) {
        printf("Device --- %d ---\n", i);
        print_device_string(device_ids[i], CL_DEVICE_NAME);
        print_device_num(device_ids[i], CL_DEVICE_ADDRESS_BITS);
        print_device_num(device_ids[i], CL_DEVICE_ENDIAN_LITTLE);
        print_device_num(device_ids[i], CL_DEVICE_MAX_COMPUTE_UNITS);
        print_device_num(device_ids[i], CL_DEVICE_MAX_CLOCK_FREQUENCY);
    }

    cl_context context = OCLFunc(clCreateContext, 0, num_devices, device_ids, NULL, NULL);
    cl_command_queue commands = OCLFunc(clCreateCommandQueue, context, device_ids[num_devices - 1], 0);
    cl_program program = OCLFunc(clCreateProgramWithSource, context, 1, (const char **) & KernelSource, NULL);
    err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (err) {
        char buffer[4096];
        size_t len;
        printf("Failed to build program.");

        clGetProgramBuildInfo(program, device_ids[num_devices - 1], CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        exit(1);
    }

    size_t m = k * (k - 1) + 1;
    printf("Searching for difference set(k=%d, m=%zd)\n", k, m);

    cl_kernel kernel = OCLFunc(clCreateKernel, program, "kmain");

    size_t max_group_size;
    OCLErr(clGetKernelWorkGroupInfo, kernel, device_ids[num_devices - 1],
           CL_KERNEL_WORK_GROUP_SIZE, sizeof(max_group_size), &max_group_size, NULL);
    printf("Max workgroup size: %zu\n", max_group_size);

    size_t global[1];
    global[0] = max_group_size;

    cl_mem prefix = OCLFunc(clCreateBuffer, context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                            sizeof(int) * (prefix_size + 1), prefix_buffer);

    int counters_buffer[NUM_COUNTERS];
    cl_mem counters = OCLFunc(clCreateBuffer, context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                              sizeof(int) * NUM_COUNTERS, counters_buffer);

    int *output_buffer = calloc(k, sizeof(int));
    cl_mem output = OCLFunc(clCreateBuffer, context, CL_MEM_WRITE_ONLY | CL_MEM_COPY_HOST_PTR,
                            sizeof(int) * k, output_buffer);

    // kmain args
    int iarg = 0;
    KernelArg(k);
    KernelArg(prefix_size);
    KernelArg(prefix);
    KernelArg(counters);
    KernelArg(output);

    // command_queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size,
    // num_events_in_wait_list,event_wait_list, event
    OCLErr(clEnqueueNDRangeKernel, commands, kernel, 1, NULL, global, NULL, 0, NULL, NULL);
    OCLErr(clFinish, commands);

    OCLErr(clEnqueueReadBuffer, commands, output, CL_TRUE, 0,
           sizeof(int) * k, output_buffer, 0, NULL, NULL );

    for (int i = 0; i < k; i++) {
        printf("%d ", output_buffer[i]);
    }
    printf("\n");

    OCLErr(clEnqueueReadBuffer, commands, counters, CL_TRUE, 0,
           sizeof(int) * NUM_COUNTERS, counters_buffer, 0, NULL, NULL );

    for (int i = 0; i < NUM_COUNTERS; i++) {
        char num_buff[20];
        printf("%s: %s\n", counter_labels[i], commas(counters_buffer[i], num_buff));
    }

    clReleaseMemObject(output);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    return 0;
}

char *commas(int num, char *buff) {
    sprintf(buff, "%d", num);
    char *end = buff + strlen(buff) - 3;
    while (end > buff) {
        insert_string(end, ",");
        end -= 3;
    }
    return buff;
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
