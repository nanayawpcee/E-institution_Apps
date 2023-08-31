import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutorlinkelearning/components/routes.dart';
import 'package:tutorlinkelearning/firebase_options.dart';
import 'package:tutorlinkelearning/utils/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';


//this is the background notification handler for the app
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
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.orange),
      actionButtons: [
        NotificationActionButton(
            key: 'Ok', label: 'Okay', autoDismissible: true)
      ]);
}

void main() async {
  // Notification initialization for the app 
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
  

  WidgetsFlutterBinding.ensureInitialized();//firebase core initialisation to unable to connection to the Api
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _intialization = Firebase.initializeApp();

  // This widget is the root of the  app.
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
