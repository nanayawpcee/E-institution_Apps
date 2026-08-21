import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Screens/Splash/splashscreen.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TutorLink Admin',
      debugShowCheckedModeBanner: false,
      theme: TLTheme.light(),
      darkTheme: TLTheme.dark(),
      // The topbar's sun/moon control drives this, so the console never falls
      // back to the OS setting mid-session.
      themeMode: ref.watch(themeModeProvider),
      home: const SplashScreen(),
      routes: routes,
    );
  }
}
