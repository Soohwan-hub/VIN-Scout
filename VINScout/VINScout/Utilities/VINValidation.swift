//
//  VINValidation.swift
//  VINScout
//
//  Created by user283826 on 9/29/25.
//

import Foundation
struct VINValidator {
    static func validate(vin: String) throws {
        let formattedVIN = vin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard formattedVIN.count == 17 else {
            throw VINError.invalidLength
        }
        
        let illegalCharacters: Set<Character> = ["I", "O", "Q"]
        guard !formattedVIN.contains(where: { illegalCharacters.contains($0) }) else {
            throw VINError.containsIllegalCharacters
        }
        
        guard isCheckDigitValid(vin: formattedVIN) else {
            throw VINError.invalidCheckDigit
        }
    }
    
    private static func isCheckDigitValid(vin: String) -> Bool {
        let transliteration: [Character: Int] = [
            "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8,
            "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "P": 7, "R": 9,
            "S": 2, "T": 3, "U": 4, "V": 5, "W": 6, "X": 7, "Y": 8, "Z": 9,
            "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "0": 0
        ]
        let weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
         
        var sum = 0
        for (i, char) in vin.enumerated() {
            guard let value = transliteration[char] else { return false }
            sum += value * weights[i]
        }
         
        let remainder = sum % 11
        let checkDigitChar = vin[vin.index(vin.startIndex, offsetBy: 8)]
         
        if remainder == 10 {
            return checkDigitChar == "X"
        } else {
            return String(remainder) == String(checkDigitChar)
        }
    }
}
