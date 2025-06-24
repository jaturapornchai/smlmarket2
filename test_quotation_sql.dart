import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // SQL script สำหรับ quotation system
  final sqlContent = '''
-- สร้างตาราง quotations (ใบขอยืนยันราคาและขอยืนยันจำนวนหลัก)
CREATE TABLE IF NOT EXISTS quotations (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    quotation_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(30) DEFAULT 'pending' NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    total_items DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    original_total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    notes TEXT,
    seller_notes TEXT,
    expires_at TIMESTAMP,
    confirmed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_quotations_cart FOREIGN KEY (cart_id) REFERENCES carts(id)
);

-- สร้างตาราง quotation_items (รายการสินค้าในใบขอยืนยันราคา)
CREATE TABLE IF NOT EXISTS quotation_items (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER NOT NULL,
    ic_code VARCHAR(50) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    
    original_quantity DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    original_unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    original_total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    requested_quantity DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    requested_unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    requested_total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    offered_quantity DECIMAL(10,2),
    offered_unit_price DECIMAL(10,2),
    offered_total_price DECIMAL(10,2),
    
    final_quantity DECIMAL(10,2),
    final_unit_price DECIMAL(10,2),
    final_total_price DECIMAL(10,2),
    
    status VARCHAR(20) DEFAULT 'active' NOT NULL,
    item_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_quotation_items_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE
);

-- สร้างตาราง quotation_negotiations (ประวัติการต่อรองราคา)
CREATE TABLE IF NOT EXISTS quotation_negotiations (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER NOT NULL,
    quotation_item_id INTEGER,
    negotiation_type VARCHAR(20) NOT NULL,
    from_role VARCHAR(20) NOT NULL,
    to_role VARCHAR(20) NOT NULL,
    proposed_quantity DECIMAL(10,2),
    proposed_unit_price DECIMAL(10,2),
    proposed_total_price DECIMAL(10,2),
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending' NOT NULL,
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_quotation_negotiations_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE,
    CONSTRAINT fk_quotation_negotiations_item FOREIGN KEY (quotation_item_id) REFERENCES quotation_items(id) ON DELETE CASCADE
);

-- สร้าง Index สำหรับประสิทธิภาพ
CREATE INDEX IF NOT EXISTS idx_quotations_customer_status ON quotations(customer_id, status);
CREATE INDEX IF NOT EXISTS idx_quotations_cart_id ON quotations(cart_id);
CREATE INDEX IF NOT EXISTS idx_quotation_items_quotation_id ON quotation_items(quotation_id);
CREATE INDEX IF NOT EXISTS idx_quotation_negotiations_quotation_id ON quotation_negotiations(quotation_id);

SELECT 'Quotation system tables created successfully!' as result;
  ''';

  try {
    print('🚀 กำลังรัน Quotation SQL script ผ่าน API...');

    final response = await dio.post(
      '/pgcommand',
      data: {'query': sqlContent},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ Response Status: ${response.statusCode}');
    print('📄 Response Data: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print('🎉 Quotation SQL script รันสำเร็จ!');
      print('📋 Result: ${response.data['result']}');
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
