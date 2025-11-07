#!/bin/bash
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  TTL Performance Test Suite: Array vs Object Approach      ║"
echo "║  Testing DNS Record Type: A                                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
ls -l /data
echo "Running Python test..."
python3 /app/python/test_performance.py
echo ""
echo "Running C test..."
/app/c/test_performance
echo ""
echo "Running Java test..."
java -cp /opt/java/lib/gson-2.10.1.jar:/app/java TestPerformance
echo ""
echo "Running Go test..."
/app/go/test_performance
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  All tests completed!                                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
