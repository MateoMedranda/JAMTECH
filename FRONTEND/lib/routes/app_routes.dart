import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/auth/reset_password_view.dart';
import '../views/home/home_view.dart';
import '../views/chatbot_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot_password';
  static const String resetPassword = '/reset_password';
  static const String chatbot = '/chatbot';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      home: (context) => const HomeView(),
      forgotPassword: (context) => const ForgotPasswordView(),
      resetPassword: (context) => const ResetPasswordView(),
      chatbot: (context) => const ChatbotView(),
    };
  }
}
