// In Services/HistoryService.swift
import Foundation

class HistoryService {
    
    // A unique key to save and retrieve the data from UserDefaults.
    private let historyKey = "VINLookupHistory"

    func load() -> [VehicleInfo] {
        // Try to get the saved data for our key.
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        
        // If data exists, try to decode it from JSON into an array of VehicleInfo.
        let decoder = JSONDecoder()
        return (try? decoder.decode([VehicleInfo].self, from: data)) ?? []
    }
    func save(history: [VehicleInfo]) {
        // Keep only the 5 most recent lookups.
        let recentHistory = Array(history.prefix(5))
            
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(recentHistory) {
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        }
    }
    
    func save(vehicle: VehicleInfo) {
        var history = load()
        history.removeAll { $0.vin == vehicle.vin }
        history.insert(vehicle, at: 0)
        
        // Call the new general-purpose save function
        save(history: history)
    }
}
