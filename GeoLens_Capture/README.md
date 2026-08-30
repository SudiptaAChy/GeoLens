# GeoLens Capture

A Flutter app for capturing image batches with a custom camera UI and syncing them to the cloud through a resilient, offline-first upload queue. Photos are captured locally, queued for upload, and automatically retried in the background whenever a stable internet connection is detected — no manual intervention required.

## Features

- **Custom Camera UI** — a full custom camera preview screen with pinch-to-zoom, a zoom slider, quick zoom presets (0.5x / 1x / 2x / 3x), tap-to-focus with a visual indicator, and front/back lens switching
- **Batch Capture** — capture multiple photos in a single session, with a live thumbnail preview and running batch count badge before uploading
- **Pending Uploads Dashboard** — a dedicated screen listing every queued item with its thumbnail, size, and live status (waiting / uploading / success / failed)
- **Batch Sync Progress Header** — a real-time summary under the app bar showing overall sync percentage, a progress bar, and completed vs. total data size across the whole queue
- **Resilient Sync Engine** — failed or interrupted uploads stay in a persistent local queue instead of being lost; a foreground connectivity listener retries automatically the instant a connection returns, and a `workmanager` background task provides the same retry behavior even when the app is closed
- **Manual Retry** — individual failed items can be retried on demand from the dashboard, besides auto retry by workmanager.

## Project Structure / Approach

The app follows the **BLoC/Cubit** pattern for state management, structured as feature modules (`camera/`, `dashboard/`) each with their own `cubit`, `models`, `views`, and `repositories`/`services`, plus a shared `core/` layer for cross-feature services.

- **`CameraCubit`** — owns the `CameraController` and drives zoom, focus, and capture logic, exposing a single immutable `CameraPageState`.
- **`UploadQueueCubit`** — the core of the sync engine. Loads the persisted queue on startup, adds new batches, listens to connectivity changes, and processes pending/failed uploads sequentially with live progress updates.
- **`UploadRepository`** — orchestrates uploads by delegating storage to `SharedPrefService` and the actual "network call" to `MockApiService` (since no real backend was provided for this task).
- **`MockApiService`** — simulates a real upload endpoint with a 3–5 second delay per image and a deterministic hardcoded success/failure outcome, so retry behavior is reproducible on demand.
- **`ConnectivityService`** — wraps `connectivity_plus` to check and stream real-time connection status.
- **`background_sync_service.dart`** — the `workmanager` callback dispatcher that mirrors the cubit's upload logic in a background isolate, constrained to only run when a network connection is available.

All UI screens are `StatelessWidget`s that read state via `BlocBuilder`/`context.watch` and dispatch actions through `context.read<Cubit>()` — no `setState` is used anywhere in the app.

## Generative AI Usage

Generative AI (Claude) was used throughout this project as a pair-programming and debugging assistant, particularly for:

- **Architecture decisions** — structuring the app around Cubit instead of `setState`, and designing the offline-first sync engine (persistent queue + connectivity listener + background worker) around a shared repository
- **UI Design** — building the custom camera preview (zoom slider, presets, tap-to-focus, capture button, batch thumbnail) and the dashboard's sync progress header, iterated over several passes for layout and centering fixes
- **Service isolation** — refactoring storage logic out of the repository into a dedicated `SharedPrefService`, and separating the mock upload simulation into its own `MockApiService`
- **Debugging & Bug fixing** — diagnosing a stuck loading spinner on camera init, a missing `Offset` import, `const`-related compile errors, and a list item hidden behind the floating action button
- **Documentation** — generated this README file

Some of the essential prompts used:
- *"Custom Camera UI: Build a camera preview screen... Zoom: pinch-to-zoom, a slider and rounded buttons... Manual Focus: Tap-to-focus with a visual indicator at the tap point."*
- *"Batch Management... Resilient Sync Engine: background worker (workmanager) to monitor connectivity. If the API call fails... images must remain in the local queue. Automatically retry... without user intervention."*
- *"do this with maintaining cubit pattern (as per assessment requirement)"*
- *"Create a mock API service class that mimic image uploading behavior for Success and Failed hard-codedly."*
- *"create a sharedPref service and isolate all functions from repository"*

All AI-suggested code was reviewed, tested, and iterated on before being accepted into the final codebase.

## How to Run

### Prerequisites
- Flutter SDK (latest stable channel recommended)
- Android Studio or VS Code with Flutter/Dart plugins
- A physical Android device or emulator (camera features require a physical device — emulator camera support is limited)

### Steps

1. **Clone the repository**
```bash
   git clone https://github.com/<your-username>/GeoLens.git
   cd "GeoLens/GeoLens Capture"
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Run the app**
```bash
   flutter run
```
   On first launch, grant camera permission when prompted.

4. **Using the app**
   - Tap **START NEW UPLOAD BATCH** on the Dashboard to open the camera.
   - Capture one or more photos — the thumbnail and batch count update live.
   - Tap **Upload Batch** to queue the captures and return to the Dashboard.
   - Watch the **Batch Sync Progress** header and each item's status update in real time as uploads complete, fail, and automatically retry.
   - Turn off Wi-Fi/mobile data mid-upload to see items queue as "Failed" and automatically resume once connectivity returns.

### Release APK
[app-apk](https://drive.google.com/file/d/1Fdiomlpdbh64Dcj4p-vIAXZFDQ9UEw_h/view?usp=sharing)

## Screen Recording

<video src="../recordings/capture.mp4" controls width="300"></video>