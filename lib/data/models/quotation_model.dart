import 'package:json_annotation/json_annotation.dart';
import 'quotation_enums.dart';

part 'quotation_model.g.dart';

/// Custom converter สำหรับแปลง dynamic เป็น double
class DoubleConverter implements JsonConverter<double, dynamic> {
  const DoubleConverter();

  @override
  double fromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double value) => value;
}

/// Custom converter สำหรับแปลง dynamic เป็น double?
class NullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const NullableDoubleConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

/// รายการสินค้าในใบขอยืนยันราคาและขอยืนยันจำนวน
@JsonSerializable()
class QuotationItem {
  final int id;
  @JsonKey(name: 'quotation_id')
  final int quotationId;
  @JsonKey(name: 'ic_code')
  final String icCode;
  final String? barcode;
  @JsonKey(name: 'unit_code')
  final String? unitCode;

  // ข้อมูลเดิมจากตะกร้า
  @JsonKey(name: 'original_quantity')
  @DoubleConverter()
  final double originalQuantity;
  @JsonKey(name: 'original_unit_price')
  @DoubleConverter()
  final double originalUnitPrice;
  @JsonKey(name: 'original_total_price')
  @DoubleConverter()
  final double originalTotalPrice;

  // ข้อมูลที่ลูกค้าขอ
  @JsonKey(name: 'requested_quantity')
  @DoubleConverter()
  final double requestedQuantity;
  @JsonKey(name: 'requested_unit_price')
  @DoubleConverter()
  final double requestedUnitPrice;
  @JsonKey(name: 'requested_total_price')
  @DoubleConverter()
  final double requestedTotalPrice;

  // ข้อมูลที่ผู้ขายเสนอ (ในกรณีต่อรอง)
  @JsonKey(name: 'offered_quantity')
  @NullableDoubleConverter()
  final double? offeredQuantity;
  @JsonKey(name: 'offered_unit_price')
  @NullableDoubleConverter()
  final double? offeredUnitPrice;
  @JsonKey(name: 'offered_total_price')
  @NullableDoubleConverter()
  final double? offeredTotalPrice;

  // ข้อมูลสุดท้ายที่ตกลงกัน
  @JsonKey(name: 'final_quantity')
  @NullableDoubleConverter()
  final double? finalQuantity;
  @JsonKey(name: 'final_unit_price')
  @NullableDoubleConverter()
  final double? finalUnitPrice;
  @JsonKey(name: 'final_total_price')
  @NullableDoubleConverter()
  final double? finalTotalPrice;

  final QuotationItemStatus status;
  @JsonKey(name: 'item_notes')
  final String? itemNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const QuotationItem({
    required this.id,
    required this.quotationId,
    required this.icCode,
    this.barcode,
    this.unitCode,
    required this.originalQuantity,
    required this.originalUnitPrice,
    required this.originalTotalPrice,
    required this.requestedQuantity,
    required this.requestedUnitPrice,
    required this.requestedTotalPrice,
    this.offeredQuantity,
    this.offeredUnitPrice,
    this.offeredTotalPrice,
    this.finalQuantity,
    this.finalUnitPrice,
    this.finalTotalPrice,
    this.status = QuotationItemStatus.active,
    this.itemNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) =>
      _$QuotationItemFromJson(json);

  Map<String, dynamic> toJson() => _$QuotationItemToJson(this);
}

/// ประวัติการต่อรอง
@JsonSerializable()
class QuotationNegotiation {
  final int id;
  @JsonKey(name: 'quotation_id')
  final int quotationId;
  @JsonKey(name: 'quotation_item_id')
  final int? quotationItemId;
  @JsonKey(name: 'negotiation_type')
  final NegotiationType negotiationType;
  @JsonKey(name: 'from_role')
  final NegotiationRole fromRole;
  @JsonKey(name: 'to_role')
  final NegotiationRole toRole;

  // ข้อมูลที่เสนอ
  @JsonKey(name: 'proposed_quantity')
  final double? proposedQuantity;
  @JsonKey(name: 'proposed_unit_price')
  final double? proposedUnitPrice;
  @JsonKey(name: 'proposed_total_price')
  final double? proposedTotalPrice;
  final String? message;

  final NegotiationStatus status;
  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const QuotationNegotiation({
    required this.id,
    required this.quotationId,
    this.quotationItemId,
    required this.negotiationType,
    required this.fromRole,
    required this.toRole,
    this.proposedQuantity,
    this.proposedUnitPrice,
    this.proposedTotalPrice,
    this.message,
    this.status = NegotiationStatus.pending,
    this.respondedAt,
    required this.createdAt,
  });

  factory QuotationNegotiation.fromJson(Map<String, dynamic> json) =>
      _$QuotationNegotiationFromJson(json);

  Map<String, dynamic> toJson() => _$QuotationNegotiationToJson(this);
}

/// ใบขอยืนยันราคาและขอยืนยันจำนวนหลัก
@JsonSerializable()
class Quotation {
  final int id;
  @JsonKey(name: 'cart_id')
  final int cartId;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'quotation_number')
  final String quotationNumber;
  final QuotationStatus status;
  @JsonKey(name: 'total_amount')
  @DoubleConverter()
  final double totalAmount;
  @JsonKey(name: 'total_items')
  @DoubleConverter()
  final double totalItems;
  @JsonKey(name: 'original_total_amount')
  @DoubleConverter()
  final double originalTotalAmount;
  final String? notes;
  @JsonKey(name: 'seller_notes')
  final String? sellerNotes;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'confirmed_at')
  final DateTime? confirmedAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // รายการสินค้า
  final List<QuotationItem> items;

  // ประวัติการต่อรอง
  final List<QuotationNegotiation> negotiations;

  const Quotation({
    required this.id,
    required this.cartId,
    required this.customerId,
    required this.quotationNumber,
    this.status = QuotationStatus.pending,
    required this.totalAmount,
    required this.totalItems,
    required this.originalTotalAmount,
    this.notes,
    this.sellerNotes,
    this.expiresAt,
    this.confirmedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.negotiations = const [],
  });

  factory Quotation.fromJson(Map<String, dynamic> json) =>
      _$QuotationFromJson(json);

  Map<String, dynamic> toJson() => _$QuotationToJson(this);
}

/// ข้อมูลสำหรับสร้างใบขอยืนยันราคาใหม่
class CreateQuotationRequest {
  final int cartId;
  final int customerId;
  final String? notes;
  final DateTime? expiresAt;
  final List<CreateQuotationItemRequest> items;

  const CreateQuotationRequest({
    required this.cartId,
    required this.customerId,
    this.notes,
    this.expiresAt,
    required this.items,
  });

  factory CreateQuotationRequest.fromJson(Map<String, dynamic> json) {
    return CreateQuotationRequest(
      cartId: json['cart_id'] as int,
      customerId: json['customer_id'] as int,
      notes: json['notes'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      items: (json['items'] as List)
          .map((item) => CreateQuotationItemRequest.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'customer_id': customerId,
      'notes': notes,
      'expires_at': expiresAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// ข้อมูลรายการสินค้าสำหรับสร้างใบขอยืนยัน
class CreateQuotationItemRequest {
  final String icCode;
  final String? barcode;
  final String? unitCode;
  final double originalQuantity;
  final double originalUnitPrice;
  final double originalTotalPrice;
  final double requestedQuantity;
  final double requestedUnitPrice;
  final double requestedTotalPrice;
  final String? itemNotes;

  const CreateQuotationItemRequest({
    required this.icCode,
    this.barcode,
    this.unitCode,
    required this.originalQuantity,
    required this.originalUnitPrice,
    required this.originalTotalPrice,
    required this.requestedQuantity,
    required this.requestedUnitPrice,
    required this.requestedTotalPrice,
    this.itemNotes,
  });

  factory CreateQuotationItemRequest.fromJson(Map<String, dynamic> json) {
    return CreateQuotationItemRequest(
      icCode: json['ic_code'] as String,
      barcode: json['barcode'] as String?,
      unitCode: json['unit_code'] as String?,
      originalQuantity: (json['original_quantity'] as num).toDouble(),
      originalUnitPrice: (json['original_unit_price'] as num).toDouble(),
      originalTotalPrice: (json['original_total_price'] as num).toDouble(),
      requestedQuantity: (json['requested_quantity'] as num).toDouble(),
      requestedUnitPrice: (json['requested_unit_price'] as num).toDouble(),
      requestedTotalPrice: (json['requested_total_price'] as num).toDouble(),
      itemNotes: json['item_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ic_code': icCode,
      'barcode': barcode,
      'unit_code': unitCode,
      'original_quantity': originalQuantity,
      'original_unit_price': originalUnitPrice,
      'original_total_price': originalTotalPrice,
      'requested_quantity': requestedQuantity,
      'requested_unit_price': requestedUnitPrice,
      'requested_total_price': requestedTotalPrice,
      'item_notes': itemNotes,
    };
  }
}

/// ข้อมูลสำหรับการต่อรอง
class CreateNegotiationRequest {
  final int quotationId;
  final int? quotationItemId;
  final NegotiationType negotiationType;
  final NegotiationRole fromRole;
  final NegotiationRole toRole;
  final double? proposedQuantity;
  final double? proposedUnitPrice;
  final double? proposedTotalPrice;
  final String? message;

  const CreateNegotiationRequest({
    required this.quotationId,
    this.quotationItemId,
    required this.negotiationType,
    required this.fromRole,
    required this.toRole,
    this.proposedQuantity,
    this.proposedUnitPrice,
    this.proposedTotalPrice,
    this.message,
  });

  factory CreateNegotiationRequest.fromJson(Map<String, dynamic> json) {
    return CreateNegotiationRequest(
      quotationId: json['quotation_id'] as int,
      quotationItemId: json['quotation_item_id'] as int?,
      negotiationType: NegotiationType.fromString(
        json['negotiation_type'] as String,
      ),
      fromRole: NegotiationRole.fromString(json['from_role'] as String),
      toRole: NegotiationRole.fromString(json['to_role'] as String),
      proposedQuantity: json['proposed_quantity'] != null
          ? (json['proposed_quantity'] as num).toDouble()
          : null,
      proposedUnitPrice: json['proposed_unit_price'] != null
          ? (json['proposed_unit_price'] as num).toDouble()
          : null,
      proposedTotalPrice: json['proposed_total_price'] != null
          ? (json['proposed_total_price'] as num).toDouble()
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotation_id': quotationId,
      'quotation_item_id': quotationItemId,
      'negotiation_type': negotiationType.value,
      'from_role': fromRole.value,
      'to_role': toRole.value,
      'proposed_quantity': proposedQuantity,
      'proposed_unit_price': proposedUnitPrice,
      'proposed_total_price': proposedTotalPrice,
      'message': message,
    };
  }
}

/// ข้อมูลสำหรับอัปเดตสถานะใบขอยืนยัน
class UpdateQuotationStatusRequest {
  final int quotationId;
  final QuotationStatus status;
  final String? sellerNotes;

  const UpdateQuotationStatusRequest({
    required this.quotationId,
    required this.status,
    this.sellerNotes,
  });

  factory UpdateQuotationStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateQuotationStatusRequest(
      quotationId: json['quotation_id'] as int,
      status: QuotationStatus.fromString(json['status'] as String),
      sellerNotes: json['seller_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotation_id': quotationId,
      'status': status.value,
      'seller_notes': sellerNotes,
    };
  }
}
