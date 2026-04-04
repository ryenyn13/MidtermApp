import 'package:flutter/material.dart';
import 'database.dart';
import 'product_list_screen.dart';
import 'register_screen.dart'; // Tí nữa tạo file này sau

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _handleLogin() async {
    bool isSuccess = await MongoDatabase.login(_userController.text, _passController.text);
    if (isSuccess) {
      // Đăng nhập đúng thì vào trang danh sách sản phẩm
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ProductListScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _handleLogin, child: const Text("ĐĂNG NHẬP")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
              child: const Text("Chưa có tài khoản? Đăng ký ngay")
            )
          ],
        ),
      ),
    );
  }
}