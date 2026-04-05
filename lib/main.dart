import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gk_app/login_screen.dart';
import 'database.dart';
import 'product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

void main() async {
  // Đảm bảo Flutter sẵn sàng trước khi gọi Database
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Sản Phẩm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = MongoDatabase.getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = MongoDatabase.getProducts();
    });
  }

 void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      // 1. ĐỔI TÊN context thành dialogContext ở đây:
      builder: (BuildContext dialogContext) { 
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc muốn xóa sản phẩm ${product.tensp} không?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              // 2. Dùng dialogContext để tắt hộp thoại
              onPressed: () => Navigator.pop(dialogContext), 
            ),
            TextButton(
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);

                Navigator.pop(dialogContext); 

                // 5. Chờ xóa database
                bool success = await MongoDatabase.deleteProduct(product.idsanpham);

                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Đã xóa sản phẩm thành công!")),
                  );
                  _refreshProducts(); // Load lại danh sách
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
    ).then((value) => _refreshProducts());
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
            onPressed: _refreshProducts,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm nào."));
          }

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((value) => _refreshProducts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildProductImage(product.hinhanh),
          ),
        ),
        title: Text(
          product.tensp,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
              _showDeleteDialog(product);
            } else if (value == 'edit') {
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
    if (imageStr.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    if (imageStr.startsWith('data:image')) {
      final base64String = imageStr.split(',').last;
      try {
        final imageBytes = base64Decode(base64String);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image, color: Colors.red),
        );
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.grey);
      }
    }

    if (imageStr.startsWith('http')) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, _, _) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return const Icon(Icons.image_search, color: Colors.grey);
  }
}
