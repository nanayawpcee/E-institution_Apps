import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for receiving notifications
    await _firebaseMessaging.requestPermission();

    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a new notification: ${message.notification!.body}");
      // Handle displaying a notification in the app or updating UI.
    });

    // Handle notifications when the app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on the notification to open the app: ${message.notification!.body}");
      // Handle navigating to the appropriate screen in your app.
    });

    // Handle notifications when the app is in the background
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("User tapped on the notification to open the app from the background: ${initialMessage.notification!.body}");
      // Handle navigating to the appropriate screen in your app.
    }
  }
}
