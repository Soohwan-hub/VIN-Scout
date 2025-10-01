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
    @Published var isShowingHistoryVehicle: Bool = false
    // properties the view will use
    
    private let apiService: VINAPIServiceProtocol
    private let historyService = HistoryService()
    
    init(apiService: VINAPIServiceProtocol = VINAPIService()) {
        self.apiService = apiService
        self.history = historyService.load()
    }
    
    //public methods
    func clearResults() {
        vehicle = nil
        errorMessage = nil
        isShowingHistoryVehicle = false
    }
    func deleteHistoryItem(vehicle: VehicleInfo) {
        history.removeAll { $0.id == vehicle.id }
        // Save the entire, updated array back to the service
        historyService.save(history: self.history)
        
    }
    func lookupVIN() async{
        isShowingHistoryVehicle = false
        isLoading = true
        errorMessage = nil
        vehicle = nil
        
        do {
            try VINValidator.validate(vin: vinText)
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Invalid VIN Format"
            self.isLoading = false
            return
        }
        
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
    func showHistoryVehicle(_ vehicleToShow: VehicleInfo) {
        self.vehicle = vehicleToShow
        self.vinText = vehicleToShow.vin
        self.isShowingHistoryVehicle = true
        self.errorMessage = nil
    }
}
