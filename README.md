**HueVault - iOS Color Code Generator**

Overview
HueVault is an iOS application designed to generate random hex color codes, display them on interactive cards, and manage their storage locally and in Firebase. This project fulfills the requirements of an iOS assignment, demonstrating offline persistence, online synchronization, and connectivity awareness.

Features
Color Code Generation: Generate unique random hex codes and display them on cards with corresponding colors.
Local Data Storage: Store color codes and timestamps locally using Core Data, ensuring persistence across app restarts (offline handling).
Firebase Sync: Sync generated colors to Firestore when the app is online.
Connectivity Awareness: Display a network status indicator (online/offline) using a custom StatusBar.
Error Handling: Implement basic retry logic for Firebase sync failures due to network issues.

Installation
Clone the Repository:git clone https://github.com/Ankit70294/HueVault-Assignment.git

Open in Xcode:
Launch Xcode and open the HueVault.xcodeproj file.

Install Dependencies:
Ensure Firebase is configured. Add GoogleService-Info.plist from the Firebase Console to the project root.

Build and Run:
Select a simulator or connected device and press Cmd + R to build and run.

Usage
Generate Colors: Tap the "Generate Color" button to create a new hex code, displayed on a card with a color preview.
Offline Mode: Colors are saved locally and persist after app closure when offline.
Online Mode: When internet is available, colors sync to Firebase Firestore (check the colors collection in the Firebase Console).
Network Status: The top bar indicates connectivity (green for online, red for offline).

Project Structure
HueVaultApp.swift: App entry point with Firebase configuration.
ContentView.swift: Main UI with StatusBar, ColorCard, and generation button.
ColorViewModel.swift: Manages color generation, network monitoring, and Firebase sync.
Persistence.swift: Handles Core Data setup and Firebase synchronization.
HueVault.xcdatamodeld: Core Data model for ColorEntity.

Development
Tools: Xcode, Swift, Core Data, Firebase Firestore, NWPathMonitor.
Design: Follows iOS Human Interface Guidelines with a responsive, clean design.

Demo
A walkthrough video demonstrating color generation, offline storage, and Firebase sync is available here. The video showcases:

Generating colors offline.
Persisting data after app restart.
Syncing to Firebase when online.

License
This project is for educational purposes only. No commercial use is permitted.

Acknowledgments
Built as part of an iOS assignment.
Utilizes Firebase and Apple’s SwiftUI framework.
