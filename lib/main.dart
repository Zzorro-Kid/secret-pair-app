import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secretpairapp/app/app.dart';
import 'package:secretpairapp/core/di/service_locator.dart';
import 'package:secretpairapp/core/utils/screenshot_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup Dependency Injection
  await setupServiceLocator();

  // Initialize Screenshot Detector
  await sl<ScreenshotDetector>().initialize();

  runApp(const SecretPairApp());
}
