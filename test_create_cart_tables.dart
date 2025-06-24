import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(minutes: 2);
  dio.options.receiveTimeout = const Duration(minutes: 2);

  try {
    print('🚀 Creating Cart system tables...');

    // SQL สำหรับสร้างตาราง carts และ cart_items
    final createTablesSql = '''
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
    
    -- Foreign Key
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    
    -- Unique constraint - ไม่ให้มีสินค้าเดียวกันซ้ำในตระกร้า
    CONSTRAINT unique_cart_item UNIQUE(cart_id, ic_code, unit_code, unit_price)
);

-- Index สำหรับประสิทธิภาพ
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_ic_code ON cart_items(ic_code);

SELECT 'Cart system tables created successfully!' as result;
    ''';

    final response = await dio.post(
      '/pgcommand',
      data: {'query': createTablesSql},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ Create Tables Status: ${response.statusCode}');
    print('📄 Create Tables Response: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print('🎉 Cart system tables created successfully!');

      // ทดสอบการใช้งานตาราง
      print('\n🧪 Testing table operations...');

      final testInsertSql = '''
INSERT INTO carts (customer_id, status, total_amount, total_items) 
VALUES (1, 'active', 0.00, 0) 
RETURNING id, customer_id, status, total_amount, total_items, created_at;
      ''';

      final insertResponse = await dio.post(
        '/pgcommand',
        data: {'query': testInsertSql},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('✅ Test Insert Status: ${insertResponse.statusCode}');
      print('📄 Test Insert Response: ${jsonEncode(insertResponse.data)}');
    }
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('📄 Response: ${e.response?.data}');
      print('📊 Status Code: ${e.response?.statusCode}');
    }
  }
}
