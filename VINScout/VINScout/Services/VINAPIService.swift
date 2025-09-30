// In Services/VINAPIService.swift

import Foundation
//codable structs for api response
struct NHTSAResponse: Codable {
    let Results: [NHSTADetail]
}

struct NHSTADetail: Codable {
    let Variable: String?
    let Value: String?
}

protocol VINAPIServiceProtocol {
    func fetchVehicleInfo(for vin: String) async throws -> VehicleInfo
}

class VINAPIService: VINAPIServiceProtocol {
    //returns a vehicleInfo object to store and display
    //throws errors according to the fetching fails
    func fetchVehicleInfo(for vin: String) async throws -> VehicleInfo {
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/\(vin)?format=json"
        guard let url = URL(string: urlString) else {
            throw VINError.badURL
        }
        
        let (data, _): (Data, URLResponse)
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw VINError.networkError(error)
        }
        
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(NHTSAResponse.self, from: data)
            guard !apiResponse.Results.isEmpty else {
                throw VINError.noDataFound
            }
            
            let detailsDictionary = Dictionary(uniqueKeysWithValues: apiResponse.Results.compactMap { detail -> (String, String)? in
                guard let key = detail.Variable, let value = detail.Value, !value.isEmpty else { return nil }
                return (key.trimmingCharacters(in: .whitespaces), value)
            })
            
            guard let year = detailsDictionary["Model Year"],
                  let make = detailsDictionary["Make"],
                  let model = detailsDictionary["Model"] else {
                throw VINError.noCoreDataFound
            }
            
            return VehicleInfo(
                vin: vin,
                year: year,
                make: make,
                model: model,
                // You can expand this mapping to pull more details from the dictionary
                trim: detailsDictionary["Trim"],
                bodyType: detailsDictionary["Body Class"],
                driveType: detailsDictionary["Drive Type"],
                engineInfo: detailsDictionary["Engine Model"],
                
                //test for dropdown feature
                fuelTypePrimary: detailsDictionary["Fuel Type - Primary"],
                engineCylinders: detailsDictionary["Engine Cylinders"],
                displacementL: detailsDictionary["Displacement (L)"],
                transmissionStyle: detailsDictionary["Transmission Style"]
            )
            
        } catch {
            throw VINError.decodingError(error)
        }
    }
}
