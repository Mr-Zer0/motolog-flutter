import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'screens/history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const HistoryScreen(),
    );
  }
}
