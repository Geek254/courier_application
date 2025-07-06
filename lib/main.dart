import 'package:courier_application/profile_screen.dart';
import 'package:courier_application/screens/admin_screen.dart';
import 'package:courier_application/screens/traveler_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login.dart';
import 'models/user.dart';
import 'services/auth_service.dart';

final DateTime currentDateTime = DateTime.now();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInitialized = false;
  try {
    if (kDebugMode) print("Checking Firebase apps at $currentDateTime: ${Firebase.apps.length} apps exist");
    if (Firebase.apps.isEmpty) {
      if (kDebugMode) print("Initializing Firebase at $currentDateTime");
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else {
      if (kDebugMode) print("Firebase app already exists, using existing instance at $currentDateTime");
      firebaseInitialized = true;
    }
    firebaseInitialized = true; // Set to true if no exception
    if (kDebugMode) print("Firebase initialized successfully at $currentDateTime");
  } catch (e, stackTrace) {
    if (kDebugMode) print("Firebase initialization error: $e\nStackTrace: $stackTrace at $currentDateTime");
  }
  if (!firebaseInitialized) {
    if (kDebugMode) print("Falling back to error screen at $currentDateTime");
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text("Firebase initialization failed: Check logs")))));
    return;
  }
  runApp(
    ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("Building MyApp at $currentDateTime");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Courier Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (kDebugMode) print("InitState triggered with user: $user at $currentDateTime");
      _refreshUserData(user);
    }
  }

  Future<void> _refreshUserData(User? user) async {
    if (user != null) {
      if (kDebugMode) print("Refreshing user data for UID ${user.uid} at $currentDateTime");
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() {});
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.fetchUserData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("Building MyHomePage at $currentDateTime");
    final authService = Provider.of<AuthService>(context);
    final user = FirebaseAuth.instance.currentUser;
    if (kDebugMode) print("Current user in MyHomePage: $user at $currentDateTime");
    if (user == null) {
      if (kDebugMode) print("No user, redirecting to LoginScreen at $currentDateTime");
      return const LoginScreen();
    }

    return FutureBuilder<UserModel?>(
      future: authService.fetchUserData(user.uid),
      builder: (context, snapshot) {
        if (kDebugMode) print("FutureBuilder state: ${snapshot.connectionState} at $currentDateTime");
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (kDebugMode) print("Waiting for data at $currentDateTime");
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          if (kDebugMode) print("FutureBuilder error: ${snapshot.error} or no data at $currentDateTime");
          return const LoginScreen();
        }
        final userModel = snapshot.data!;
        if (kDebugMode) print("User Model: role=${userModel.role}, verified=${userModel.verified}, uid=${user.uid} at $currentDateTime");
        if (userModel.role.toLowerCase() == 'admin' && userModel.verified) {
          if (kDebugMode) print("Navigating to AdminScreen for uid=${user.uid} at $currentDateTime");
          return const AdminScreen();
        }
        if (userModel.role.toLowerCase() == 'traveler') {
          if (kDebugMode) print("Navigating to TravelerDashboardScreen for uid=${user.uid} at $currentDateTime");
          return const TravelerDashboardScreen();
        }
        if (kDebugMode) print("Navigating to ProfileScreen for uid=${user.uid} at $currentDateTime");
        return const ProfileScreen();
      },
    );
  }
}