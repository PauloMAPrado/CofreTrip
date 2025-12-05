import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travelbox/stores/ConviteStore.dart';
import 'package:travelbox/stores/PerfilProvider.dart';
import 'package:travelbox/stores/cofreStore.dart';
import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/views/home.dart';
import 'package:travelbox/views/login.dart';
import 'package:travelbox/views/pageSplash.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/services/AuthService.dart';
import 'package:travelbox/services/firestoreService.dart';
import 'package:travelbox/services/authProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        Provider<AuthService>(
          create: (context) => AuthService(context.read<FirestoreService>()),
        ),

        ChangeNotifierProvider<AuthStore>(
          create: (context) => AuthStore(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),
        
        ChangeNotifierProvider<CofreStore>(
          create: (context) => CofreStore(
            context.read<FirestoreService>(),
          ),
        ),

        ChangeNotifierProvider<DetalhesCofreStore>(
          create: (context) => DetalhesCofreStore(
            context.read<FirestoreService>(),
          ),
        ),

        ChangeNotifierProvider<ConviteStore>(
          create: (context) => ConviteStore(
            context.read<FirestoreService>(),
          ),
        ),

        ChangeNotifierProvider<PerfilProvider>(
          create: (context) => PerfilProvider(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
        ),


      ],

      

      child: Consumer<AuthStore>(
        builder: (context, authStore, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _getTelaInicial(authStore.sessionStatus),
          );
        },
      ),
    );
  }

  Widget _getTelaInicial(SessionStatus status) {
    switch (status) {
      case SessionStatus.authenticated:
        return Home();
        case SessionStatus.unauthenticated:
          return Login(); // talvez vai mudar
        case SessionStatus.uninitialized:
          return TelaSplash();
        // ignore: unreachable_switch_default
        default:
          return TelaSplash();
    }
  }
}

