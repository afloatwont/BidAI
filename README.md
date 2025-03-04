# Firebase Auth & Firebase Cloud Firestore Tutorial (MVVM with riverpod)

This is a Flutter application designed to demonstrate firebase auth and firebase cloud firestore usage with MVVM architecture using riverpod for state management.

## Getting Started

Follow these instructions to set up and run the project on your local machine.

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase account: [Create a Firebase project](https://firebase.google.com/)

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/afloatwont/BidAI.git
   cd bidai
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase:**
   - Follow the instructions to add Firebase to your Flutter app: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
   - Replace the `firebase_options.dart` file with your own Firebase configuration.

4. **Run the app:**
   ```sh
   flutter run
   ```

## Project Structure

- `lib/core`: Contains core functionalities like error handling and theming.
- `lib/models`: Data models for the application.
- `lib/repositories`: Repository classes for interacting with Firebase.
- `lib/viewmodels`: ViewModel classes for state management using Riverpod.
- `lib/views`: UI screens and widgets.

## Features

- User authentication (sign up, sign in, sign out)
- Product management (add, view, and categorize products)
- Real-time updates using Firebase Firestore
- Error handling and user-friendly error messages

## Demo Video

Watch the demo video to see the app in action:

[](https://github.com/afloatwont/BidAI/raw/main/demo.mp4)

