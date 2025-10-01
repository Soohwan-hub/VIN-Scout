# VIN Scout - iOS Vehicle Identification App

A lightweight, modern iOS app built with SwiftUI to decode Vehicle Identification Numbers (VINs) using the NHTSA vPIC API.



## Overview

VIN Scout provides a clean, simple interface for looking up vehicle information. Users can enter a 17-character VIN, see the decoded details, and view a history of their recent lookups. The app is designed to be fast, reliable, and intuitive, with robust error handling and thoughtful user experience details.

## Features

### Core Features
- **VIN Input & Validation**: A single input field for a 17-character VIN. The lookup button is disabled until the length is correct, providing clear, real-time feedback.
- **Vehicle Lookup**: Decodes a valid VIN to show key vehicle data including Year, Make, Model, Trim, Body Class, Drive Type, Engine info, Fuel Type, and more.
- **State Handling**: A clean, state-driven UI that clearly displays loading spinners, success cards, and user-friendly error messages for invalid VINs, network issues, and API failures.
- **History**: Automatically saves the last 5 successful lookups to local device storage using `UserDefaults`.

### Implemented Extra Features
- **Client-Side Check Digit Validation**: Implements the ISO 3779 checksum algorithm to validate the 9th character of a VIN, catching common typos before an API call is made.
- **Hybrid History Interaction**: Tapping a history item instantly displays the cached result for speed and offline access. A refresh button appears on the card, allowing the user to fetch the latest data on demand.
- **History Deletion**: A long-press on any history item reveals a context menu with a destructive "Delete" action to easily manage recent lookups.
- **Paste & Clear**: The input field includes convenient buttons to paste a VIN from the clipboard (with automatic sanitization) and to clear the field with a single tap.

## Architecture

The app is built using the **MVVM (Model-View-ViewModel)** architecture to ensure a clean separation of concerns, making the codebase scalable and highly testable.

- **View (`VINLookupView`):** The SwiftUI view layer, responsible only for displaying the UI and forwarding user actions to the ViewModel.
- **ViewModel (`VINViewModel`):** The brain of the app. It manages the view's state (`@Published` properties), handles user input, and coordinates with the services to perform business logic. It is marked with `@MainActor` to ensure all UI updates are thread-safe.
- **Services:**
    - **`VINAPIService`:** Handles all networking, responsible for fetching and decoding data from the NHTSA API.
    - **`HistoryService`:** Manages the persistence (saving and loading) of the lookup history using `UserDefaults`.
    - **`VINValidator`:** A dedicated utility for performing client-side validation logic, including the check digit algorithm.
- **Model (`VehicleInfo`, `VINError`):** Simple, `Codable` data structures that represent the app's data and error states.

Dependency Injection is used to provide services to the `VINViewModel`, allowing for a mock `VINAPIService` to be injected during unit tests.

## Technical Details

- **Platform:** iOS 17.0+
- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **Concurrency:** `async/await` for modern, structured concurrency.
- **Dependencies:** None. The project uses only native Apple frameworks.

## How to Build and Run

1.  Clone the repository.
2.  Open `VINScout.xcodeproj` in Xcode 15 or later.
3.  Select an iOS simulator or a connected device.
4.  Press **Run** (Cmd + R).

## API Notes

- **Endpoint:** The app uses the public U.S. NHTSA vPIC "DecodeVin" endpoint.
- **Rate Limits:** The NHTSA API has rate limits, but they are generally generous for this type of application. Excessive requests may result in temporary IP blocking.

## Decisions & Trade-offs

- **`UserDefaults` for History:** `UserDefaults` was chosen for its simplicity and is perfectly suited for storing a small, non-relational list of the last 5 lookups. For a more complex app with a larger history or user accounts, a more robust solution like **SwiftData** or **Core Data** would be preferable.
- **History UX (Hybrid Model):** The decision was made to instantly show cached data when a history item is tapped, with an optional refresh button. This provides the best trade-off between speed/offline access and the ability to fetch fresh data.
- **`@MainActor` on ViewModel:** The entire `VINViewModel` class is marked `@MainActor`. This simplifies development by ensuring all properties and methods are accessed on the main thread by default, preventing common UI-related concurrency bugs.

## Future Work (With 2 More Days)

- **VIN Scanning:** Implement a camera-based scanner using `VisionKit`'s `DataScannerViewController`. This would be the highest-impact feature, allowing users to scan VIN barcodes instead of typing.
- **UI Polish:** Introduce skeleton loaders to replace the `ProgressView` for a smoother loading experience, and add subtle haptic feedback for button taps and successful lookups.
- **Accessibility:** Conduct a full accessibility review to ensure proper VoiceOver labels, support for Dynamic Type scaling, and sufficient color contrast.
- **Integrate Vehicle Safety & Recall History** : The highest-value next step would be to fetch and display critical safety information. This would involve a second API call to the NHTSA Recalls API (recallsByVin endpoint) to get data on active recalls, manufacturer campaigns, and consumer complaints for the vehicle. The work would include creating new Codable models for the recall data, adding a fetchSafetyHistory(for:) function to the VINAPIService, and designing a new section in the UI to present this vital information to the user. For optimal performance, the two network calls (vehicle info and safety history) could be run concurrently using a TaskGroup.

## Testing

The project includes several unit tests for key pieces of logic.

- **`VINValidator` Tests:** Verify that the checksum algorithm correctly identifies valid and invalid VINs.
- **`VINViewModel` Tests:** Use a mock `VINAPIService` to test the ViewModel's behavior in both success and failure scenarios, as well as the history deletion and result clearing logic.

### Sample VINs Used for Testing

- **2019 Ford F-150:** `1FTFW1E57KFA14352`
- **2021 Honda Accord:** `1HGCV1F52MA000123`
- **2012 Jeep Grand Cherokee:** `1C4PJMAK2CW184491`
- 2HKRM3H38EH550410
- 1FTFW1E5XPFB12346
- KNAFU4A2XD5739551
- JM1GJ1W65E1143959
- 4JGBB86E06A006500

---
*(Estimated time spent on project: ~11 hours)*
