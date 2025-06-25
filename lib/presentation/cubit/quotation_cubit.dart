import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/quotation_api_data_source.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import 'quotation_state.dart';

/// Cubit สำหรับจัดการสถานะของระบบใบขอยืนยันราคาและขอยืนยันจำนวน
class QuotationCubit extends Cubit<QuotationState> {
  final QuotationApiDataSource _dataSource;

  QuotationCubit(this._dataSource) : super(QuotationInitial());

  /// โหลดรายการใบขอยืนยันราคาของลูกค้า
  Future<void> loadQuotations(int customerId) async {
    print('🔍 [QUOTATION_CUBIT] Loading quotations for customer: $customerId');
    emit(QuotationLoading());
    try {
      final quotations = await _dataSource.getQuotationsByCustomer(customerId);
      print('✅ [QUOTATION_CUBIT] Loaded ${quotations.length} quotations');
      emit(QuotationLoaded(quotations));
    } catch (e) {
      print('❌ [QUOTATION_CUBIT] Error loading quotations: $e');
      emit(QuotationError('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'));
    }
  }

  /// โหลดรายละเอียดใบขอยืนยันราคา
  Future<void> loadQuotationDetails(int quotationId) async {
    emit(QuotationLoading());
    try {
      final quotation = await _dataSource.getQuotationWithDetails(quotationId);
      if (quotation != null) {
        emit(QuotationDetailLoaded(quotation));
      } else {
        emit(QuotationError('ไม่พบข้อมูลใบขอยืนยันราคา'));
      }
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการโหลดรายละเอียด: $e'));
    }
  }

  /// สร้างใบขอยืนยันราคาใหม่
  Future<void> createQuotation(
    Quotation quotation,
    List<QuotationItem> items,
  ) async {
    print('🔍 [QUOTATION_CUBIT] Creating quotation with ${items.length} items');
    emit(QuotationCreating());
    try {
      // สร้างใบขอยืนยันราคา
      print('📝 [QUOTATION_CUBIT] Step 1: Creating quotation...');
      final quotationId = await _dataSource.createQuotation(quotation);
      print('✅ [QUOTATION_CUBIT] Step 1 completed: Quotation ID $quotationId');

      // เพิ่มรายการสินค้า
      print('📦 [QUOTATION_CUBIT] Step 2: Creating ${items.length} items...');
      await _dataSource.createQuotationItems(quotationId, items);
      print('✅ [QUOTATION_CUBIT] Step 2 completed: Items created');

      // โหลดข้อมูลใหม่
      print('🔍 [QUOTATION_CUBIT] Step 3: Loading quotation details...');
      await loadQuotationDetails(quotationId);
      print('✅ [QUOTATION_CUBIT] Step 3 completed: Details loaded');

      emit(QuotationCreated(quotationId));
      print('🎉 [QUOTATION_CUBIT] Quotation creation completed successfully');
    } catch (e) {
      print('❌ [QUOTATION_CUBIT] Error creating quotation: $e');
      emit(QuotationError('เกิดข้อผิดพลาดในการสร้างใบขอยืนยันราคา: $e'));
    }
  }

  /// ส่งข้อเสนอการเจรจา
  Future<void> createNegotiation(QuotationNegotiation negotiation) async {
    emit(QuotationNegotiating());
    try {
      await _dataSource.createNegotiation(negotiation);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(negotiation.quotationId);

      emit(QuotationNegotiationSent());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการส่งข้อเสนอ: $e'));
    }
  }

  /// อัพเดทสถานะใบขอยืนยันราคา
  Future<void> updateStatus(int quotationId, QuotationStatus status) async {
    emit(QuotationUpdating());
    try {
      await _dataSource.updateQuotationStatus(quotationId, status);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(quotationId);

      emit(QuotationStatusUpdated());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการอัพเดทสถานะ: $e'));
    }
  }

  /// อัพเดทรายการสินค้า
  Future<void> updateQuotationItem(QuotationItem item) async {
    emit(QuotationUpdating());
    try {
      await _dataSource.updateQuotationItem(item);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(item.quotationId);

      emit(QuotationItemUpdated());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการอัพเดทรายการสินค้า: $e'));
    }
  }

  /// ยืนยันใบขอยืนยันราคา
  Future<void> confirmQuotation(int quotationId) async {
    emit(QuotationConfirming());
    try {
      await _dataSource.confirmQuotation(quotationId);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(quotationId);

      emit(QuotationConfirmed());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการยืนยัน: $e'));
    }
  }

  /// ยกเลิกใบขอยืนยันราคา
  Future<void> cancelQuotation(int quotationId) async {
    emit(QuotationCancelling());
    try {
      await _dataSource.cancelQuotation(quotationId);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(quotationId);

      emit(QuotationCancelled());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการยกเลิก: $e'));
    }
  }

  /// อัพเดทหมายเหตุจากผู้ขาย
  Future<void> updateSellerNotes(int quotationId, String? notes) async {
    emit(QuotationUpdating());
    try {
      await _dataSource.updateSellerNotes(quotationId, notes);

      // โหลดข้อมูลใหม่
      await loadQuotationDetails(quotationId);

      emit(QuotationNotesUpdated());
    } catch (e) {
      emit(QuotationError('เกิดข้อผิดพลาดในการอัพเดทหมายเหตุ: $e'));
    }
  }

  /// รีเซ็ตสถานะเป็นเริ่มต้น
  void reset() {
    emit(QuotationInitial());
  }

  /// ล้างข้อผิดพลาด
  void clearError() {
    if (state is QuotationError) {
      emit(QuotationInitial());
    }
  }
}
