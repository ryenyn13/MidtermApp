import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo; // Tránh trùng tên với các class khác
import 'database.dart';
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
        const SnackBar(content: Text("✅ Đã cập nhật sản phẩm vào Database!")),
      );
      // Đóng màn hình thêm và quay về danh sách
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi rồi, không cập nhật được!")),
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
              TextField(controller: _idController, readOnly: true, decoration: const InputDecoration(labelText: "Mã sản phẩm (idsanpham)")),
              const SizedBox(height: 10),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên sản phẩm (tensp)")),
              const SizedBox(height: 10),
              TextField(controller: _typeController, decoration: const InputDecoration(labelText: "Loại sản phẩm (loaisp)")),
              const SizedBox(height: 10),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Giá (gia)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _imageController, decoration: const InputDecoration(labelText: "Link hình ảnh (hinhanh)")),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _updateData,
                child: const Text("LƯU VÀO DATABASE", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}