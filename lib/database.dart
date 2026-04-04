import 'package:mongo_dart/mongo_dart.dart';
import 'package:gk_app/product_model.dart';

class MongoDatabase {
  static const String mongoUrl = "mongodb+srv://nhinty23itb:1234@giuaky.opyprmd.mongodb.net/?appName=GiuaKy";
  static late Db db;

  static Future<void> connect() async {
    db = await Db.create(mongoUrl);
    await db.open();
    print("Connected to MongoDB!");
  }

  static DbCollection getCollection(String collectionName) {
    return db.collection(collectionName);
  }

  static Future<void> close() async {
    await db.close();
  }
// 1. Hàm THÊM sản phẩm
  static Future<bool> insertProduct(Product product) async {
    try {
      var collection = getCollection('sanpham'); // 'sanpham' là tên collection (bảng) trong MongoDB của bạn
      await collection.insert(product.toMap());
      print("Thêm sản phẩm thành công!");
      return true; // Trả về true nếu thành công để giao diện biết
    } catch (e) {
      print("Lỗi khi thêm: $e");
      return false;
    }
  }

  // 2. Hàm LẤY danh sách sản phẩm
  static Future<List<Product>> getProducts() async {
    try {
      var collection = getCollection('sanpham');
      // Lấy toàn bộ dữ liệu từ MongoDB (dạng Map)
      final productsMap = await collection.find().toList();
      
      // Chuyển đổi dữ liệu Map thành danh sách các đối tượng Product
      return productsMap.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      return []; // Lỗi thì trả về danh sách rỗng
    }
  }
  static Future<bool> deleteProduct(String id) async {
  try {
    var collection = getCollection('sanpham');
    // Tìm và xóa bản ghi có idsanpham khớp với id truyền vào
    await collection.remove(where.eq('idsanpham', id));
    print("Xóa thành công sản phẩm có ID: $id");
    return true;
  } catch (e) {
    print("Lỗi khi xóa: $e");
    return false;
  }
}
static Future<bool> updateProduct(Product product) async {
  try {
    var collection = getCollection('sanpham');
    // Tìm theo idsanpham và cập nhật các trường còn lại
    await collection.updateOne(
      where.eq('idsanpham', product.idsanpham),
      modify
        .set('tensp', product.tensp)
        .set('loaisp', product.loaisp)
        .set('gia', product.gia)
        .set('hinhanh', product.hinhanh),
    );
    return true;
  } catch (e) {
    print("Lỗi update: $e");
    return false;
  }
}
// 1. Hàm Đăng ký
static Future<bool> register(String user, String pass) async {
  try {
    var collection = db.collection('users');
    // Kiểm tra xem username đã tồn tại chưa
    var existingUser = await collection.findOne(where.eq('username', user));
    if (existingUser != null) return false; 

    await collection.insert({'username': user, 'password': pass});
    return true;
  } catch (e) {
    return false;
  }
}

// 2. Hàm Đăng nhập
static Future<bool> login(String user, String pass) async {
  try {
    var collection = db.collection('users');
    // Tìm user có cả username và password khớp
    var res = await collection.findOne(
      where.eq('username', user).and(where.eq('password', pass))
    );
    return res != null; 
  } catch (e) {
    return false;
  }
}
}
// 3. Hàm XÓA sản phẩm dựa trên idsanpham
