
# iOS Location Tracking App

## Overview

This iOS app tracks the user's location and adds markers on the map every time the location changes by 100 meters. The app continues location tracking in the foreground and background for as long as possible. The markers display the address of the location and allow users to start or stop the tracking. The route is resettable, and previous routes are displayed when the app is reopened.

## Features

- Tracks the user's location in real-time and updates every 100 meters.
- Markers are added to the map with location details.
- Allows starting or stopping location tracking.
- Route reset option; previous routes are visible upon app reopening.
- Location tracking continues in the background for extended periods.
- MVVM architecture used.
- Apple Maps (MapKit) for mapping functionality.
- SnapKit and Lottie used for layout and animations.

## Technologies

- **Language:** Swift
- **MapKit:** For displaying the map and adding markers.
- **SnapKit:** For layout management.
- **Lottie:** For animations.
- **GitHub:** Project is version-controlled using Git.

## Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/LocationTrackingApp.git
   ```

2. Open the project in Xcode.

3. Install dependencies (if any) using CocoaPods or Swift Package Manager.

4. Run the app on your device or simulator.

## How to Use

- The app will automatically track the user’s location and add a marker on the map every 100 meters.
- Tapping on a marker will show the corresponding address.
- You can start or stop the tracking via the UI.
- Reset the route to clear previous markers and start fresh.
- When reopening the app, the last route will be shown.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
