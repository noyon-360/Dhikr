import 'dart:io';

// import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'package:local_notifier/local_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:dhikrs/Controller/Provider/AllahNamesProvider.dart';
import 'package:dhikrs/Controller/Provider/CustomAddProvider.dart';
import 'package:dhikrs/Controller/Provider/DhirkProvider.dart';
import 'package:dhikrs/Controller/Provider/TimerProvider.dart';
import 'package:dhikrs/Controller/Provider/UserSavedProvider.dart';
import 'package:dhikrs/ListOfAllName/dhikrs.dart';
import 'package:dhikrs/ListOfAllName/ListOfName.dart';
import 'package:dhikrs/Screens/HomeScreen.dart';
import 'package:window_manager/window_manager.dart';

import 'persona/firebase_options.dart';
// import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // print("Background Task Running: $task");
//     await NotificationHelper.performBackgroundTask();
//
//     return Future.value(true);
//   });
// }

// void _requestPermissions() async {
//   if (await Permission.ignoreBatteryOptimizations.isDenied) {
//     await Permission.ignoreBatteryOptimizations.request();
//   }
//   if (await Permission.notification.isDenied) {
//     await Permission.notification.request();
//   }
// }

// void _startBackgroundFetch() async {
//   await BackgroundFetch.configure(
//     BackgroundFetchConfig(
//       minimumFetchInterval: 15, // Fetch interval in minutes
//       stopOnTerminate: false, // Continue after termination
//       enableHeadless: true, // Enable headless mode
//     ),
//     _onBackgroundFetch,
//     _onBackgroundFetchTimeout,
//   );
// }
//
// void _onBackgroundFetch(String taskId) async {
//   print("[BackgroundFetch] Event received: $taskId");
//
//   // Perform your background task here, such as fetching data from a server.
//
//   BackgroundFetch.finish(taskId);
// }
//
// void _onBackgroundFetchTimeout(String taskId) {
//   print("[BackgroundFetch] Timeout: $taskId");
//   BackgroundFetch.finish(taskId);
// }
//
// void backgroundFetchHeadlessTask(String taskId) async {
//   print("[BackgroundFetch] Headless event received: $taskId");
//
//   // Handle headless background task here.
//
//   BackgroundFetch.finish(taskId);
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await localNotifier.setup(
      appName: 'dhikrs',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    WindowManager.instance.setMinimumSize(const Size(1024, 768));
  }

  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
        appName: packageInfo.appName,
        appPath: Platform.resolvedExecutable,
        packageName: 'dev.leanflutter.examples.launchatstartupexample',
        args: <String>['--minimized']);

    // await TrayManager.instance.setIcon("Assets/Images/dhikrs Logo.ico");
    await launchAtStartup.enable();
    // await launchAtStartup.disable();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    // Workmanager().registerOneOffTask("1", "simpleTask");
    // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    // _startBackgroundFetch();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux,
            macOS: initializationSettingsDarwin);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // _requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAddProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => AllahNamesProvider(allahNames)),
        ChangeNotifierProvider(create: (_) => DhikrProvider(mostCommonDhikr)),
        ChangeNotifierProvider(create: (_) => UserSaveDuaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
