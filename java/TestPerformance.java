import com.google.gson.*;
import java.io.FileReader;
import java.io.IOException;

public class TestPerformance {
    
    public static Integer getTTLArray(JsonObject root, String recordType) {
        JsonArray ttl0Data = root.getAsJsonArray("ttl0_data");
        if (ttl0Data == null) {
            return null;
        }
        
        for (JsonElement entryElement : ttl0Data) {
            JsonObject entry = entryElement.getAsJsonObject();
            JsonArray types = entry.getAsJsonArray("types");
            for (JsonElement typeElement : types) {
                String type = typeElement.getAsString();
                if (type.equals(recordType)) {
                    return entry.get("value").getAsInt();
                }
            }
        }
        return null;
    }
    
    public static Integer getTTLObject(JsonObject root, String recordType) {
        JsonObject ttl0Data = root.getAsJsonObject("ttl0_data");
        if (ttl0Data == null) {
            return null;
        }
        
        JsonObject recordData = ttl0Data.getAsJsonObject(recordType);
        if (recordData != null) {
            return recordData.get("value").getAsInt();
        }
        return null;
    }
    
    public static double benchmark(JsonObject data, String recordType, int iterations, boolean useArray) {
        long startTime = System.nanoTime();
        
        Integer result = null;
        for (int i = 0; i < iterations; i++) {
            if (useArray) {
                result = getTTLArray(data, recordType);
            } else {
                result = getTTLObject(data, recordType);
            }
        }
        
        long endTime = System.nanoTime();
        return (endTime - startTime) / 1_000_000.0; // Convert to milliseconds
    }
    
    public static void main(String[] args) {
        int iterations = 10_000_000;
        String recordType = "A";
        
        try {
            // Load array data
            Gson gson = new Gson();
            JsonObject arrayData = gson.fromJson(
                new FileReader("/data/array_data.json"), JsonObject.class);
            
            // Load object data
            JsonObject objectData = gson.fromJson(
                new FileReader("/data/object_data.json"), JsonObject.class);
            
            // Get results first
            Integer arrayResult = getTTLArray(arrayData, recordType);
            Integer objectResult = getTTLObject(objectData, recordType);
            
            // Benchmark array approach
            double arrayTime = benchmark(arrayData, recordType, iterations, true);
            
            // Benchmark object approach
            double objectTime = benchmark(objectData, recordType, iterations, false);
            
            // Results
            System.out.println("============================================================");
            System.out.println("JAVA PERFORMANCE TEST");
            System.out.println("============================================================");
            System.out.println("Record Type: " + recordType);
            System.out.println("Iterations: " + String.format("%,d", iterations));
            System.out.println("\nArray Approach:");
            System.out.println("  TTL Retrieved: " + arrayResult);
            System.out.println("  Total Time: " + String.format("%.2f ms", arrayTime));
            System.out.println("  Avg Time: " + String.format("%.4f µs/op", (arrayTime/iterations)*1000));
            
            System.out.println("\nObject Approach:");
            System.out.println("  TTL Retrieved: " + objectResult);
            System.out.println("  Total Time: " + String.format("%.2f ms", objectTime));
            System.out.println("  Avg Time: " + String.format("%.4f µs/op", (objectTime/iterations)*1000));
            
            double speedup = arrayTime / objectTime;
            System.out.println("\nSpeedup: " + String.format("%.2fx (object is %.2fx faster)", speedup, speedup));
            System.out.println("============================================================\n");
            
        } catch (IOException e) {
            System.err.println("Error reading files: " + e.getMessage());
            System.exit(1);
        }
    }
}
