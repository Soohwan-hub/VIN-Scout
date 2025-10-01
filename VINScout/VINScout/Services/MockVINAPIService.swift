//
//  MockVINAPIService.swift
//  VINScout
//
//  Created by user283826 on 9/30/25.
//

import Foundation

class MockVINAPIService: VINAPIServiceProtocol {
    // Set this property to control the outcome of the fetch
    var result: Result<VehicleInfo, VINError>?

    func fetchVehicleInfo(for vin: String) async throws -> VehicleInfo {
        switch result {
        case .success(let vehicleInfo):
            return vehicleInfo
        case .failure(let error):
            throw error
        case .none:
            // Throw a default error if no result is set
            throw VINError.noDataFound
        }
    }
}
