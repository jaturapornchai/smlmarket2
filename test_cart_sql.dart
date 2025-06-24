import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // อ่าน SQL file
  final sqlContent = '''
-- ลบตารางเดิม (เรียงลำดับตาม Foreign Key)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;

-- สร้างตาราง carts (ตระกร้าหลัก)
CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    total_items DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index สำหรับการค้นหาตะกร้าของลูกค้า
CREATE INDEX idx_carts_customer_status ON carts(customer_id, status);
CREATE INDEX idx_carts_status ON carts(status);

-- สร้างตาราง cart_items (สินค้าในตระกร้า)
CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    ic_code VARCHAR(50) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1.00 CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    CONSTRAINT unique_cart_item UNIQUE(cart_id, ic_code, unit_code, unit_price)
);

-- Index สำหรับประสิทธิภาพ
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_ic_code ON cart_items(ic_code);

SELECT 'Cart tables created successfully!' as result;
  ''';

  try {
    print('🚀 กำลังรัน SQL script ผ่าน API...');

    final response = await dio.post(
      '/pgcommand',
      data: {'query': sqlContent},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ Response Status: ${response.statusCode}');
    print('📄 Response Data: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print('🎉 SQL script รันสำเร็จ!');
      print('📋 Result: ${response.data['data']}');
    } else {
      print('❌ เกิดข้อผิดพลาด: ${response.data}');
    }
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('📄 Response: ${e.response?.data}');
    }
  }
}
