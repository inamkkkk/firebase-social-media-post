# Firebase Social Media Post App

A Flutter app that allows users to create and upload social media posts with Firebase Authentication, Firestore, and Storage.

## Features

- User Authentication (Sign-in/Sign-up)
- Creating and uploading posts with text and images
- Displaying posts in a feed
- Realtime updates of the feed

## Technologies Used

- Flutter
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Provider (State Management)

## Getting Started

1.  Clone the repository.
2.  Set up a Firebase project.
3.  Enable Authentication, Firestore, and Storage in your Firebase project.
4.  Configure your Flutter app with your Firebase project credentials.
5.  Run `flutter pub get`.
6.  Run the app.

## Folder Structure


lib/
  main.dart
  screens/
    auth_screen.dart
    home_screen.dart
    create_post_screen.dart
  models/
    post_model.dart
  services/
    auth_service.dart
    firestore_service.dart
    storage_service.dart


## State Management

The app uses the Provider package for state management.  `ChangeNotifierProvider` is used to provide data to the UI.
