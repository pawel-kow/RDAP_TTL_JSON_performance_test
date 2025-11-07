# Quick Start Guide

## Get Started in 3 Steps

### 1. Navigate to the project directory
```bash
cd ttl-performance-test
```

### 2. Build and run all tests (easiest method)
```bash
./run_tests.sh
```

OR manually:

### 2a. Build the Docker image
```bash
docker build -t ttl-performance-test .
```

### 2b. Run all tests
```bash
docker run --rm ttl-performance-test
```

## What to Expect

The tests will run automatically in this order:
1. Python test (~1-2 seconds)
2. C test (~0.5-1 seconds)
3. Java test (~1-2 seconds)
4. Go test (~0.5-1 seconds)

Each test performs 1,000,000 TTL lookups and reports:
- Total execution time
- Average time per operation
- Speedup factor (object vs array approach)

## Sample Output

```
╔════════════════════════════════════════════════════════════╗
║  TTL Performance Test Suite: Array vs Object Approach     ║
║  Testing DNS Record Type: A                               ║
╚════════════════════════════════════════════════════════════╝

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
## Full Documentation

See [README.md](README.md) for complete documentation including:
- Detailed implementation notes
- Running individual tests
- Modifying test data
- Troubleshooting guide
