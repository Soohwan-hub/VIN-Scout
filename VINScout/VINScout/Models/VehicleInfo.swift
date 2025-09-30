//
//  VehicleInfo.swift
//  VINScout
//
//  Created by user283826 on 9/28/25.
//

import Foundation

struct VehicleInfo: Codable, Identifiable {
    
    var id: String { vin }
    
    let vin: String
    let year: String
    let make: String
    let model: String
    let trim: String?
    let bodyType: String?
    let driveType: String?
    let engineInfo: String?
    
    //test for dropdown feature
    let fuelTypePrimary: String?
    let engineCylinders: String?
    let displacementL: String?
    let transmissionStyle: String?
}
