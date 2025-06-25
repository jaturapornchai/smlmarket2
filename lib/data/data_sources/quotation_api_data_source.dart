import 'package:dio/dio.dart';
import '../models/quotation_model.dart';
import '../models/quotation_enums.dart';
import '../../utils/quotation_number_helper.dart';

class QuotationApiDataSource {
  final Dio _dio;

  QuotationApiDataSource(this._dio); // สร้างใบขอยืนยันราคาใหม่
  Future<int> createQuotation(Quotation quotation) async {
    try {
      // สร้างเลขที่ใบขอยืนยันราคาถ้ายังไม่มี
      final quotationNumber = quotation.quotationNumber.isEmpty
          ? QuotationNumberHelper.generateQuotationNumber()
          : quotation.quotationNumber;

      final query =
          '''
        INSERT INTO quotations (
          cart_id, customer_id, quotation_number, status, 
          total_amount, total_items, original_total_amount, notes
        ) VALUES (${quotation.cartId}, ${quotation.customerId}, '$quotationNumber', '${quotation.status.value}', 
                  ${quotation.totalAmount}, ${quotation.totalItems}, ${quotation.originalTotalAmount}, 
                  ${quotation.notes != null ? "'${quotation.notes}'" : 'NULL'}) 
        RETURNING id
      ''';

      final response = await _dio.post('/pgcommand', data: {'query': query});

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'];
        if (result != null && result.isNotEmpty) {
          return result[0]['id'] as int;
        }
      }
      throw Exception('Failed to create quotation');
    } catch (e) {
      throw Exception('Error creating quotation: $e');
    }
  }

  // สร้างรายการสินค้าในใบขอยืนยันราคา
  Future<void> createQuotationItems(
    int quotationId,
    List<QuotationItem> items,
  ) async {
    try {
      print(
        '🔍 [API] Creating ${items.length} quotation items for quotation ID: $quotationId',
      );

      for (final item in items) {
        print(
          '📦 [API] Creating item: ${item.icCode} x${item.originalQuantity}',
        );

        final query =
            '''
          INSERT INTO quotation_items (
            quotation_id, ic_code, barcode, unit_code,
            original_quantity, original_unit_price, original_total_price,
            requested_quantity, requested_unit_price, requested_total_price,
            status, item_notes
          ) VALUES ($quotationId, '${item.icCode}', 
                    ${item.barcode != null ? "'${item.barcode}'" : 'NULL'}, 
                    ${item.unitCode != null ? "'${item.unitCode}'" : 'NULL'},
                    ${item.originalQuantity}, ${item.originalUnitPrice}, ${item.originalTotalPrice},
                    ${item.requestedQuantity}, ${item.requestedUnitPrice}, ${item.requestedTotalPrice},
                    '${item.status.value}', 
                    ${item.itemNotes != null ? "'${item.itemNotes}'" : 'NULL'})
          RETURNING id
        ''';

        final response = await _dio.post('/pgcommand', data: {'query': query});
        print('📄 [API] Create item response: ${response.data}');

        if (response.statusCode != 200 || response.data['success'] != true) {
          throw Exception('Failed to create quotation item for ${item.icCode}');
        }
      }

      print('✅ [API] Successfully created all quotation items');
    } catch (e) {
      print('❌ [API] Error creating quotation items: $e');
      throw Exception('Error creating quotation items: $e');
    }
  }

  // ดึงรายการใบขอยืนยันราคาของลูกค้า
  Future<List<Quotation>> getQuotationsByCustomer(int customerId) async {
    try {
      print('🔍 [QUOTATION_API] Getting quotations for customer: $customerId');
      final query =
          '''
        SELECT q.*, 
               COUNT(qn.id) as negotiation_count,
               MAX(qn.created_at) as last_negotiation_date
        FROM quotations q
        LEFT JOIN quotation_negotiations qn ON q.id = qn.quotation_id
        WHERE q.customer_id = $customerId
        GROUP BY q.id
        ORDER BY q.created_at DESC
      ''';

      final response = await _dio.post('/pgselect', data: {'query': query});
      print('📄 [QUOTATION_API] Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        print('✅ [QUOTATION_API] Found ${data.length} quotations');
        return data.map((json) => Quotation.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch quotations');
    } catch (e) {
      print('❌ [QUOTATION_API] Error: $e');
      throw Exception('Error fetching quotations: $e');
    }
  }

  // ดึงรายละเอียดใบขอยืนยันราคา
  Future<Quotation?> getQuotationById(int quotationId) async {
    try {
      final query =
          '''
        SELECT * FROM quotations WHERE id = $quotationId
      ''';

      final response = await _dio.post('/pgselect', data: {'query': query});

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          return Quotation.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching quotation details: $e');
    }
  }

  // ดึงรายการสินค้าในใบขอยืนยันราคา
  Future<List<QuotationItem>> getQuotationItems(int quotationId) async {
    try {
      print('🔍 [API] Getting quotation items for quotation ID: $quotationId');
      final query =
          '''
        SELECT * FROM quotation_items 
        WHERE quotation_id = $quotationId
        ORDER BY id
      ''';

      final response = await _dio.post('/pgselect', data: {'query': query});
      print('📄 [API] Quotation items response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        print('✅ [API] Found ${data.length} quotation items');
        return data.map((json) => QuotationItem.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch quotation items');
    } catch (e) {
      throw Exception('Error fetching quotation items: $e');
    }
  }

  // ดึงประวัติการเจรจา
  Future<List<QuotationNegotiation>> getNegotiationHistory(
    int quotationId,
  ) async {
    try {
      final query =
          '''
        SELECT * FROM quotation_negotiations 
        WHERE quotation_id = $quotationId
        ORDER BY created_at DESC
      ''';

      final response = await _dio.post('/pgselect', data: {'query': query});

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => QuotationNegotiation.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch negotiation history');
    } catch (e) {
      throw Exception('Error fetching negotiation history: $e');
    }
  }

  // ส่งข้อเสนอการเจรจา
  Future<int> createNegotiation(QuotationNegotiation negotiation) async {
    try {
      print(
        '🔍 [API] Creating negotiation for quotation: ${negotiation.quotationId}',
      );

      final query =
          '''
        INSERT INTO quotation_negotiations (
          quotation_id, quotation_item_id, negotiation_type, 
          from_role, to_role, proposed_quantity, proposed_unit_price,
          proposed_total_price, message
        ) VALUES (${negotiation.quotationId}, 
                  ${negotiation.quotationItemId != null ? negotiation.quotationItemId : 'NULL'}, 
                  '${negotiation.negotiationType.value}',
                  '${negotiation.fromRole.value}', 
                  '${negotiation.toRole.value}', 
                  ${negotiation.proposedQuantity ?? 'NULL'}, 
                  ${negotiation.proposedUnitPrice ?? 'NULL'},
                  ${negotiation.proposedTotalPrice ?? 'NULL'}, 
                  ${negotiation.message != null ? "'${negotiation.message}'" : 'NULL'})
        RETURNING id
      ''';

      print('📄 [API] Negotiation query: $query');
      final response = await _dio.post('/pgcommand', data: {'query': query});
      print('📄 [API] Negotiation response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'];
        if (result != null && result.isNotEmpty) {
          final negotiationId = result[0]['id'] as int;
          print('✅ [API] Negotiation created with ID: $negotiationId');
          return negotiationId;
        }
      }
      throw Exception('Failed to create negotiation');
    } catch (e) {
      print('❌ [API] Error creating negotiation: $e');
      throw Exception('Error creating negotiation: $e');
    }
  }

  // อัพเดทสถานะใบขอยืนยันราคา
  Future<void> updateQuotationStatus(
    int quotationId,
    QuotationStatus status,
  ) async {
    try {
      final query =
          '''
        UPDATE quotations 
        SET status = '${status.value}', updated_at = CURRENT_TIMESTAMP
        WHERE id = $quotationId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error updating quotation status: $e');
    }
  }

  // อัพเดทราคารวมใบขอยืนยันราคา
  Future<void> updateQuotationAmount(int quotationId, double newAmount) async {
    try {
      final query =
          '''
        UPDATE quotations 
        SET total_amount = $newAmount, updated_at = CURRENT_TIMESTAMP
        WHERE id = $quotationId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error updating quotation amount: $e');
    }
  }

  // อัพเดทรายการสินค้าในใบขอยืนยันราคา
  Future<void> updateQuotationItem(QuotationItem item) async {
    try {
      final query =
          '''
        UPDATE quotation_items 
        SET requested_quantity = ${item.requestedQuantity}, 
            requested_unit_price = ${item.requestedUnitPrice}, 
            requested_total_price = ${item.requestedTotalPrice}, 
            offered_quantity = ${item.offeredQuantity},
            offered_unit_price = ${item.offeredUnitPrice}, 
            offered_total_price = ${item.offeredTotalPrice},
            final_quantity = ${item.finalQuantity}, 
            final_unit_price = ${item.finalUnitPrice}, 
            final_total_price = ${item.finalTotalPrice},
            status = '${item.status.value}', 
            item_notes = ${item.itemNotes != null ? "'${item.itemNotes}'" : 'NULL'}, 
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ${item.id}
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error updating quotation item: $e');
    }
  }

  // ยกเลิกรายการสินค้าในใบขอยืนยันราคา
  Future<void> cancelQuotationItem(int itemId) async {
    try {
      final query =
          '''
        UPDATE quotation_items 
        SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
        WHERE id = $itemId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error cancelling quotation item: $e');
    }
  }

  // อัพเดทข้อมูลที่ผู้ขายเสนอ
  Future<void> updateOfferedPrices(
    int itemId,
    double? offeredQuantity,
    double? offeredUnitPrice,
    double? offeredTotalPrice,
  ) async {
    try {
      final query =
          '''
        UPDATE quotation_items 
        SET offered_quantity = $offeredQuantity, 
            offered_unit_price = $offeredUnitPrice, 
            offered_total_price = $offeredTotalPrice, 
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $itemId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error updating offered prices: $e');
    }
  }

  // ยืนยันราคาและปิดการเจรจา
  Future<void> confirmQuotation(int quotationId) async {
    try {
      final query =
          '''
        UPDATE quotations 
        SET status = 'confirmed', confirmed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $quotationId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error confirming quotation: $e');
    }
  }

  // ยกเลิกใบขอยืนยันราคา
  Future<void> cancelQuotation(int quotationId) async {
    try {
      final query =
          '''
        UPDATE quotations 
        SET status = 'cancelled', cancelled_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $quotationId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error cancelling quotation: $e');
    }
  }

  // อัพเดทหมายเหตุจากผู้ขาย
  Future<void> updateSellerNotes(int quotationId, String? sellerNotes) async {
    try {
      final query =
          '''
        UPDATE quotations 
        SET seller_notes = ${sellerNotes != null ? "'$sellerNotes'" : 'NULL'}, 
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $quotationId
      ''';

      await _dio.post('/pgcommand', data: {'query': query});
    } catch (e) {
      throw Exception('Error updating seller notes: $e');
    }
  }

  // ดึงใบขอยืนยันราคาพร้อมรายการสินค้าและประวัติการเจรจา
  Future<Quotation?> getQuotationWithDetails(int quotationId) async {
    try {
      print('🔍 [API] Getting quotation with details for ID: $quotationId');

      // ดึงข้อมูลใบขอยืนยันราคา
      final quotation = await getQuotationById(quotationId);
      if (quotation == null) {
        print('❌ [API] Quotation not found');
        return null;
      }
      print('✅ [API] Base quotation loaded');

      // ดึงรายการสินค้า
      final items = await getQuotationItems(quotationId);
      print('✅ [API] Loaded ${items.length} items');

      // ดึงประวัติการเจรจา
      final negotiations = await getNegotiationHistory(quotationId);
      print('✅ [API] Loaded ${negotiations.length} negotiations');

      // สร้าง Quotation object ใหม่พร้อมข้อมูลครบถ้วน
      final result = Quotation(
        id: quotation.id,
        cartId: quotation.cartId,
        customerId: quotation.customerId,
        quotationNumber: quotation.quotationNumber,
        status: quotation.status,
        totalAmount: quotation.totalAmount,
        totalItems: quotation.totalItems,
        originalTotalAmount: quotation.originalTotalAmount,
        notes: quotation.notes,
        sellerNotes: quotation.sellerNotes,
        expiresAt: quotation.expiresAt,
        confirmedAt: quotation.confirmedAt,
        cancelledAt: quotation.cancelledAt,
        createdAt: quotation.createdAt,
        updatedAt: quotation.updatedAt,
        items: items,
        negotiations: negotiations,
      );

      print('✅ [API] Quotation with details created successfully');
      return result;
    } catch (e) {
      print('❌ [API] Error fetching quotation with details: $e');
      throw Exception('Error fetching quotation with details: $e');
    }
  }
}
