// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:haushalt_app/firebase_options.dart';
import 'package:haushalt_app/providers/dishwasher_provider.dart';
import 'package:haushalt_app/screens/auth/authchecker.dart';
import 'package:haushalt_app/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/screens/auth/login_screen.dart';
import 'package:haushalt_app/providers/task_provider.dart';
import 'package:haushalt_app/providers/fridge_provider.dart';
import 'package:haushalt_app/providers/laundry_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await setupNotifications();

  String? token = await messaging.getToken();

Future<void> sendTokenToBackend(String? token) async {
  if (token == null) return;

  final url = Uri.parse('http://192.168.178.22:8000/api/save-token/'); // Ersetze durch deine URL

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"token": "$token"}',
    );

    if (response.statusCode == 200) {
      print('Token erfolgreich zum Backend gesendet');
    } else {
      print('Fehler beim Senden des Tokens: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception beim Senden des Tokens: $e');
  }
}

  await sendTokenToBackend(token);
}final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupNotifications() async {
  // Android-Initialisierung
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS-Initialisierung (optional)
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Notification-Berechtigungen anfragen (besonders iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Nachricht im Vordergrund abfangen
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Nur wenn eine Notification dabei ist
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id', 'channel_name',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print("Push empfangen: ${message.notification?.title}");
    });
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DishwasherProvider()),
        ChangeNotifierProvider(create: (_) => FridgeProvider()),
        ChangeNotifierProvider(create: (_) => LaundryProvider()),
      ],
      child: MaterialApp(
        title: 'Haushaltsmanager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6200EE), // Deep purple for app bars
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          // cardTheme: CardTheme(
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03DAC6), // Teal accent color
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF03DAC6), // Teal accent color
            foregroundColor: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blueGrey[50], // Light grey for input fields
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          // Set text style for better readability
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        home: const AuthChecker(),

      ),
    );
  }
}
