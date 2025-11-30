import 'package:flutter/material.dart';
import 'package:secretpairapp/features/auth/presentation/pages/splash_page.dart';
import 'package:secretpairapp/features/pair/presentation/pages/create_pair_page.dart';
import 'package:secretpairapp/features/pair/presentation/pages/join_pair_page.dart';
import 'package:secretpairapp/features/chat/presentation/pages/chat_page.dart';
import 'package:secretpairapp/features/gallery/presentation/pages/secret_gallery_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String createPair = '/create-pair';
  static const String joinPair = '/join-pair';
  static const String chat = '/chat';
  static const String gallery = '/gallery';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      
      case createPair:
        return MaterialPageRoute(builder: (_) => const CreatePairPage());
      
      case joinPair:
        return MaterialPageRoute(builder: (_) => const JoinPairPage());
      
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatPage());
      
      case gallery:
        return MaterialPageRoute(builder: (_) => const SecretGalleryPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
