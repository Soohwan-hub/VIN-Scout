// In Services/VINAPIService.swift

import Foundation

protocol VINAPIServiceProtocol {
    func fetchVehicleInfo(for vin: String) async throws -> VehicleInfo
}

class VINAPIService: VINAPIServiceProtocol {
    func fetchVehicleInfo(for vin: String) async throws -> VehicleInfo {
        try await Task.sleep(for: .seconds(1.5))
        
        // FIX: Added the missing 'make' property and fixed the 'bodyType' typo.
        return VehicleInfo(id: vin,
                           year: "2023",
                           make: "Tesla",
                           model: "Model Y",
                           trim: "Long Range",
                           bodyType: "SUV",
                           driveType: "AWD",
                           engineInfo: "Electric")
    }
}
