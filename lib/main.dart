// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'dart:io';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/send_money_screen.dart';
import 'screens/transfer_to_bank_screen.dart';
import 'screens/amount_input_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/bank_transfer_confirmation_screen.dart';
import 'screens/merchant_confirmation_screen.dart';

// Define a class to hold the device check result
class DeviceCheckResult {
  final bool isAllowed;
  final String deviceId;

  DeviceCheckResult(this.isAllowed, this.deviceId);
}

// Replace this with the actual device ID of the phone you want to al

// Main application widget (unchanged)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telebirr Clone',
      theme: ThemeData(
        primaryColor: const Color(0xFF00A859),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF1E90FF),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E90FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/send_money': (context) => const SendMoneyScreen(),
        '/transfer_to_bank': (context) => const TransferToBankScreen(),
        '/amount_input': (context) => const AmountInputScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/bank_transfer_confirmation':
            (context) => const BankTransferConfirmationScreen(),
        '/pay_merchant_confirmation':
            (context) => const MerchantConfirmationScreen(),
      },
    );
  }
}

// Error application widget to display when the device is not allowed
class ErrorApp extends StatelessWidget {
  final String deviceId;

  const ErrorApp({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'This app can only be run on a specific device.\nYour device ID is: $deviceId',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
