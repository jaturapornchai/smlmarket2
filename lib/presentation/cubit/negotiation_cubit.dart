import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/models/negotiation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../data/repositories/negotiation_repository.dart';
import 'negotiation_state.dart';

class NegotiationCubit extends Cubit<NegotiationState> {
  final NegotiationRepository repository;
  final Logger logger;

  NegotiationCubit({required this.repository, required this.logger})
    : super(NegotiationInitial());

  /// ดึงรายการการต่อรองทั้งหมดสำหรับใบเสนอราคา
  Future<void> getNegotiations(int quotationId) async {
    try {
      emit(NegotiationLoading());
      logger.i('Fetching negotiations for quotation: $quotationId');

      final negotiations = await repository.getNegotiations(quotationId);
      final summary = await repository.getNegotiationSummary(quotationId);

      emit(NegotiationsLoaded(negotiations: negotiations, summary: summary));

      logger.i('Successfully loaded ${negotiations.length} negotiations');
    } catch (e) {
      logger.e('Error fetching negotiations: $e');
      emit(NegotiationError('ไม่สามารถดึงข้อมูลการต่อรองได้: $e'));
    }
  }

  /// ดึงสรุปการต่อรองแยกต่างหาก
  Future<void> getNegotiationSummary(int quotationId) async {
    try {
      emit(NegotiationSummaryLoading());
      logger.i('Fetching negotiation summary for quotation: $quotationId');

      final summary = await repository.getNegotiationSummary(quotationId);
      emit(NegotiationSummaryLoaded(summary));

      logger.i('Successfully loaded negotiation summary');
    } catch (e) {
      logger.e('Error fetching negotiation summary: $e');
      emit(NegotiationSummaryError('ไม่สามารถดึงข้อมูลสรุปการต่อรองได้: $e'));
    }
  }

  /// สร้างการต่อรองใหม่
  Future<void> createNegotiation({
    required int quotationId,
    int? quotationItemId,
    required NegotiationType type,
    double? proposedPrice,
    double? proposedQuantity,
    String? message,
    int? expiresInHours,
  }) async {
    try {
      emit(NegotiationLoading());
      logger.i('Creating negotiation for quotation: $quotationId');

      final request = CreateNegotiationRequest(
        quotationId: quotationId,
        quotationItemId: quotationItemId,
        type: type,
        proposedPrice: proposedPrice,
        proposedQuantity: proposedQuantity,
        message: message,
        expiresInHours: expiresInHours ?? 24,
      );

      final negotiation = await repository.createNegotiation(request);
      emit(NegotiationCreated(negotiation));

      logger.i('Successfully created negotiation: ${negotiation.id}');

      // โหลดข้อมูลใหม่หลังจากสร้างเสร็จ
      await getNegotiations(quotationId);
    } catch (e) {
      logger.e('Error creating negotiation: $e');
      emit(NegotiationError('ไม่สามารถสร้างการต่อรองได้: $e'));
    }
  }

  /// ตอบกลับการต่อรอง
  Future<void> respondToNegotiation({
    required int negotiationId,
    required NegotiationStatus response,
    double? counterPrice,
    double? counterQuantity,
    String? message,
    int? expiresInHours,
  }) async {
    try {
      emit(NegotiationLoading());
      logger.i('Responding to negotiation: $negotiationId');

      final request = RespondNegotiationRequest(
        negotiationId: negotiationId,
        response: response,
        counterPrice: counterPrice,
        counterQuantity: counterQuantity,
        message: message,
        expiresInHours: expiresInHours ?? 24,
      );

      final negotiation = await repository.respondToNegotiation(request);
      emit(NegotiationResponded(negotiation));

      logger.i('Successfully responded to negotiation: ${negotiation.id}');

      // โหลดข้อมูลใหม่หลังจากตอบกลับเสร็จ
      await getNegotiations(negotiation.quotationId);
    } catch (e) {
      logger.e('Error responding to negotiation: $e');
      emit(NegotiationError('ไม่สามารถตอบกลับการต่อรองได้: $e'));
    }
  }

  /// ยอมรับการต่อรอง
  Future<void> acceptNegotiation(int negotiationId, {String? message}) async {
    await respondToNegotiation(
      negotiationId: negotiationId,
      response: NegotiationStatus.accepted,
      message: message ?? 'ยอมรับข้อเสนอ',
    );
  }

  /// ปฏิเสธการต่อรอง
  Future<void> rejectNegotiation(int negotiationId, {String? message}) async {
    await respondToNegotiation(
      negotiationId: negotiationId,
      response: NegotiationStatus.rejected,
      message: message ?? 'ไม่ยอมรับข้อเสนอ',
    );
  }

  /// เสนอกลับ (Counter offer)
  Future<void> counterNegotiation({
    required int negotiationId,
    double? counterPrice,
    double? counterQuantity,
    String? message,
    int? expiresInHours,
  }) async {
    await respondToNegotiation(
      negotiationId: negotiationId,
      response: NegotiationStatus.countered,
      counterPrice: counterPrice,
      counterQuantity: counterQuantity,
      message: message ?? 'เสนอราคาใหม่',
      expiresInHours: expiresInHours,
    );
  }

  /// ปิดการต่อรอง
  Future<void> closeNegotiation(int negotiationId) async {
    try {
      emit(NegotiationLoading());
      logger.i('Closing negotiation: $negotiationId');

      await repository.closeNegotiation(negotiationId);
      emit(NegotiationClosed(negotiationId));

      logger.i('Successfully closed negotiation: $negotiationId');
    } catch (e) {
      logger.e('Error closing negotiation: $e');
      emit(NegotiationError('ไม่สามารถปิดการต่อรองได้: $e'));
    }
  }

  /// สร้างการต่อรองราคาสำหรับสินค้าเฉพาะ
  Future<void> negotiateItemPrice({
    required int quotationId,
    required int quotationItemId,
    required double proposedPrice,
    String? message,
  }) async {
    await createNegotiation(
      quotationId: quotationId,
      quotationItemId: quotationItemId,
      type: NegotiationType.price,
      proposedPrice: proposedPrice,
      message: message ?? 'ขอต่อรองราคาสินค้า',
    );
  }

  /// สร้างการต่อรองจำนวนสำหรับสินค้าเฉพาะ
  Future<void> negotiateItemQuantity({
    required int quotationId,
    required int quotationItemId,
    required double proposedQuantity,
    String? message,
  }) async {
    await createNegotiation(
      quotationId: quotationId,
      quotationItemId: quotationItemId,
      type: NegotiationType.quantity,
      proposedQuantity: proposedQuantity,
      message: message ?? 'ขอต่อรองจำนวนสินค้า',
    );
  }

  /// สร้างการต่อรองทั้งราคาและจำนวนสำหรับสินค้าเฉพาะ
  Future<void> negotiateItemBoth({
    required int quotationId,
    required int quotationItemId,
    double? proposedPrice,
    double? proposedQuantity,
    String? message,
  }) async {
    await createNegotiation(
      quotationId: quotationId,
      quotationItemId: quotationItemId,
      type: NegotiationType.both,
      proposedPrice: proposedPrice,
      proposedQuantity: proposedQuantity,
      message: message ?? 'ขอต่อรองราคาและจำนวนสินค้า',
    );
  }

  /// รีเซ็ตสถานะ
  void reset() {
    emit(NegotiationInitial());
  }

  /// ตรวจสอบว่าสามารถต่อรองได้หรือไม่
  bool canNegotiate(NegotiationSummary summary) {
    return summary.canNegotiate && summary.pendingNegotiations == 0;
  }

  /// หาการต่อรองล่าสุดที่รอการตอบกลับ
  NegotiationModel? getLatestPendingNegotiation(
    List<NegotiationModel> negotiations,
  ) {
    try {
      return negotiations
          .where((n) => n.status == NegotiationStatus.pending)
          .reduce(
            (a, b) =>
                (a.createdAt?.isAfter(b.createdAt ?? DateTime(1900)) ?? false)
                ? a
                : b,
          );
    } catch (e) {
      return null;
    }
  }
}
