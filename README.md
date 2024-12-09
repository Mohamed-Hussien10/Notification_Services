# NotificationService - Firebase and Local Notifications

## Overview
The `NotificationService` class provides an easy-to-use interface for handling push notifications through Firebase Cloud Messaging (FCM) and local notifications using the `flutter_local_notifications` package in your Flutter app.

### Features:
- **Request Notification Permissions**: Requests permission for displaying notifications on the device.
- **Handle Push Notifications**: Receives push notifications via FCM, even when the app is in the background or closed.
- **Local Notifications**: Displays local notifications when messages are received while the app is in the foreground.
- **Background Message Handling**: Automatically handles background notifications and allows navigation based on notification data.

## Setup Instructions
1. **Add Dependencies**: Add the necessary dependencies to your `pubspec.yaml` file.

    ```yaml
    dependencies:
      firebase_messaging: ^14.0.0 `Or the latest version`
      flutter_local_notifications: ^9.0.0 `Or the latest version`
      firebase_core: ^2.0.0 `Or the latest version`
    ```

2. **Initialize Firebase**: Initialize Firebase in your `main.dart` file.

    ```dart
    import 'package:firebase_core/firebase_core.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(MyApp());
    }
    ```

3. **Initialize `NotificationService`**: Call the `initialize()` method in the `main.dart` or main screen of your app.

    ```dart
    import 'notification_service.dart'; 

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      // Initialize the notification service
      await NotificationService.instance.initialize();

      runApp(MyApp());
    }
    ```

4. **Send Push Notifications**: Use Firebase Cloud Functions to send notifications. You can use the Firebase Admin SDK to trigger remote notifications to devices.

5. **Handle Notification Click**: Customize how your app responds when the user clicks a notification (e.g., navigating to a specific screen).

    ```dart
    void _handleBackgroundMessage(RemoteMessage message) {
      if (message.data['type'] == 'section_status') {
        // Navigate to a section details screen
        print('Opening section details...');
      }
    }
    ```

