import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'firebase_options.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MotologApp(),
    ),
  );
}

class MotologApp extends StatelessWidget {
  const MotologApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motolog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.accent,
          surface: AppColors.surface,
          onSurface: AppColors.text,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  // Use currentUser synchronously for the initial state — avoids waiting on
  // the Pigeon auth-state channel before showing anything.
  bool _signedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _signedIn = user != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().clear();
      });
      return const LoginScreen();
    }
    return _AppLoader(user: FirebaseAuth.instance.currentUser!);
  }
}

class _AppLoader extends StatefulWidget {
  final User user;
  const _AppLoader({required this.user});

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen();
  }
}
