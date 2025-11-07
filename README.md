# TTL Performance Test Suite: Array vs Object Approach

This project provides a comprehensive performance comparison between two different JSON data structures for storing and retrieving DNS record TTL (Time To Live) information.

## Overview

The test suite compares two approaches for storing DNS TTL data:

### Array Approach
```json
{
  "ttl0_data": [
    {
      "types": ["A", "AAAA"],
      "value": 3600
    }
  ]
}
```

### Object Approach
```json
{
  "ttl0_data": {
    "A": { "value": 3600 },
    "AAAA": { "value": 3600 }
  }
}
```

## Test Methodology

Each implementation:
- Parses JSON data from test files
- Retrieves the TTL value for record type "A"
- Performs 1,000,000 iterations to measure performance
- Reports total time and average time per operation

## Supported Languages

- **Python** 3.x
- **C** (with json-c library)
- **Java** 11 (with Gson library)
- **Go** 1.21

## Project Structure

```
ttl-performance-test/
├── Dockerfile              # Container with all tools and compilers
├── README.md              # This file
├── data/
│   ├── array_data.json    # Array-based test data
│   └── object_data.json   # Object-based test data
├── python/
│   └── test_performance.py
├── c/
│   └── test_performance.c
├── java/
│   └── TestPerformance.java
└── go/
    └── test_performance.go
```

## Prerequisites

- Docker installed on your system
- At least 2GB of free disk space

## Building the Test Environment

Build the Docker image containing all necessary compilers and tools:

```bash
docker build -t ttl-performance-test .
```

This will:
- Install Python 3, GCC, OpenJDK 11, and Go 1.21
- Download required libraries (json-c, Gson)
- Compile all test programs
- Set up the test environment

## Running the Tests

Execute all performance tests:

```bash
docker run --rm ttl-performance-test
```

This single command will:
1. Run the Python test
2. Run the C test
3. Run the Java test
4. Run the Go test
5. Display all results in the console

## Understanding the Output

Each test outputs:
- **Record Type**: The DNS record type being tested (A)
- **Iterations**: Number of lookup operations (1,000,000)
- **TTL Retrieved**: The actual TTL value found
- **Total Time**: Complete execution time in milliseconds
- **Avg Time**: Average time per single operation in microseconds
- **Speedup**: How much faster the object approach is compared to array

Example output:
```
============================================================
PYTHON PERFORMANCE TEST
============================================================
Record Type: A
Iterations: 1,000,000

Array Approach:
  TTL Retrieved: 3600
  Total Time: 234.56 ms
  Avg Time: 0.2346 µs/op

Object Approach:
  TTL Retrieved: 3600
  Total Time: 45.78 ms
  Avg Time: 0.0458 µs/op

Speedup: 5.12x (object is 5.12x faster)
============================================================
```

## Running Individual Tests

To run a specific language test:

### Python
```bash
docker run --rm ttl-performance-test python3 /app/python/test_performance.py
```

### C
```bash
docker run --rm ttl-performance-test /app/c/test_performance
```

### Java
```bash
docker run --rm ttl-performance-test \
  java -cp /opt/java/lib/gson-2.10.1.jar:/app/java TestPerformance
```

### Go
```bash
docker run --rm ttl-performance-test /app/go/test_performance
```

## Modifying Test Data

To test with different data:

1. Edit `data/array_data.json` or `data/object_data.json`
2. Rebuild the Docker image
3. Run the tests again

You can add more record types (e.g., MX, TXT, CNAME) to test the scalability of both approaches.

## Implementation Details

### Array Approach
- **Pros**: Flexible grouping of records with same TTL
- **Cons**: Requires iteration through array to find specific record type
- **Complexity**: O(n) where n is the number of entries

### Object Approach
- **Pros**: Direct hash/map lookup by record type
- **Cons**: More verbose JSON, duplicate TTL values
- **Complexity**: O(1) average case for hash table lookup

## Expected Results

Generally, the **object approach is significantly faster** (typically 3-10x) because:
1. Direct key-based lookup vs. sequential search
2. Hash table/dictionary access is O(1) vs. O(n) for arrays
3. No need to iterate through types array for each entry

The performance difference becomes more pronounced as:
- The number of RR types increases
- The target record type appears later in the array
- More iterations are performed

## Troubleshooting

### Build fails with "cannot download Go"
- Check your internet connection
- Try using a Docker mirror closer to your location

### Java compilation error
- Ensure the Gson library downloaded correctly
- Check the Java version (should be 11+)

### C compilation error
- Verify json-c library is installed
- Check gcc version (should support C11)

## Performance Considerations

The test results depend on:
- CPU performance
- Available system memory
- Docker resource allocation
- JSON parsing library efficiency

For production use, consider:
- Caching parsed data structures
- Using binary formats for high-performance scenarios
- Implementing appropriate data structures for your specific access patterns

## License

This test suite is provided as-is for educational and benchmarking purposes.

## Contributing

To add support for additional languages:
1. Create a new directory for the language
2. Implement the two lookup functions
3. Add benchmarking with 1,000,000 iterations
4. Update the Dockerfile to include compilation/setup
5. Update the entrypoint script to run the new test
