# WebRTC Basic Video Calling App

A Flutter-based video calling application using WebRTC and Firebase for signaling.

## Features

- One-to-one video calls
- Signaling using Firebase Firestore
- Simple user interface for initiating and receiving calls
- Support for Android platform


## Technologies Used

- Flutter
- WebRTC (flutter_webrtc package)
- Firebase Firestore (for signaling)
- Firebase Authentication (for user authentication)
- GetX (for state management)

## Getting Started

### Prerequisites

- [FVM (Flutter Version Management)](https://fvm.app/) installed
- Flutter SDK (version specified in `.fvmrc`)
- Firebase account and project set up
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/motasimfuad/chat_rtc.git
   ```

2. Navigate to the project directory:
   ```
   cd chat_rtc
   ```

3. Use FVM to ensure you're using the correct Flutter version:
   ```
   fvm install
   fvm use
   ```

4. Install dependencies:
   ```
   fvm flutter pub get
   ```

5. Set up Firebase:
   - Create a new Firebase project
   - Add your Android and iOS apps to the Firebase project
   - Download and add the `google-services.json` (for Android)
   - Enable Firestore in your Firebase project

6. Run the app:
   ```
   fvm flutter run
   ```


## Call Flow

### Caller (Initiator) Flow

1. **Initiate Call**
   - User taps "Start Call" button in ChatScreen
   - `CallController.initiateCall()` is called
   - Navigate to CallSetupScreen
   - `WebRTCService.startCall()` is executed:
     - Get user media (audio/video)
     - Create peer connection
   - `WebRTCService.createAndStoreOffer()` is called:
     - Create offer
     - Set local description
     - Store offer in Firebase

2. **Wait for Answer**
   - CallSetupScreen shows "Waiting for answer" status
   - `WebRTCService` listens for changes in Firebase data

3. **Join Call**
   - When answer is received, `WebRTCService.handleStoredAnswer()` is called:
     - Set remote description with received answer
   - `CallController` navigates to CallScreen

### Callee (Receiver) Flow

1. **Receive Call**
   - `ChatController` listens for changes in Firebase data
   - When offer is detected, `CallController.checkForIncomingCall()` is triggered
   - Incoming call dialog is shown

2. **Answer Call**
   - If user accepts, `CallController.handleAnswerCall()` is called
   - `WebRTCService.handleAnswerCall()` is executed:
     - `WebRTCService.startCall()` is called to set up local media
     - `WebRTCService.handleStoredOffer()` sets remote description
     - Create and store answer in Firebase
   - Navigate to CallScreen

### Shared Steps

- ICE candidates are gathered and exchanged via Firebase throughout the process
- `WebRTCService` continuously updates call state
- Both parties can see when the other is ready to start the call
- Media connection is established once both parties have set local and remote descriptions

### Call Management

- `CallScreen` displays local and remote video streams
- Users can end the call using the end call button, which triggers `CallController.endCall()`

This flow ensures:
- Caller can't join until callee answers
- Callee can't join until caller creates offer
- Both parties are aware of call setup progress
- Connection is fully established before entering CallScreen
- Proper cleanup of resources when call ends

## Project Structure

- `lib/src/core/services/webrtc`: WebRTC service implementation
- `lib/src/features/chat`: Chat and call-related screens and controllers
- `lib/src/core/routes`: App routing
- `lib/src/core/theme`: App theme and colors

## Usage

1. Launch the app on two devices
2. Enter user details on each device
3. Initiate a call from one device
4. Accept the call on the other device
5. Enjoy your video call!
