import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gala_gatherings/NotificationScree.dart';
import 'package:gala_gatherings/prefrence_helper.dart';
import 'package:gala_gatherings/screens/Tabs/Profile/post_screen.dart';
import 'package:gala_gatherings/screens/Tabs/tabs.dart';
import 'package:gala_gatherings/screens/login_screen.dart';
import 'package:gala_gatherings/welcome_screen.dart';
import 'package:gala_gatherings/api_service.dart';

import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';



@pragma('vm:entry-point')

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//    await Firebase.initializeApp();
//   showNotification(message);
//   print("Handling a background message: ${message.notification!.body}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: "AIzaSyB3UySbCaiXjC_bh2h9JAjTKvbeUVA1OmQ",
  //     appId: "1:508708683425:android:fcfeda59f64fd186e9bae0",
  //     messagingSenderId: "508708683425",
  //     projectId: "cloudbelly-d97a9",
  //   ),
  // );

  // await requestNotificationPermission();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await initializeNotification();

  // FlutterLocalNotificationsPlugin().initialize(
  //   const InitializationSettings(
  //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //     iOS: DarwinInitializationSettings()
  //   ),
  //   onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) {
  //     if (notificationResponse?.payload != null) {
  //       handleNotificationClick(notificationResponse!.payload!);
  //     }
  //   },
  // );

  // Initialize deep links
  // await initUniLinks();

  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  await UserPreferences.init();
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print("fcmToken $fcmToken");
  // await prefs.setString('fcmToken', fcmToken ?? "");
  // Auth().getToken(fcmToken);
  Auth().getUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Future<void> requestNotificationPermission() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   print('User granted permission: ${settings.authorizationStatus}');
// }

// Future<void> showNotification(RemoteMessage message) async {
//   var androidChannel = const AndroidNotificationDetails(
//     'CHANNEL_ID',
//     'CHANNEL_NAME',
//     channelDescription: 'CHANNEL_DESCRIPTION',
//     importance: Importance.high,
//     priority: Priority.high,
//     color: Colors.blue, // Customize color
//     enableLights: true,
//     enableVibration: true,
//     playSound: true,
//     icon: '@mipmap/ic_launcher', // Customize icon if needed
//   );
//   var platformChannel = NotificationDetails(android: androidChannel);
//   FlutterLocalNotificationsPlugin().show(
//     message.hashCode,
//     message.notification?.title,
//     message.notification?.body,
//     platformChannel,
//     payload: message.data['type'], // Add payload data
//   );
// }

void handleNotificationClick(String payload) {
  print("payload   from nott  $payload");
  if (payload == 'order') {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => NotificationScreen(),
    ));
  }
  // Handle other payloads as needed
}

// Future<void> initUniLinks() async {
//   try {
//     final initialLink = await getInitialLink();
//     if (initialLink != null) {
//       _handleDeepLink(Uri.parse(initialLink));
//     }
//     uriLinkStream.listen((Uri? uri) {
//       if (uri != null) {
//         _handleDeepLink(uri);
//       }
//     }, onError: (err) {
//       print('Error handling deep link: $err');
//     });
//   } on PlatformException {
//     print('PlatformException when handling deep link');
//   } on FormatException {
//     print('FormatException when handling deep link');
//   }
// }

// void _handleDeepLink(Uri deepLink) {
//   print("Received deep link: $deepLink");
//   final String? userId = deepLink.queryParameters['profileId'];
//   if (userId != null) {
//     print("Extracted userId: $userId");
//     // navigatorKey.currentState?.push(MaterialPageRoute(
//     //   builder: (context) => ProfileView(userIdList: [userId]),
//     // ));
//   } else {
//     print("No userId found in the deep link");
//   }
// }

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          // ChangeNotifierProvider(
          //   create: (ctx) => ViewCartProvider(),
          // ),
          // ChangeNotifierProvider(create: (ctx) => CartProvider()),
          ChangeNotifierProvider(
            create: (ctx) => TransitionEffect(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'GG',
            theme: ThemeData(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Color(0xFFFA6E00)),
                trackColor: MaterialStateProperty.all<Color>(
                    Colors.black.withOpacity(0.47)
                    ),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFA6E00)),
              useMaterial3: true,
            ),
            initialRoute: WelcomeScreen.routeName,
            routes: {
             
              // LoginScreen.routeName: (context) => LoginScreen(),
              // '/map': (context) => MapScreen(),
              '/login': (context) => LoginScreen(),

              // '/notifications': (context) => NotificationScreen(),
              WelcomeScreen.routeName: (context) => WelcomeScreen(),
              Tabs.routeName: (context) => Tabs(),
              PostsScreen.routeName: (context) => PostsScreen(),
              // ProfileSharePost.routeName: (context) => ProfileSharePost(),
              // GraphsScreen.routeName: (context) => GraphsScreen(),
              // ViewCart.routeName: (context) => ViewCart(),
            },
          ),
        ),
      );
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


