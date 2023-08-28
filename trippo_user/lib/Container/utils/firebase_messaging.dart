import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_user/Container/utils/error_notification.dart';

class MessagingService {
  static String? fcmToken; // Variable to store the FCM token

  static final MessagingService _instance = MessagingService._internal();

  factory MessagingService() => _instance;

  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    try {
      // Requesting permission for notifications
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          'User granted notifications permission: ${settings.authorizationStatus}');

      // Retrieving the FCM token
      fcmToken = await _fcm.getToken();
      print('fcmToken: $fcmToken');

      // Handling background messages using the specified handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Listening for incoming messages while the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.notification!.title.toString()}');

        if (message.notification != null) {
          if (message.notification!.title != null &&
              message.notification!.body != null) {
            final notificationData = message.data;
            final screen = notificationData['screen'];

            // Showing an alert dialog when a notification is received (Foreground state)
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: Text(message.notification!.title!),
                    content: Text(
                      message.notification!.body!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.black54),
                    ),
                    actions: [
                      if (notificationData.containsKey('screen'))
                        TextButton(
                          onPressed: () {
                            context.pop();
                            context.goNamed(screen);
                          },
                          child: const Text('Open Screen'),
                        ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      });

      // Handling a notification click event by navigating to the specified screen
      void handleNotificationClick(
          BuildContext context, RemoteMessage message) {
        final notificationData = message.data;

        if (notificationData.containsKey('screen')) {
          final screen = notificationData['screen'];
          context.goNamed(screen);
        }
      }

      // Handling the initial message received when the app is launched from dead (killed state)
      // When the app is killed and a new notification arrives when user clicks on it
      // It gets the data to which screen to open
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          handleNotificationClick(context, message);
        }
      });

      // Handling a notification click event when the app is in the background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            'onMessageOpenedApp: ${message.notification!.title.toString()}');
        handleNotificationClick(context, message);
      });
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");

      if (context.mounted) {
        ErrorNotification().showError(context, e.toString());
      }
    }
  }
}

// Handler for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message: ${message.notification!.title}');
}
