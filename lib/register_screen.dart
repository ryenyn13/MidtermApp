import 'package:flutter/material.dart';
import 'database.dart';
import 'product_list_screen.dart';
import 'login_screen.dart'; // Tí nữa tạo file này sau

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _handleRegister() async {
    bool isSuccess = await MongoDatabase.register(_userController.text, _passController.text);
    if (isSuccess) {
      // Đăng ký thành công, chuyển đến trang đăng nhập
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại!")));
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
            const Text("ĐĂNG KÝ TÀI KHOẢN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _handleRegister, child: const Text("ĐĂNG KÝ")),
          ],
        ),
      ),
    );
  }
}

 