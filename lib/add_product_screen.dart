import 'package:flutter/material.dart';
import 'database.dart';
import 'product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Bộ điều khiển cho các ô nhập liệu
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe mỗi khi gõ hoặc paste link thì vẽ lại màn hình
    _imageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    final id = _idController.text;
    final name = _nameController.text;
    final type = _typeController.text;
    final price = double.tryParse(_priceController.text) ?? 0;
    final image = _imageController.text;

    if (id.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập ID và Tên sản phẩm!")),
      );
      return;
    }

    final newProduct = Product(
      idsanpham: id,
      tensp: name,
      loaisp: type,
      gia: price,
      hinhanh: image,
    );

    bool success = await MongoDatabase.insertProduct(newProduct);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm sản phẩm vào Database!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thêm được sản phẩm!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Sản Phẩm Mới")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _idController, decoration: const InputDecoration(labelText: "Mã sản phẩm")),
              const SizedBox(height: 10),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên sản phẩm")),
              const SizedBox(height: 10),
              TextField(controller: _typeController, decoration: const InputDecoration(labelText: "Loại sản phẩm")),
              const SizedBox(height: 10),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Giá sản phẩm (VNĐ)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _imageController, decoration: const InputDecoration(labelText: "Link hình ảnh")),
              
              const SizedBox(height: 15), 
              
              // KHU VỰC HIỆN ẢNH XEM TRƯỚC
              if (_imageController.text.isNotEmpty)
                Container(
                  height: 150, 
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
                      fit: BoxFit.contain, 
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text("Đang chờ link ảnh hợp lệ...", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _insertData,
                child: const Text("LƯU", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}