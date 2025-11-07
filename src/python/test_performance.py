#!/usr/bin/env python3
import json
import time
import sys

def get_ttl_array(data, record_type):
    """Get TTL from array-based structure"""
    for entry in data['ttl0_data']:
        if record_type in entry['types']:
            return entry['value']
    return None

def get_ttl_object(data, record_type):
    """Get TTL from object-based structure"""
    record_data = data['ttl0_data'].get(record_type)
    if record_data:
        return record_data.get('value')
    return None

def benchmark(data, get_ttl_func, record_type, iterations):
    """Benchmark TTL retrieval"""
    start = time.perf_counter()
    for _ in range(iterations):
        result = get_ttl_func(data, record_type)
    end = time.perf_counter()
    return (end - start) * 1000, result  # Return time in milliseconds

def main():
    iterations = 10000000
    record_type = "A"
    
    # Load array data
    with open('/data/array_data.json', 'r') as f:
        array_data = json.load(f)
    
    # Load object data
    with open('/data/object_data.json', 'r') as f:
        object_data = json.load(f)
    
    # Benchmark array approach
    array_time, array_result = benchmark(array_data, get_ttl_array, record_type, iterations)
    
    # Benchmark object approach
    object_time, object_result = benchmark(object_data, get_ttl_object, record_type, iterations)
    
    # Results
    print("=" * 60)
    print("PYTHON PERFORMANCE TEST")
    print("=" * 60)
    print(f"Record Type: {record_type}")
    print(f"Iterations: {iterations:,}")
    print(f"\nArray Approach:")
    print(f"  TTL Retrieved: {array_result}")
    print(f"  Total Time: {array_time:.2f} ms")
    print(f"  Avg Time: {(array_time/iterations)*1000:.4f} µs/op")
    
    print(f"\nObject Approach:")
    print(f"  TTL Retrieved: {object_result}")
    print(f"  Total Time: {object_time:.2f} ms")
    print(f"  Avg Time: {(object_time/iterations)*1000:.4f} µs/op")
    
    speedup = array_time / object_time
    print(f"\nSpeedup: {speedup:.2f}x (object is {speedup:.2f}x faster)")
    print("=" * 60)
    print()

if __name__ == "__main__":
    main()
