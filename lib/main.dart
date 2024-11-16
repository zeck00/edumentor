import 'package:edumentor/screens/home.dart';
import 'package:edumentor/screens/login.dart';
import 'package:edumentor/services/auth_service.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.green,
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.blue,
          surface: AppColors.white,
          error: AppColors.red,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.black),
          bodyMedium: TextStyle(color: AppColors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.black),
          ),
        ),
      ),
      // Use the builder property to modify MediaQuery
      builder: (context, child) {
        // Retrieve the existing MediaQuery data
        final mediaQueryData = MediaQuery.of(context);

        // Modify the textScaler or textScaleFactor as needed
        final modifiedMediaQuery = mediaQueryData.copyWith(
          // For Flutter 3.13 and above
          textScaler: const TextScaler.linear(1.0),
          // For Flutter versions below 3.13, use textScaleFactor
          // textScaleFactor: 1.0,
        );

        return MediaQuery(
          data: modifiedMediaQuery,
          child: child!,
        );
      },
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.green,
                ),
              ),
            );
          }

          return snapshot.data == true ? const HomePage() : const LoginScreen();
        },
      ),
    );
  }
}
