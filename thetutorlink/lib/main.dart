import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thetutorlink/Components/routes.dart';
import 'package:thetutorlink/constants.dart';
import 'package:thetutorlink/firebase_options.dart';
import 'package:thetutorlink/utils/user_state.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 123,
          channelKey: 'request_channel',
          color: kWhiteColor,
          title: title,
          body: body,
          category: NotificationCategory.Event,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.orange),
      actionButtons: [
        NotificationActionButton(
            key: "Accept",
            label: "Accept Request",
            color: Colors.green,
            autoDismissible: true),
        NotificationActionButton(
            key: "Reject",
            label: "Reject Request",
            color: kRedColor,
            autoDismissible: true)
      ]);
}

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'request_channel',
        channelName: 'request channel',
        channelDescription: "channel of request",
        defaultColor: Colors.redAccent,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        locked: true,
        defaultRingtoneType: DefaultRingtoneType.Notification)
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _intialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _intialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                    child: Center(
                  child: Text('Welcome To TutorLink App'),
                )),
              ),
            );
          } else if (snapshot.hasError) {
            return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Center(
                    child: Center(
                  child: Text('An error occurred, Please Wait...'),
                )));
          }
          return MaterialApp(
             theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
            debugShowCheckedModeBanner: false,
            title: "TutorLink App",
            home: UserState(),
            routes: routes,
          );
        });
  }
}
