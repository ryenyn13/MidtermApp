import 'package:flutter/material.dart';
import 'database.dart';
// import 'login_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _handleRegister() async {
    // 1. Kiểm tra xem có bỏ trống không
    if (_userController.text.trim().isEmpty || _passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Vui lòng nhập đầy đủ tài khoản và mật khẩu!"),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }

    // 2. Gửi dữ liệu lên Database
    bool isSuccess = await MongoDatabase.register(_userController.text, _passController.text);
    
    // 3. Fix lỗi "async gap"
    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Đăng ký thành công!"),
        )
      );
      // Đóng trang đăng ký và tự động lùi về trang đăng nhập
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Đăng ký thất bại! Tên tài khoản có thể đã tồn tại."),
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
                "ĐĂNG KÝ TÀI KHOẢN", 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Tạo tài khoản mới để quản lý hệ thống", 
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _userController, 
                decoration: InputDecoration(
                  labelText: "Tên đăng nhập mới",
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.deepPurple),
                  filled: true,
                  fillColor: const Color(0xFFFEF7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passController, 
                obscureText: true, 
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepPurple),
                  filled: true,
                  fillColor: const Color(0xFFFEF7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ), 
                child: const Text("TẠO TÀI KHOẢN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(

                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Đã có tài khoản? Đăng nhập ngay",
                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 120, 78, 191)),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}