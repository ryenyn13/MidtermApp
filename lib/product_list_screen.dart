// file: product_list_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gk_app/add_product_screen.dart';
import 'package:gk_app/edit_product_screen.dart';
import 'database.dart'; // File chứa code kết nối của bạn
import 'product_model.dart'; // File model vừa nhắc ở trên

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Biến này để lưu danh sách sản phẩm tạm thời để hiển thị
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy dữ liệu ngay khi màn hình khởi tạo
    _productsFuture = MongoDatabase.getProducts();
  }

  // Hàm này để load lại danh sách sau khi thêm/sửa/xóa
  void _refreshProducts() {
    setState(() {
      _productsFuture = MongoDatabase.getProducts();
    });
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa sản phẩm ${product.tensp} không?",
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.pop(context); // Đóng thông báo

                // Gọi hàm xóa từ database
                bool success = await MongoDatabase.deleteProduct(
                  product.idsanpham,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(" Đã xóa sản phẩm!")),
                  );
                  _refreshProducts(); // Load lại danh sách sau khi xóa
                }
              },
            ),
          ],
        );
      },
    );
  }
  void _navigateToEditScreen(Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProductScreen(product: product),
    ),
  ).then((value) => _refreshProducts()); // Load lại danh sách sau khi sửa xong
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Danh sách sản phẩm"),
        backgroundColor: Colors.deepPurple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts, // Nút tải lại dữ liệu
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // 1. Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Có lỗi xảy ra
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // 3. Không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm nào."));
          }

          // 4. Có dữ liệu -> Hiển thị ListView
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển sang trang Thêm sản phẩm
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then(
            (value) => _refreshProducts(),
          ); // Khi quay lại thì tự động load lại danh sách
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Widget vẽ từng dòng sản phẩm ---
  Widget _buildProductItem(Product product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Phần hình ảnh (0.5 điểm)
       leading: Container(
          width: 70, // Đặt chiều rộng cho khung ảnh
          height: 70, // Đặt chiều cao
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8), // Làm bo góc ảnh cho đẹp
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8), // Bo góc cho bức ảnh bên trong
            // Gọi hàm hiển thị ảnh ở đây
            child: _buildProductImage(product.hinhanh), 
          ),
        ),
        // Tên sản phẩm
        title: Text(
          product.tensp,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // Loại và Giá
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Loại: ${product.loaisp}"),
            const SizedBox(height: 4),
            Text(
              "${product.gia.toStringAsFixed(0)} VNĐ",
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              // Gọi hàm hiện thông báo xác nhận xóa (hàm mình viết ở bước trước đó)
              _showDeleteDialog(product);
            } else if (value == 'edit') {
              // Gọi hàm chuyển sang trang Sửa (mình sẽ hướng dẫn làm trang này ngay dưới đây)
              _navigateToEditScreen(product);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text("Sửa"),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Xóa"),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildProductImage(String imageStr) {
    // 1. Nếu chuỗi rỗng: Hiển thị icon mặc định
    if (imageStr.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
    }

    // 2. Kiểm tra nếu là ảnh Base64
    if (imageStr.startsWith('data:image')) {
      // Phải cắt bỏ phần "data:image/jpeg;base64," ở đầu
      final base64String = imageStr.split(',').last; 
      try {
        final imageBytes = base64Decode(base64String); // Giải mã chuỗi
        return Image.memory(
          imageBytes, 
          fit: BoxFit.cover, // Căn ảnh cho vừa khung
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.red), // Lỗi khi vẽ ảnh
        );
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.grey); // Lỗi khi giải mã
      }
    }

    // 3. Nếu là link mạng (URL)
    if (imageStr.startsWith('http')) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        // Hiển thị vòng xoay khi đang tải ảnh
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        // Hiển thị icon lỗi nếu link ảnh hỏng
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // 4. Nếu là chuỗi lạ, không nhận dạng được
    return const Icon(Icons.image_search, color: Colors.grey);
  }
}