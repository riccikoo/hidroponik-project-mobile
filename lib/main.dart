import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'services/shared_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await SharedService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Register App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? const DashboardPage() // 🔹 Langsung ke Dashboard jika sudah login
          : const RegisterPage(),  // 🔹 Kalau belum login, ke halaman Register
    );
  }
}
