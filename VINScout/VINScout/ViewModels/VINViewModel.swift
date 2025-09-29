//
//  VINViewModel.swift
//  VINScout
//
//  Created by user283826 on 9/28/25.
//

import SwiftUI

@MainActor
public class VINViewModel: ObservableObject {
    @Published var vinText: String = ""
    @Published var vehicle: VehicleInfo?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var history: [VehicleInfo] = []
    // properties the view will use
    
    private let apiService: VINAPIServiceProtocol
    private let historyService = HistoryService()
    
    init(apiService: VINAPIServiceProtocol = VINAPIService()) {
        self.apiService = apiService
        self.history = historyService.load()
    }
    
    //public methods
    func lookupVIN() {
        isLoading = true
        errorMessage = nil
        vehicle = nil
        
        Task {
            do {
                let fetchedVehicle = try await apiService.fetchVehicleInfo(for: vinText)
                self.vehicle = fetchedVehicle
                
                historyService.save(vehicle: fetchedVehicle)
                self.history = historyService.load()
            } catch {
                self.errorMessage = "Failed to fetch vehicle info \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
