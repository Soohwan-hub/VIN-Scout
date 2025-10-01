//
//  VINScoutTests.swift
//  VINScoutTests
//
//  Created by user283826 on 9/28/25.
//

import XCTest
@testable import VINScout

@MainActor
final class VINScoutTests: XCTestCase {
    var viewModel: VINViewModel!
    var mockAPIService: MockVINAPIService!
    
    func test_validVIN_shouldPassValidation() {
        // A known valid VIN for a 2019 Audi A4
        let validVIN = "WAUUPBFF2K1000000"
            
        // XCTAssertNoThrow will pass if the function doesn't throw an error.
        XCTAssertNoThrow(try VINValidator.validate(vin: validVIN), "A valid VIN should not throw an error.")
    }

    func test_invalidCheckDigitVIN_shouldThrowError() {
        // Same VIN as above, but the check digit 'P' (9th char) is changed to 'A'.
        let invalidVIN = "WAUUPBFF_A_K1000000"
            
        // XCTAssertThrowsError will pass if the function throws the specific error we expect.
        XCTAssertThrowsError(try VINValidator.validate(vin: invalidVIN)) { error in
            XCTAssertEqual(error as? VINError, .invalidCheckDigit, "An invalid VIN should throw the invalidCheckDigit error.")
        }
    }
    func test_additionalValidVINs_fromRealWorldCases_shouldPassValidation() {
         // These are the VINs that were previously failing due to the incomplete map.
         let realWorldVINs = [
             "WVWMA63B1XE042415",
             "JKAEXVD129A115072",
             "JA32U8FW6AU023413"
         ]
         
         // We loop through each VIN and assert that it passes validation without throwing an error.
         for vin in realWorldVINs {
             XCTAssertNoThrow(try VINValidator.validate(vin: vin), "VIN \(vin) should be valid but it failed validation.")
         }
     }

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAPIService = MockVINAPIService()
        // NOTE: This requires your VINViewModel to have an initializer that accepts an apiService
        // for dependency injection. Example: init(apiService: VINAPIServiceProtocol = VINAPIService())
        viewModel = VINViewModel(apiService: mockAPIService)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        try super.tearDownWithError()
    }
    
    @MainActor
    func testLookupVIN_Success() async {
        let mockVehicle = VehicleInfo(
            vin: "123",
            year: "2025",
            make: "TestMake",
            model: "TestModel",
            trim: nil,
            bodyType: nil,
            driveType: nil,
            engineInfo: nil,
            fuelTypePrimary: nil,
            engineCylinders: nil,
            displacementL: nil,
            transmissionStyle: nil
        )
        mockAPIService.result = .success(mockVehicle)
        viewModel.vinText = "123456789ABCDEFGH"
        
        // Act
        await viewModel.lookupVIN()
        
        // Assert
        XCTAssertNotNil(viewModel.vehicle)
        XCTAssertEqual(viewModel.vehicle?.make, "TestMake")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.history.contains(where: { $0.vin == "123" }))
    }

    @MainActor
    func testLookupVIN_Failure() async {
        // Arrange
        mockAPIService.result = .failure(VINScout.VINError.badURL)
        viewModel.vinText = "INVALIDVIN"
        
        await viewModel.lookupVIN()
        
        // Assert
        XCTAssertNil(viewModel.vehicle)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    @MainActor
    func testClearResults() {
        viewModel.vehicle = VehicleInfo(
            vin: "123",
            year: "2025",
            make: "TestMake",
            model: "TestModel",
            trim: nil,
            bodyType: nil,
            driveType: nil,
            engineInfo: nil,
            fuelTypePrimary: nil,
            engineCylinders: nil,
            displacementL: nil,
            transmissionStyle: nil
        )
        viewModel.errorMessage = "An old error"
        
        // Act
        viewModel.clearResults()
        
        // Assert
        XCTAssertNil(viewModel.vehicle)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testDeleteHistoryItem() {
        let vehicle1 = VehicleInfo(
            vin: "VIN1",
            year: "2020",
            make: "MakeA",
            model: "ModelA",
            trim: nil,
            bodyType: nil,
            driveType: nil,
            engineInfo: nil,
            fuelTypePrimary: nil,
            engineCylinders: nil,
            displacementL: nil,
            transmissionStyle: nil
        )
        let vehicle2 = VehicleInfo(
            vin: "VIN2",
            year: "2021",
            make: "MakeB",
            model: "ModelB",
            trim: nil,
            bodyType: nil,
            driveType: nil,
            engineInfo: nil,
            fuelTypePrimary: nil,
            engineCylinders: nil,
            displacementL: nil,
            transmissionStyle: nil
        )
        viewModel.history = [vehicle1, vehicle2]
        
        // Act
        viewModel.deleteHistoryItem(vehicle: vehicle1)
        
        // Assert
        XCTAssertEqual(viewModel.history.count, 1)
        XCTAssertFalse(viewModel.history.contains(where: { $0.vin == "VIN1" }))
        XCTAssertTrue(viewModel.history.contains(where: { $0.vin == "VIN2" }))
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
extension VINError: Equatable {
    public static func == (lhs: VINError, rhs: VINError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidLength, .invalidLength),
             (.containsIllegalCharacters, .containsIllegalCharacters),
             (.invalidCheckDigit, .invalidCheckDigit),
             (.badURL, .badURL),
             (.noDataFound, .noDataFound):
            return true
        // We can't compare the associated values for network/decoding errors,
        // so we just return false if they are compared to anything else.
        default:
            return false
        }
    }
}
