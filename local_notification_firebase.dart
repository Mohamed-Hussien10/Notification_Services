import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  // Initialize FCM and local notifications
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission for notifications
    await _requestPermission();

    // Set up message handlers
    await _setupMessageHandlers();
  }

  // Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted.');
    } else {
      print('Notification permission denied.');
    }
  }

  // Set up Flutter Local Notifications
  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // Android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS setup
    final initializationSettingsDarwin = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Initialize flutter notifications
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  // Show notification
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    required String
        deviceToken, // This parameter is used for remote push notifications (optional)
  }) async {
    try {
      // Generate a valid notification ID by truncating millisecondsSinceEpoch
      int notificationId = DateTime.now().millisecondsSinceEpoch %
          (2 ^ 31); // Modulo to ensure the value fits within the 32-bit range

      // Show local notification (this is what will run on the device)
      await _localNotifications.show(
        notificationId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload.toString(),
      );

      // If you need to send a remote message to a device, you would use Firebase Cloud Functions
      // For example, use Firebase's Cloud Functions SDK to trigger the push notification
      // This is not done within the app itself but through the Firebase server side.
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Set up message handlers for foreground and background messages
  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('Received foreground message: ${message.notification?.title}');
      showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data,
        deviceToken:
            '', // This will be handled differently based on your implementation
      );
    });

    // Handle background messages when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle initial message when the app is opened directly from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // Handle background message (when app is opened from notification click)
  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'section_status') {
      // Example: Navigate to a section details screen
      print('Opening section details...');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    payload: message.data,
    deviceToken: '', // Handle the device token accordingly
  );
}
