import 'package:auth_with_google/pages/login_pages.dart';
import 'package:auth_with_google/pages/welcome_home_page.dart';
import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeHomePage(),
        title: 'Auth with google and Apple Sing in',
       // initialRoute: '/login',
        routes: {
          '/login':(BuildContext context) => LoginPage(),
        },
      ),
    );
  }
}

