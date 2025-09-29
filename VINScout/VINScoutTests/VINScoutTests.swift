//
//  VINScoutTests.swift
//  VINScoutTests
//
//  Created by user283826 on 9/28/25.
//

import XCTest
@testable import VINScout

final class VINScoutTests: XCTestCase {
    
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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
