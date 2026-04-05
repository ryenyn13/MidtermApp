import 'package:flutter/material.dart';
import 'package:gk_app/database.dart';
import 'product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Bộ điều khiển cho các ô nhập liệu
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

 @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị cho các ô nhập liệu từ sản phẩm hiện tại
    _idController.text = widget.product.idsanpham;
    _nameController.text = widget.product.tensp;
    _typeController.text = widget.product.loaisp;
    _priceController.text = widget.product.gia.toString();
    _imageController.text = widget.product.hinhanh;

 
    // Lắng nghe sự thay đổi, mỗi khi bạn gõ hoặc paste link, nó sẽ báo app vẽ lại màn hình
    _imageController.addListener(() {
      setState(() {}); 
    });
  }

  // Hàm xử lý đẩy dữ liệu lên DB
  Future<void> _updateData() async {
    // 1. Lấy dữ liệu từ các ô nhập
    final id = _idController.text;
    final name = _nameController.text;
    final type = _typeController.text;
    final price = double.tryParse(_priceController.text) ?? 0;
    final image = _imageController.text;

    // Kiểm tra nhanh xem đã nhập đủ chưa
    if (id.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập ID và Tên sản phẩm!")),
      );
      return;
    }

    // 2. Tạo đối tượng Product mới
    final newProduct = Product(
      idsanpham: id,
      tensp: name,
      loaisp: type,
      gia: price,
      hinhanh: image,
    );

    // 3. Gọi hàm insert từ file mongodb.dart
    bool success = await MongoDatabase.updateProduct(newProduct);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã cập nhật sản phẩm vào Database!")),
      );
      // Đóng màn hình thêm và quay về danh sách
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không cập nhật được sản phẩm!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa Sản Phẩm")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _idController, readOnly: true, decoration: const InputDecoration(labelText: "Mã sản phẩm")),
              const SizedBox(height: 10),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên sản phẩm ")),
              const SizedBox(height: 10),
              TextField(controller: _typeController, decoration: const InputDecoration(labelText: "Loại sản phẩm ")),
              const SizedBox(height: 10),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Giá"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _imageController, decoration: const InputDecoration(labelText: "Link hình ảnh")),
              if (_imageController.text.isNotEmpty)
                Container(
                  height: 150, // Chiều cao khung ảnh
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageController.text,
                      fit: BoxFit.contain, // Giữ nguyên tỷ lệ ảnh
                      // Nếu link bị lỗi hoặc đang gõ dở, hiển thị dòng chữ này để không bị crash
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text("Đang chờ link ảnh hợp lệ...", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _updateData,
                child: const Text("LƯU", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}