class Product {
  final String idsanpham; 
  final String tensp;
  final String loaisp;
  final double gia;
  final String hinhanh; 

  Product({
    required this.idsanpham,
    required this.tensp,
    required this.loaisp,
    required this.gia,
    required this.hinhanh,
  });

  Map<String, dynamic> toMap() {
    return {
      'idsanpham': idsanpham,
      'tensp': tensp,
      'loaisp': loaisp,
      'gia': gia,
      'hinhanh': hinhanh,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      idsanpham: map['idsanpham'] ?? '',
      tensp: map['tensp'] ?? '',
      loaisp: map['loaisp'] ?? '',
      gia: map['gia']?.toDouble() ?? 0.0,
      hinhanh: map['hinhanh'] ?? '',
    );
  }
}