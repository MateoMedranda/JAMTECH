import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'providers/photo_provider.dart';
import 'providers/message_provider.dart';
import 'routes/app_routes.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController()..restoreSession(),
        ),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthController, ThemeProvider>(
        builder: (context, authController, themeProvider, _) {
          return MaterialApp(
            title: 'JAMTECH',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light, // DeUna usa solo modo claro
            home: authController.isLoggedIn
                ? const HomeView()
                : const LoginView(),
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}
