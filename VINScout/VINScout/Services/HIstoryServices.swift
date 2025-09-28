// In Services/HistoryService.swift
import Foundation

class HistoryService {
    
    // A unique key to save and retrieve the data from UserDefaults.
    private let historyKey = "VINLookupHistory"
    
    /// Loads the lookup history from UserDefaults.
    /// - Returns: An array of `VehicleInfo` objects, or an empty array if none is found.
    func load() -> [VehicleInfo] {
        // Try to get the saved data for our key.
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        
        // If data exists, try to decode it from JSON into an array of VehicleInfo.
        let decoder = JSONDecoder()
        return (try? decoder.decode([VehicleInfo].self, from: data)) ?? []
    }
    
    /// Saves a new vehicle to the history.
    /// - Parameter vehicle: The `VehicleInfo` object to save.
    func save(vehicle: VehicleInfo) {
        // First, load the current history.
        var history = load()
        
        // Remove any existing entry with the same ID (VIN) to avoid duplicates.
        // The new entry will be added to the top.
        history.removeAll { $0.id == vehicle.id }
        
        // Add the new vehicle to the beginning of the array.
        history.insert(vehicle, at: 0)
        
        // Keep only the 5 most recent lookups.
        let recentHistory = Array(history.prefix(5))
        
        // Encode the updated history array into JSON data and save it back to UserDefaults.
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(recentHistory) {
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        }
    }
}
