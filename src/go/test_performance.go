package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"
)

// ArrayEntry represents an entry in the array-based structure
type ArrayEntry struct {
	Types []string `json:"types"`
	Value int      `json:"value"`
}

// ArrayData represents the array-based structure
type ArrayData struct {
	ObjectClassName string       `json:"objectClassName"`
	LdhName         string       `json:"ldhName"`
	TTL0Data        []ArrayEntry `json:"ttl0_data"`
}

// ObjectData represents the object-based structure
type ObjectData struct {
	ObjectClassName string                    `json:"objectClassName"`
	LdhName         string                    `json:"ldhName"`
	TTL0Data        map[string]map[string]int `json:"ttl0_data"`
}

func getTTLArray(data *ArrayData, recordType string) (int, bool) {
	for _, entry := range data.TTL0Data {
		for _, t := range entry.Types {
			if t == recordType {
				return entry.Value, true
			}
		}
	}
	return 0, false
}

func getTTLObject(data *ObjectData, recordType string) (int, bool) {
	if recordData, ok := data.TTL0Data[recordType]; ok {
		if value, ok := recordData["value"]; ok {
			return value, true
		}
	}
	return 0, false
}

func benchmarkArray(data *ArrayData, recordType string, iterations int) (time.Duration, int) {
	var result int
	start := time.Now()
	for i := 0; i < iterations; i++ {
		result, _ = getTTLArray(data, recordType)
	}
	elapsed := time.Since(start)
	return elapsed, result
}

func benchmarkObject(data *ObjectData, recordType string, iterations int) (time.Duration, int) {
	var result int
	start := time.Now()
	for i := 0; i < iterations; i++ {
		result, _ = getTTLObject(data, recordType)
	}
	elapsed := time.Since(start)
	return elapsed, result
}

func main() {
	iterations := 10000000
	recordType := "A"

	// Load array data
	arrayFile, err := os.ReadFile("/data/array_data.json")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading array_data.json: %v\n", err)
		os.Exit(1)
	}

	var arrayData ArrayData
	if err := json.Unmarshal(arrayFile, &arrayData); err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing array_data.json: %v\n", err)
		os.Exit(1)
	}

	// Load object data
	objectFile, err := os.ReadFile("/data/object_data.json")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading object_data.json: %v\n", err)
		os.Exit(1)
	}

	var objectData ObjectData
	if err := json.Unmarshal(objectFile, &objectData); err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing object_data.json: %v\n", err)
		os.Exit(1)
	}

	// Benchmark array approach
	arrayTime, arrayResult := benchmarkArray(&arrayData, recordType, iterations)

	// Benchmark object approach
	objectTime, objectResult := benchmarkObject(&objectData, recordType, iterations)

	// Convert to milliseconds
	arrayTimeMs := float64(arrayTime.Microseconds()) / 1000.0
	objectTimeMs := float64(objectTime.Microseconds()) / 1000.0

	// Results
	fmt.Println("============================================================")
	fmt.Println("GO PERFORMANCE TEST")
	fmt.Println("============================================================")
	fmt.Printf("Record Type: %s\n", recordType)
	fmt.Printf("Iterations: %d\n", iterations)
	fmt.Printf("\nArray Approach:\n")
	fmt.Printf("  TTL Retrieved: %d\n", arrayResult)
	fmt.Printf("  Total Time: %.2f ms\n", arrayTimeMs)
	fmt.Printf("  Avg Time: %.4f µs/op\n", arrayTimeMs/float64(iterations)*1000)

	fmt.Printf("\nObject Approach:\n")
	fmt.Printf("  TTL Retrieved: %d\n", objectResult)
	fmt.Printf("  Total Time: %.2f ms\n", objectTimeMs)
	fmt.Printf("  Avg Time: %.4f µs/op\n", objectTimeMs/float64(iterations)*1000)

	speedup := arrayTimeMs / objectTimeMs
	fmt.Printf("\nSpeedup: %.2fx (object is %.2fx faster)\n", speedup, speedup)
	fmt.Println("============================================================")
	fmt.Println()
}
