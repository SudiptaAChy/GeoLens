# GeoLens Attendance

A geo-fenced attendance system built with native Android (Kotlin + Jetpack Compose). Users set their office location once, then can only mark attendance when they're physically within a 50-meter radius of that location — verified in real time using continuous GPS tracking.

## Features

- **Set Office Location** — captures the user's current GPS coordinates and saves them locally via SharedPreferences
- **Live Distance Tracking** — continuously observes the user's location and calculates real-time distance to the saved office location
- **Geofenced Attendance Marking** — the "Mark Attendance" action only becomes enabled once the user is within 50 meters
- **Interactive Map** — visualizes the saved office location with a live-updating marker and camera
- **Graceful Permission & Hardware Handling** — requests location permission at runtime, detects if device location services are switched off, and automatically prompts the user to enable them via the native Play Services resolution dialog (no manual trip to Settings required)

## Project Structure / Approach

The app follows a lightweight **MVVM architecture** with a single-screen flow. State management is handled through **Kotlin `StateFlow`**, exposed from `AttendanceViewModel` as a single `AttendanceUiState`, which the Composable UI collects via `collectAsStateWithLifecycle()`.

- **`AttendanceViewModel`** — the sole state holder for the screen. Exposes `uiState: StateFlow<AttendanceUiState>` and drives all business logic: `setOfficeLocation()` performs a one-shot GPS fetch and persists it, `startObservingLocation()` continuously collects live GPS updates and recalculates distance to the office location, and `markAttendance()` validates that distance against the 50m radius before confirming.
- **`GpsLocationService`** — a Hilt-injected singleton wrapping `FusedLocationProviderClient`. Provides a one-time location fetch, a continuous `Flow<Location>` of updates, distance calculation, and a Play Services **Location Settings API** check that resolves disabled device location automatically.
- **`SharedPreferenceService`** — a Hilt-injected singleton isolating all `SharedPreferences` read/write logic for the saved office coordinates, keeping persistence concerns out of the ViewModel entirely.

Dependency injection is handled via **Dagger Hilt** (`@HiltViewModel`, `@Inject` constructors, `@Singleton` scoping), and the UI is composed of small, stateless Composables (`OfficeContextScreen`, `DistanceStatusScreen`, `MarkAttendanceScreen`) that receive state and event callbacks from the top-level `AttendanceScreen` — keeping data flowing down and events flowing up.

## Generative AI Usage

Generative AI (Claude) was used throughout this project as a pair-programming and debugging assistant, particularly for:

- **Architecture decisions** — deciding on MVVM with a single `StateFlow`-based `AttendanceUiState`, and later refactoring SharedPreferences access out of the ViewModel into a dedicated service class
- **Dependency Injection setup** — scaffolding Dagger Hilt from scratch (Application class, `@HiltViewModel`, injectable services) and migrating a manual `viewModelFactory` approach to Hilt
- **UI Design** — described how the components should be in the UI
- **Debugging & Bug fixing** — provided code snippet and described current behavior and expected behavior. Also pointed out potential leaking point.
- **Documentation** - Generated README file

Some of the essential prompts used:
- *"Create a "AttendanceViewModel" also create a GPS locaiton manager class. Thing is viewmodel will always parse location from location manager class and calculate a distance from current location to office location. Office location is saved in SharedPref. ViewModel also have a function call setOfficeLocation which will fetch current gps location and saved to SharedPref."*
- *"Create a Jetpack Compose view which will contain a Column of 3 sub views. Then Described all components of each view..."*
- *"Create a SharedPreference service class with basic CRUD functionalities"*
- *"Write code for runtime location permissions, also mention permissions of manifest file"*

All AI-suggested code was reviewed, tested on a physical device, and iterated on before being accepted into the final codebase.

## How to Run

### Prerequisites
- Android Studio (latest stable channel recommended)
- JDK 17+
- A physical Android device or emulator with Google Play Services (required for `FusedLocationProviderClient`)
- A Google Maps API key (see below)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/GeoLens.git
   cd "GeoLens/GeoLens Attendance"
   ```

2. **Add your Google Maps API key**
   Create a `local.properties` file in the project root (if it doesn't already exist) and add:
   ```properties
   MAPS_API_KEY=your_api_key_here
   ```
   Generate a key via [Google Cloud Console](https://console.cloud.google.com/) with the **Maps SDK for Android** enabled.

3. **Open in Android Studio**
   Open the `GeoLens Attendance` folder as a project and let Gradle sync.

4. **Run the app**
   Select a device/emulator with Google Play Services and click **Run**. On first launch, grant the location permission when prompted, and enable device location if asked.

5. **Using the app**
   - Tap **Set Office Location** while at your desired reference point.
   - Move around — the distance indicator and "Mark Attendance" button will update live.
   - Once within 50 meters, tap **Mark Attendance** to confirm.

### Release APK
[app-apk](https://drive.google.com/file/d/1nqkxVmCz3xZ3w_wwIX45uh6uGL0CXTz-/view?usp=sharing)


## Screen Recording
![App Demo](../recordings/attendance.gif)