import SwiftUI

// Main view for the VIN Lookup feature - Clean & Minimalist Style
struct VINLookupView: View {
    @StateObject private var viewModel = VINViewModel()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Use a subtle, off-white background for a softer look
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        inputSection
                        resultsSection
                        historySection
                        Spacer()
                    }
                    .padding()
                    .padding(.top, 20)
                }
            }
            .navigationTitle("VIN Scout")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Vehicle Lookup")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text("Enter a 17-character VIN to decode vehicle information.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            // A cleaner text field with a clear button
            HStack {
                TextField("Enter VIN", text: $viewModel.vinText)
                    .font(.title3.monospaced())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .focused($isTextFieldFocused)
                    .onChange(of: viewModel.vinText) { _, newValue in
                        if newValue.count > 17 {
                            viewModel.vinText = String(viewModel.vinText.prefix(17))
                        }
                        if newValue.count < 17 {
                            viewModel.clearResults()
                        }
                    }
                
                Button(action: {
                    // Access the pasteboard and set the text
                    if let pastedText = UIPasteboard.general.string {
                        let sanitizedVIN = pastedText.filter { $0.isLetter || $0.isNumber }.uppercased()
                                
                        viewModel.vinText = sanitizedVIN
                    }
                })  {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .padding(.trailing, 8)
                
                // Show a clear button only when the text field is not empty
                if !viewModel.vinText.isEmpty {
                    Button(action: { viewModel.vinText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTextFieldFocused ? .accentColor : Color.gray.opacity(0.3), lineWidth: 1.5)
            )

            Button(action: {
                isTextFieldFocused = false
                Task {
                    await viewModel.lookupVIN()
                }
            }) {
                Text("Look Up VIN")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .cornerRadius(12)
            .disabled(viewModel.isLoading || viewModel.vinText.count != 17)
        }
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        if viewModel.isLoading {
            ProgressView()
                .controlSize(.large)
                .padding(.top, 40)
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if let vehicle = viewModel.vehicle {
            VehicleDetailCard(
                vehicle: vehicle,
                isFromHistory: viewModel.isShowingHistoryVehicle,
                onRefresh: {
                    Task {
                        await viewModel.lookupVIN()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var historySection: some View {
        if !viewModel.history.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Lookups")
                    .font(.title3.bold())
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.history) { vehicle in
                            VStack(alignment: .leading) {
                                Text(vehicle.vin)
                                    .font(.headline.monospaced())
                                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .onTapGesture {
                                viewModel.showHistoryVehicle(vehicle)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteHistoryItem(vehicle: vehicle)
                                } label: {
                                    Label("Delete", systemImage: "remove")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
        }
    }

    private func errorView(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

struct VehicleDetailCard: View {
    let vehicle: VehicleInfo
    let isFromHistory: Bool
    let onRefresh: () -> Void

    @State private var showMoreDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                        .font(.title2.bold())
                    Text(vehicle.vin)
                        .font(.callout.monospaced())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isFromHistory {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }

            Divider()

            VStack(spacing: 12) {
                InfoRow(label: "Trim", value: vehicle.trim)
                InfoRow(label: "Body Type", value: vehicle.bodyType)
                InfoRow(label: "Drive Type", value: vehicle.driveType)
                InfoRow(label: "Engine", value: vehicle.engineInfo)
            }
            
            if showMoreDetails {
                Divider()
                VStack(spacing: 8) {
                    InfoRow(label: "Fuel Type", value: vehicle.fuelTypePrimary)
                    InfoRow(label: "Cylinders", value: vehicle.engineCylinders)
                    InfoRow(label: "Displacement", value: vehicle.displayDisplacement)
                    InfoRow(label: "Transmission", value: vehicle.transmissionStyle)
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        showMoreDetails.toggle()
                    }
                }) {
                    Text(showMoreDetails ? "Show Less" : "Show More")
                        .font(.footnote.weight(.semibold))
                    Image(systemName: showMoreDetails ? "chevron.up" : "chevron.down").font(.footnote)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .overlay(
             RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value ?? "N/A")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VINLookupView()
}

