import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/quotation_model.dart';
import '../models/quotation_enums.dart';

/// Data Source สำหรับการเรียก API ของระบบใบขอยืนยันราคา
class QuotationRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  QuotationRemoteDataSource({required Dio dio}) : _dio = dio;

  /// ดึงรายการใบขอยืนยันราคาของลูกค้า
  Future<List<Quotation>> getQuotations({
    required int customerId,
    QuotationStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('🔍 [API] Getting quotations for customer: $customerId');

      final response = await _dio.get(
        '/api/quotations',
        queryParameters: {
          'customer_id': customerId,
          if (status != null) 'status': status.value,
          'page': page,
          'limit': limit,
        },
      );

      _logger.d('✅ [API] Quotations response: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> quotationsData = response.data['data'] ?? [];
        return quotationsData.map((json) => Quotation.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get quotations');
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error getting quotations: ${e.message}');
      throw Exception('Failed to get quotations: ${e.message}');
    }
  }

  /// ดึงรายละเอียดใบขอยืนยันราคา
  Future<Quotation> getQuotationById(int quotationId) async {
    try {
      _logger.d('🔍 [API] Getting quotation by ID: $quotationId');

      final response = await _dio.get('/api/quotations/$quotationId');

      _logger.d('✅ [API] Quotation detail response: ${response.data}');

      if (response.data['success'] == true) {
        return Quotation.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get quotation');
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error getting quotation: ${e.message}');
      throw Exception('Failed to get quotation: ${e.message}');
    }
  }

  /// สร้างใบขอยืนยันราคาจากตะกร้า
  Future<Quotation> createQuotationFromCart(
    CreateQuotationRequest request,
  ) async {
    try {
      _logger.d('📝 [API] Creating quotation from cart: ${request.cartId}');

      final response = await _dio.post(
        '/api/quotations',
        data: request.toJson(),
      );

      _logger.d('✅ [API] Create quotation response: ${response.data}');

      if (response.data['success'] == true) {
        return Quotation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to create quotation',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error creating quotation: ${e.message}');
      throw Exception('Failed to create quotation: ${e.message}');
    }
  }

  /// อัปเดตสถานะใบขอยืนยันราคา
  Future<Quotation> updateQuotationStatus(
    UpdateQuotationStatusRequest request,
  ) async {
    try {
      _logger.d('🔄 [API] Updating quotation status: ${request.quotationId}');

      final response = await _dio.put(
        '/api/quotations/${request.quotationId}/status',
        data: request.toJson(),
      );

      _logger.d('✅ [API] Update status response: ${response.data}');

      if (response.data['success'] == true) {
        return Quotation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update quotation status',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error updating quotation status: ${e.message}');
      throw Exception('Failed to update quotation status: ${e.message}');
    }
  }

  /// ส่งข้อเสนอการต่อรองราคา
  Future<QuotationNegotiation> createNegotiation(
    CreateNegotiationRequest request,
  ) async {
    try {
      _logger.d(
        '💬 [API] Creating negotiation for quotation: ${request.quotationId}',
      );

      final response = await _dio.post(
        '/api/quotations/${request.quotationId}/negotiations',
        data: request.toJson(),
      );

      _logger.d('✅ [API] Create negotiation response: ${response.data}');

      if (response.data['success'] == true) {
        return QuotationNegotiation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to create negotiation',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error creating negotiation: ${e.message}');
      throw Exception('Failed to create negotiation: ${e.message}');
    }
  }

  /// ตอบกลับการต่อรอง (สำหรับผู้ขาย)
  Future<QuotationNegotiation> respondToNegotiation({
    required int negotiationId,
    required NegotiationStatus status,
    CreateNegotiationRequest? counterOffer,
  }) async {
    try {
      _logger.d('💬 [API] Responding to negotiation: $negotiationId');

      final response = await _dio.put(
        '/api/negotiations/$negotiationId/respond',
        data: {
          'status': status.value,
          if (counterOffer != null) 'counter_offer': counterOffer.toJson(),
        },
      );

      _logger.d('✅ [API] Respond negotiation response: ${response.data}');

      if (response.data['success'] == true) {
        return QuotationNegotiation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to respond to negotiation',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error responding to negotiation: ${e.message}');
      throw Exception('Failed to respond to negotiation: ${e.message}');
    }
  }

  /// ยกเลิกใบขอยืนยันราคา
  Future<Quotation> cancelQuotation(int quotationId, {String? reason}) async {
    try {
      _logger.d('🚫 [API] Cancelling quotation: $quotationId');

      final response = await _dio.put(
        '/api/quotations/$quotationId/cancel',
        data: {if (reason != null) 'reason': reason},
      );

      _logger.d('✅ [API] Cancel quotation response: ${response.data}');

      if (response.data['success'] == true) {
        return Quotation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to cancel quotation',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error cancelling quotation: ${e.message}');
      throw Exception('Failed to cancel quotation: ${e.message}');
    }
  }

  /// ยืนยันใบขอยืนยันราคา (สำหรับผู้ขาย)
  Future<Quotation> confirmQuotation(
    int quotationId, {
    String? sellerNotes,
  }) async {
    try {
      _logger.d('✅ [API] Confirming quotation: $quotationId');

      final response = await _dio.put(
        '/api/quotations/$quotationId/confirm',
        data: {if (sellerNotes != null) 'seller_notes': sellerNotes},
      );

      _logger.d('✅ [API] Confirm quotation response: ${response.data}');

      if (response.data['success'] == true) {
        return Quotation.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to confirm quotation',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error confirming quotation: ${e.message}');
      throw Exception('Failed to confirm quotation: ${e.message}');
    }
  }

  /// ดึงประวัติการต่อรองของใบขอยืนยัน
  Future<List<QuotationNegotiation>> getQuotationNegotiations(
    int quotationId,
  ) async {
    try {
      _logger.d('💬 [API] Getting negotiations for quotation: $quotationId');

      final response = await _dio.get(
        '/api/quotations/$quotationId/negotiations',
      );

      _logger.d('✅ [API] Negotiations response: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> negotiationsData = response.data['data'] ?? [];
        return negotiationsData
            .map((json) => QuotationNegotiation.fromJson(json))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get negotiations',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error getting negotiations: ${e.message}');
      throw Exception('Failed to get negotiations: ${e.message}');
    }
  }

  /// อัปเดตรายการสินค้าในใบขอยืนยัน
  Future<QuotationItem> updateQuotationItem({
    required int quotationId,
    required int itemId,
    double? quantity,
    double? unitPrice,
    String? notes,
  }) async {
    try {
      _logger.d('📝 [API] Updating quotation item: $itemId');

      final response = await _dio.put(
        '/api/quotations/$quotationId/items/$itemId',
        data: {
          if (quantity != null) 'quantity': quantity,
          if (unitPrice != null) 'unit_price': unitPrice,
          if (notes != null) 'notes': notes,
        },
      );

      _logger.d('✅ [API] Update item response: ${response.data}');

      if (response.data['success'] == true) {
        return QuotationItem.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update quotation item',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error updating quotation item: ${e.message}');
      throw Exception('Failed to update quotation item: ${e.message}');
    }
  }

  /// ลบรายการสินค้าจากใบขอยืนยัน
  Future<void> removeQuotationItem(int quotationId, int itemId) async {
    try {
      _logger.d('🗑️ [API] Removing quotation item: $itemId');

      final response = await _dio.delete(
        '/api/quotations/$quotationId/items/$itemId',
      );

      _logger.d('✅ [API] Remove item response: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to remove quotation item',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error removing quotation item: ${e.message}');
      throw Exception('Failed to remove quotation item: ${e.message}');
    }
  }

  /// ดึงสถิติใบขอยืนยันราคา
  Future<Map<String, dynamic>> getQuotationStats(int customerId) async {
    try {
      _logger.d('📊 [API] Getting quotation stats for customer: $customerId');

      final response = await _dio.get(
        '/api/quotations/stats',
        queryParameters: {'customer_id': customerId},
      );

      _logger.d('✅ [API] Stats response: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get quotation stats',
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [API] Error getting quotation stats: ${e.message}');
      throw Exception('Failed to get quotation stats: ${e.message}');
    }
  }
}
