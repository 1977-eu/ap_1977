import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/auth_check.dart';
import 'pages/cadastro_motorista_page.dart';
import 'pages/consulta_motorista_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Motoristas TVDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Noto Sans',
        textTheme: const TextTheme().apply(
          fontFamily: 'Noto Sans',
          displayColor: Colors.black,
          bodyColor: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/home': (context) => const HomePage(),
        '/cadastro-motorista': (context) => const CadastroMotoristaPage(),
        '/consulta-motorista': (context) => const ConsultaMotoristaPage(),
      },
    );
  }
}
