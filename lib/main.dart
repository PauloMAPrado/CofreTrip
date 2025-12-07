import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travelbox/stores/ConviteStore.dart';
import 'package:travelbox/stores/PerfilStore.dart';
import 'package:travelbox/stores/cofreStore.dart';
import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/views/home.dart';
import 'package:travelbox/views/login.dart';
import 'package:travelbox/views/pageSplash.dart';
import 'package:travelbox/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/services/AuthService.dart';
import 'package:travelbox/stores/authStore.dart';
import 'package:travelbox/services/FirestoreService.dart';
import 'package:travelbox/stores/despesaStore.dart';

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
          create: (context) => CofreStore(context.read<FirestoreService>()),
        ),

        ChangeNotifierProvider<DetalhesCofreStore>(
          create: (context) =>
              DetalhesCofreStore(context.read<FirestoreService>()),
        ),

        ChangeNotifierProvider<ConviteStore>(
          create: (context) => ConviteStore(context.read<FirestoreService>()),
        ),

        ChangeNotifierProvider<PerfilStore>(
          create: (context) => PerfilStore(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
        ),

        ChangeNotifierProvider<DespesaProvider>(
          // Usa context.read<FirestoreService>() para injetar a dependência.
          create: (context) =>
              DespesaProvider(context.read<FirestoreService>()),
        ),
      ],

      child: Consumer<AuthStore>(
        builder: (context, authStore, _) {
          if (!authStore.isLoggedIn) {
            // Usamos um microtask para não dar erro de build
            Future.microtask(() {
              // Verifique se seus stores têm o método limparDados(). Se não tiverem, crie!
              // O CofreStore já tem. O ConviteStore e DetalhesCofreStore precisam ter.
              Provider.of<CofreStore>(context, listen: false).limparDados();
              Provider.of<ConviteStore>(context, listen: false).limparDados();
              Provider.of<DetalhesCofreStore>(
                context,
                listen: false,
              ).limparDados();
            });
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CofreTrip',
            theme: ThemeData(
              primaryColor: const Color(0xFF1E90FF),
              useMaterial3: true, // Modernizar o visual
            ),
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
