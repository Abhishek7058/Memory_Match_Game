import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/game_bloc.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final audioService = AudioService();
  final storageService = StorageService();
  final themeService = ThemeService();

  await audioService.init();
  await storageService.init();
  await themeService.init();

  runApp(MyApp(
    audioService: audioService,
    storageService: storageService,
    themeService: themeService,
  ));
}

class MyApp extends StatelessWidget {
  final AudioService audioService;
  final StorageService storageService;
  final ThemeService themeService;

  const MyApp({
    super.key,
    required this.audioService,
    required this.storageService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        BlocProvider(
          create: (context) => GameBloc(
            audioService: audioService,
            storageService: storageService,
          ),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Memory Match Game',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}


