import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Components/routes.dart';
import 'theme/app_theme.dart';
import 'utils/user_state.dart';

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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TutorLink Tutor',
      debugShowCheckedModeBanner: false,
      theme: TLTheme.light(),
      darkTheme: TLTheme.dark(),
      // The profile screen's Dark mode switch drives this, so the app never
      // flips to the OS setting mid-session.
      themeMode: ref.watch(themeModeProvider),
      home: const UserState(),
      routes: routes,
    );
  }
}
