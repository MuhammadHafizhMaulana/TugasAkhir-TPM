import 'package:flutter/material.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:royal_clothes/views/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:royal_clothes/views/home_page.dart';
import 'package:royal_clothes/views/category_page.dart';
import 'package:royal_clothes/views/landing_page.dart';
import 'package:royal_clothes/views/login_page.dart'; 
import 'package:royal_clothes/views/signup_page.dart';
import 'package:royal_clothes/views/favorite_page.dart';
import 'package:royal_clothes/views/kesan_saran_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // WAJIB sebelum SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Royal Clothes',
  theme: ThemeData(
    primarySwatch: Colors.amber,
    fontFamily: 'Garamond',
  ),
  initialRoute: isLoggedIn ? '/home' : '/',
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupPage());
      case '/category':
        return MaterialPageRoute(
          builder: (_) => CategoryPage(initialCategory: "women's clothing"),
        );
      case '/favorite':
        return MaterialPageRoute(builder: (_) => FavoritePage(endpoint: 'phones'));
      case '/kesan_saran':
        return MaterialPageRoute(builder: (_) => KesanSaranPage());
      case '/SettingsPage':
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case '/profile':
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProfilePage(email: email));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  },
);

  }
}
