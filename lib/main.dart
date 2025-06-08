// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/screens/auth/login_screen.dart';
import 'package:haushalt_app/providers/task_provider.dart';
import 'package:haushalt_app/providers/dishwasher_provider.dart';
import 'package:haushalt_app/providers/fridge_provider.dart';
import 'package:haushalt_app/providers/laundry_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FridgeProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          // Set text style for better readability
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}