#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <json-c/json.h>

int get_ttl_array(struct json_object *root, const char *record_type) {
    struct json_object *ttl0_data;
    if (!json_object_object_get_ex(root, "ttl0_data", &ttl0_data)) {
        return -1;
    }
    
    int array_len = json_object_array_length(ttl0_data);
    for (int i = 0; i < array_len; i++) {
        struct json_object *entry = json_object_array_get_idx(ttl0_data, i);
        struct json_object *types;
        
        if (json_object_object_get_ex(entry, "types", &types)) {
            int types_len = json_object_array_length(types);
            for (int j = 0; j < types_len; j++) {
                struct json_object *type = json_object_array_get_idx(types, j);
                const char *type_str = json_object_get_string(type);
                
                if (strcmp(type_str, record_type) == 0) {
                    struct json_object *value;
                    if (json_object_object_get_ex(entry, "value", &value)) {
                        return json_object_get_int(value);
                    }
                }
            }
        }
    }
    return -1;
}

int get_ttl_object(struct json_object *root, const char *record_type) {
    struct json_object *ttl0_data;
    if (!json_object_object_get_ex(root, "ttl0_data", &ttl0_data)) {
        return -1;
    }
    
    struct json_object *record_data;
    if (json_object_object_get_ex(ttl0_data, record_type, &record_data)) {
        struct json_object *value;
        if (json_object_object_get_ex(record_data, "value", &value)) {
            return json_object_get_int(value);
        }
    }
    return -1;
}

double benchmark(struct json_object *data, int (*get_ttl_func)(struct json_object*, const char*), 
                const char *record_type, int iterations) {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    int result;
    for (int i = 0; i < iterations; i++) {
        result = get_ttl_func(data, record_type);
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    double elapsed = (end.tv_sec - start.tv_sec) * 1000.0 + 
                     (end.tv_nsec - start.tv_nsec) / 1000000.0;
    return elapsed;
}

int main() {
    const int iterations = 10000000;
    const char *record_type = "A";
    
    // Load array data
    struct json_object *array_data = json_object_from_file("/data/array_data.json");
    if (!array_data) {
        fprintf(stderr, "Failed to load array_data.json\n");
        return 1;
    }
    
    // Load object data
    struct json_object *object_data = json_object_from_file("/data/object_data.json");
    if (!object_data) {
        fprintf(stderr, "Failed to load object_data.json\n");
        json_object_put(array_data);
        return 1;
    }
    
    // Get results first
    int array_result = get_ttl_array(array_data, record_type);
    int object_result = get_ttl_object(object_data, record_type);
    
    // Benchmark array approach
    double array_time = benchmark(array_data, get_ttl_array, record_type, iterations);
    
    // Benchmark object approach
    double object_time = benchmark(object_data, get_ttl_object, record_type, iterations);
    
    // Results
    printf("============================================================\n");
    printf("C PERFORMANCE TEST\n");
    printf("============================================================\n");
    printf("Record Type: %s\n", record_type);
    printf("Iterations: %d\n", iterations);
    printf("\nArray Approach:\n");
    printf("  TTL Retrieved: %d\n", array_result);
    printf("  Total Time: %.2f ms\n", array_time);
    printf("  Avg Time: %.4f µs/op\n", (array_time/iterations)*1000);
    
    printf("\nObject Approach:\n");
    printf("  TTL Retrieved: %d\n", object_result);
    printf("  Total Time: %.2f ms\n", object_time);
    printf("  Avg Time: %.4f µs/op\n", (object_time/iterations)*1000);
    
    double speedup = array_time / object_time;
    printf("\nSpeedup: %.2fx (object is %.2fx faster)\n", speedup, speedup);
    printf("============================================================\n\n");
    
    json_object_put(array_data);
    json_object_put(object_data);
    
    return 0;
}
