// In Views/VINLookupView.swift
import SwiftUI

struct VINLookupView: View {
    @StateObject private var viewModel = VINViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                TextField("Enter 17-character VIN", text: $viewModel.vinText)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3.monospaced())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.vinText) {
                        // FIX: Updated syntax for .onChange
                        if viewModel.vinText.count > 17 {
                            viewModel.vinText = String(viewModel.vinText.prefix(17))
                        }
                    }
                
                Button("Look Up VIN") {
                    viewModel.lookupVIN()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || viewModel.vinText.count != 17)
                
                Spacer()
                
                // State Display Section
                if viewModel.isLoading {
                    ProgressView("Decoding VIN...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if let vehicle = viewModel.vehicle {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                            .font(.title)
                        Text("Trim: \(vehicle.trim ?? "N/A")")
                        Text("Body: \(vehicle.bodyType ?? "N/A")")
                        Text("Drive: \(vehicle.driveType ?? "N/A")")
                        Text("Engine: \(vehicle.engineInfo ?? "N/A")")
                    }
                } else {
                    Text("Enter a VIN to get started")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("VIN Scout")
        }
    }
}

#Preview {
    VINLookupView()
}
