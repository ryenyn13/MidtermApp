import 'package:flutter/material.dart';
import 'database.dart';
import 'main.dart';
import 'register_screen.dart'; 

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
    
    // Giữ an toàn cho màn hình sau khi đợi Database
    if (!mounted) return;

    if (isSuccess) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ProductListScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Sai tài khoản hoặc mật khẩu!"),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              const SizedBox(height: 15),
              const Text(
                "QUẢN LÝ SẢN PHẨM", 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
              
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Vui lòng đăng nhập để tiếp tục", 
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _userController, 
                decoration: InputDecoration(
                  labelText: "Tên đăng nhập",
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple), 
                  filled: true,
                  fillColor: const Color(0xFFFEF7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc tròn
                  ),
                )
              ),
              const SizedBox(height: 20), 

              TextField(
                controller: _passController, 
                obscureText: true, // Ẩn mật khẩu
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                  filled: true,
                  fillColor: Color(0xFFFEF7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, 
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(double.infinity, 55), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc nút
                  ),
                  elevation: 3, 
                ), 
                child: const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text(
                  "Chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 124, 83, 193)),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}