import 'quotation_enums.dart';

/// รายการสินค้าในใบขอยืนยันราคาและขอยืนยันจำนวน
class QuotationItem {
  final int id;
  final int quotationId;
  final String icCode;
  final String? barcode;
  final String? unitCode;

  // ข้อมูลเดิมจากตะกร้า
  final double originalQuantity;
  final double originalUnitPrice;
  final double originalTotalPrice;

  // ข้อมูลที่ลูกค้าขอ
  final double requestedQuantity;
  final double requestedUnitPrice;
  final double requestedTotalPrice;

  // ข้อมูลที่ผู้ขายเสนอ (ในกรณีต่อรอง)
  final double? offeredQuantity;
  final double? offeredUnitPrice;
  final double? offeredTotalPrice;

  // ข้อมูลสุดท้ายที่ตกลงกัน
  final double? finalQuantity;
  final double? finalUnitPrice;
  final double? finalTotalPrice;

  final QuotationItemStatus status;
  final String? itemNotes;
  final DateTime createdAt;
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

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id'] as int,
      quotationId: json['quotation_id'] as int,
      icCode: json['ic_code'] as String,
      barcode: json['barcode'] as String?,
      unitCode: json['unit_code'] as String?,
      originalQuantity: (json['original_quantity'] as num).toDouble(),
      originalUnitPrice: (json['original_unit_price'] as num).toDouble(),
      originalTotalPrice: (json['original_total_price'] as num).toDouble(),
      requestedQuantity: (json['requested_quantity'] as num).toDouble(),
      requestedUnitPrice: (json['requested_unit_price'] as num).toDouble(),
      requestedTotalPrice: (json['requested_total_price'] as num).toDouble(),
      offeredQuantity: json['offered_quantity'] != null
          ? (json['offered_quantity'] as num).toDouble()
          : null,
      offeredUnitPrice: json['offered_unit_price'] != null
          ? (json['offered_unit_price'] as num).toDouble()
          : null,
      offeredTotalPrice: json['offered_total_price'] != null
          ? (json['offered_total_price'] as num).toDouble()
          : null,
      finalQuantity: json['final_quantity'] != null
          ? (json['final_quantity'] as num).toDouble()
          : null,
      finalUnitPrice: json['final_unit_price'] != null
          ? (json['final_unit_price'] as num).toDouble()
          : null,
      finalTotalPrice: json['final_total_price'] != null
          ? (json['final_total_price'] as num).toDouble()
          : null,
      status: QuotationItemStatus.fromString(
        json['status'] as String? ?? 'active',
      ),
      itemNotes: json['item_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'ic_code': icCode,
      'barcode': barcode,
      'unit_code': unitCode,
      'original_quantity': originalQuantity,
      'original_unit_price': originalUnitPrice,
      'original_total_price': originalTotalPrice,
      'requested_quantity': requestedQuantity,
      'requested_unit_price': requestedUnitPrice,
      'requested_total_price': requestedTotalPrice,
      'offered_quantity': offeredQuantity,
      'offered_unit_price': offeredUnitPrice,
      'offered_total_price': offeredTotalPrice,
      'final_quantity': finalQuantity,
      'final_unit_price': finalUnitPrice,
      'final_total_price': finalTotalPrice,
      'status': status.value,
      'item_notes': itemNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// ประวัติการต่อรอง
class QuotationNegotiation {
  final int id;
  final int quotationId;
  final int? quotationItemId;
  final NegotiationType negotiationType;
  final NegotiationRole fromRole;
  final NegotiationRole toRole;

  // ข้อมูลที่เสนอ
  final double? proposedQuantity;
  final double? proposedUnitPrice;
  final double? proposedTotalPrice;
  final String? message;

  final NegotiationStatus status;
  final DateTime? respondedAt;
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

  factory QuotationNegotiation.fromJson(Map<String, dynamic> json) {
    return QuotationNegotiation(
      id: json['id'] as int,
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
      status: NegotiationStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'quotation_item_id': quotationItemId,
      'negotiation_type': negotiationType.value,
      'from_role': fromRole.value,
      'to_role': toRole.value,
      'proposed_quantity': proposedQuantity,
      'proposed_unit_price': proposedUnitPrice,
      'proposed_total_price': proposedTotalPrice,
      'message': message,
      'status': status.value,
      'responded_at': respondedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// ใบขอยืนยันราคาและขอยืนยันจำนวนหลัก
class Quotation {
  final int id;
  final int cartId;
  final int customerId;
  final String quotationNumber;
  final QuotationStatus status;
  final double totalAmount;
  final double totalItems;
  final double originalTotalAmount;
  final String? notes;
  final String? sellerNotes;
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
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

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as int,
      cartId: json['cart_id'] as int,
      customerId: json['customer_id'] as int,
      quotationNumber: json['quotation_number'] as String,
      status: QuotationStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalItems: (json['total_items'] as num).toDouble(),
      originalTotalAmount: (json['original_total_amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      sellerNotes: json['seller_notes'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => QuotationItem.fromJson(item))
                .toList()
          : [],
      negotiations: json['negotiations'] != null
          ? (json['negotiations'] as List)
                .map((neg) => QuotationNegotiation.fromJson(neg))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'customer_id': customerId,
      'quotation_number': quotationNumber,
      'status': status.value,
      'total_amount': totalAmount,
      'total_items': totalItems,
      'original_total_amount': originalTotalAmount,
      'notes': notes,
      'seller_notes': sellerNotes,
      'expires_at': expiresAt?.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'negotiations': negotiations.map((neg) => neg.toJson()).toList(),
    };
  }
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
