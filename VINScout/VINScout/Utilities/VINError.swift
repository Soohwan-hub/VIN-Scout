//
//  VINError.swift
//  VINScout
//
//  Created by user283826 on 9/29/25.
//

import Foundation
// A single, comprehensive error enum for all VIN-related failures.
enum VINError: Error, LocalizedError {
    // Validation Errors
    case invalidLength
    case containsIllegalCharacters
    case invalidCheckDigit
    
    // Network Errors
    case badURL
    case networkError(Error)
    case noDataFound // Specific for when the API finds no vehicle for a valid VIN
    case noCoreDataFound
    
    // Decoding Error
    case decodingError(Error)
    
    // This computed property provides user-friendly messages for each case.
    var errorDescription: String? {
        switch self {
        case .invalidCheckDigit:
            return "The VIN is invalid according to its check digit feature (ISO 3779)"
        case .invalidLength:
            return "A VIN must be exactly 17 characters long."
        case .containsIllegalCharacters:
            return "A VIN cannot contain the letters I, O, or Q."
        case .badURL:
            return "Could not construct a valid URL for the API request."
        case .networkError:
            return "A network error occurred. Please check your connection and try again."
        case .noDataFound:
            return "No vehicle information was found for this VIN."
        case .noCoreDataFound:
            return "No information was found for the model, make, or the year it was made."
        case .decodingError:
            return "Failed to process the data received from the server."
        }
    }
}
