import 'package:equatable/equatable.dart';
import '../../data/models/quotation_model.dart';

/// Base state สำหรับ QuotationCubit
abstract class QuotationState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// สถานะเริ่มต้น
class QuotationInitial extends QuotationState {}

/// สถานะกำลังโหลดข้อมูล
class QuotationLoading extends QuotationState {}

/// สถานะโหลดรายการใบขอยืนยันราคาสำเร็จ
class QuotationLoaded extends QuotationState {
  final List<Quotation> quotations;

  QuotationLoaded(this.quotations);

  @override
  List<Object?> get props => [quotations];
}

/// สถานะโหลดรายละเอียดใบขอยืนยันราคาสำเร็จ
class QuotationDetailLoaded extends QuotationState {
  final Quotation quotation;

  QuotationDetailLoaded(this.quotation);

  @override
  List<Object?> get props => [quotation];
}

/// สถานะกำลังสร้างใบขอยืนยันราคา
class QuotationCreating extends QuotationState {}

/// สถานะสร้างใบขอยืนยันราคาสำเร็จ
class QuotationCreated extends QuotationState {
  final int quotationId;

  QuotationCreated(this.quotationId);

  @override
  List<Object?> get props => [quotationId];
}

/// สถานะกำลังส่งข้อเสนอการเจรจา
class QuotationNegotiating extends QuotationState {}

/// สถานะส่งข้อเสนอการเจรจาสำเร็จ
class QuotationNegotiationSent extends QuotationState {}

/// สถานะกำลังอัพเดทข้อมูล
class QuotationUpdating extends QuotationState {}

/// สถานะอัพเดทสถานะสำเร็จ
class QuotationStatusUpdated extends QuotationState {}

/// สถานะอัพเดทรายการสินค้าสำเร็จ
class QuotationItemUpdated extends QuotationState {}

/// สถานะอัพเดทหมายเหตุสำเร็จ
class QuotationNotesUpdated extends QuotationState {}

/// สถานะกำลังยืนยันใบขอยืนยันราคา
class QuotationConfirming extends QuotationState {}

/// สถานะยืนยันใบขอยืนยันราคาสำเร็จ
class QuotationConfirmed extends QuotationState {}

/// สถานะกำลังยกเลิกใบขอยืนยันราคา
class QuotationCancelling extends QuotationState {}

/// สถานะยกเลิกใบขอยืนยันราคาสำเร็จ
class QuotationCancelled extends QuotationState {}

/// สถานะเกิดข้อผิดพลาด
class QuotationError extends QuotationState {
  final String message;

  QuotationError(this.message);

  @override
  List<Object?> get props => [message];
}
