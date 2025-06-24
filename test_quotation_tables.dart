import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://smlgoapi.dedepos.com/v1';
  dio.options.connectTimeout = const Duration(minutes: 2);
  dio.options.receiveTimeout = const Duration(minutes: 2);

  try {
    print('🚀 Creating Quotation system tables...');

    // SQL สำหรับสร้างตาราง quotations
    final createQuotationsSql = '''
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

-- Index สำหรับการค้นหา quotations
CREATE INDEX IF NOT EXISTS idx_quotations_customer ON quotations(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotations_status ON quotations(status);
CREATE INDEX IF NOT EXISTS idx_quotations_cart ON quotations(cart_id);

SELECT 'Quotations table created successfully!' as result;
    ''';

    final response = await dio.post(
      '/pgcommand',
      data: {'query': createQuotationsSql},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print('✅ Create Quotations Status: ${response.statusCode}');
    print('📄 Create Quotations Response: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print('🎉 Quotations table created successfully!');

      // สร้างตาราง quotation_items
      print('\n🚀 Creating quotation_items table...');

      final createItemsSql = '''
-- สร้างตาราง quotation_items (รายการสินค้าในใบขอยืนยัน)
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

CREATE INDEX IF NOT EXISTS idx_quotation_items_quotation ON quotation_items(quotation_id);
CREATE INDEX IF NOT EXISTS idx_quotation_items_ic_code ON quotation_items(ic_code);

SELECT 'Quotation items table created successfully!' as result;
      ''';

      final itemsResponse = await dio.post(
        '/pgcommand',
        data: {'query': createItemsSql},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('✅ Create Items Status: ${itemsResponse.statusCode}');
      print('📄 Create Items Response: ${jsonEncode(itemsResponse.data)}');

      if (itemsResponse.statusCode == 200 &&
          itemsResponse.data['success'] == true) {
        print('🎉 Quotation items table created successfully!');

        // สร้างตาราง quotation_negotiations
        print('\n🚀 Creating quotation_negotiations table...');

        final createNegotiationsSql = '''
-- สร้างตาราง quotation_negotiations (ประวัติการต่อรอง)
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
    
    CONSTRAINT fk_negotiations_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE,
    CONSTRAINT fk_negotiations_item FOREIGN KEY (quotation_item_id) REFERENCES quotation_items(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_negotiations_quotation ON quotation_negotiations(quotation_id);
CREATE INDEX IF NOT EXISTS idx_negotiations_item ON quotation_negotiations(quotation_item_id);

SELECT 'Quotation negotiations table created successfully!' as result;
        ''';

        final negotiationsResponse = await dio.post(
          '/pgcommand',
          data: {'query': createNegotiationsSql},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        print(
          '✅ Create Negotiations Status: ${negotiationsResponse.statusCode}',
        );
        print(
          '📄 Create Negotiations Response: ${jsonEncode(negotiationsResponse.data)}',
        );

        if (negotiationsResponse.statusCode == 200 &&
            negotiationsResponse.data['success'] == true) {
          print('🎉 All quotation system tables created successfully!');

          // ทดสอบการทำงาน
          print('\n🧪 Testing quotation system...');

          final testQuotationSql = '''
INSERT INTO quotations (cart_id, customer_id, quotation_number, status, total_amount, total_items, original_total_amount, notes) 
VALUES (1, 1, 'QU-2025-000001', 'pending', 1500.00, 2, 1500.00, 'Test quotation')
RETURNING id, quotation_number, status, total_amount;
          ''';

          final testResponse = await dio.post(
            '/pgcommand',
            data: {'query': testQuotationSql},
            options: Options(headers: {'Content-Type': 'application/json'}),
          );

          print('✅ Test Quotation Status: ${testResponse.statusCode}');
          print('📄 Test Quotation Response: ${jsonEncode(testResponse.data)}');
        }
      }
    }
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('📄 Response: ${e.response?.data}');
      print('📊 Status Code: ${e.response?.statusCode}');
    }
  }
}
