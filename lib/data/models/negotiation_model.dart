import 'package:equatable/equatable.dart';

import 'quotation_enums.dart';

/// โมเดลสำหรับการต่อรองราคา
class NegotiationModel extends Equatable {
  final int? id;
  final int quotationId;
  final int? quotationItemId; // null หมายถึงต่อรองใบใบเสร็จทั้งใบ
  final int userId; // ผู้เสนอ
  final NegotiationRole role; // บทบาทของผู้เสนอ
  final NegotiationType type; // ประเภทการต่อรอง
  final double? proposedPrice; // ราคาที่เสนอ
  final double? proposedQuantity; // จำนวนที่เสนอ
  final String? message; // ข้อความ/หมายเหตุ
  final NegotiationStatus status; // สถานะการต่อรอง
  final int? parentNegotiationId; // การต่อรองที่ตอบกลับ
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt; // วันหมดอายุของข้อเสนอ

  const NegotiationModel({
    this.id,
    required this.quotationId,
    this.quotationItemId,
    required this.userId,
    required this.role,
    required this.type,
    this.proposedPrice,
    this.proposedQuantity,
    this.message,
    this.status = NegotiationStatus.pending,
    this.parentNegotiationId,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) {
    return NegotiationModel(
      id: json['id'] as int?,
      quotationId: json['quotation_id'] as int,
      quotationItemId: json['quotation_item_id'] as int?,
      userId: json['user_id'] as int,
      role: NegotiationRole.fromString(json['role'] as String? ?? 'customer'),
      type: NegotiationType.fromString(json['type'] as String? ?? 'note'),
      proposedPrice: (json['proposed_price'] as num?)?.toDouble(),
      proposedQuantity: (json['proposed_quantity'] as num?)?.toDouble(),
      message: json['message'] as String?,
      status: NegotiationStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      parentNegotiationId: json['parent_negotiation_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'quotation_item_id': quotationItemId,
      'user_id': userId,
      'role': role.value,
      'type': type.value,
      'proposed_price': proposedPrice,
      'proposed_quantity': proposedQuantity,
      'message': message,
      'status': status.value,
      'parent_negotiation_id': parentNegotiationId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  NegotiationModel copyWith({
    int? id,
    int? quotationId,
    int? quotationItemId,
    int? userId,
    NegotiationRole? role,
    NegotiationType? type,
    double? proposedPrice,
    double? proposedQuantity,
    String? message,
    NegotiationStatus? status,
    int? parentNegotiationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return NegotiationModel(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      quotationItemId: quotationItemId ?? this.quotationItemId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      type: type ?? this.type,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      proposedQuantity: proposedQuantity ?? this.proposedQuantity,
      message: message ?? this.message,
      status: status ?? this.status,
      parentNegotiationId: parentNegotiationId ?? this.parentNegotiationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// ตรวจสอบว่าการต่อรองหมดอายุหรือไม่
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// ตรวจสอบว่าสามารถตอบกลับได้หรือไม่
  bool get canRespond {
    return status == NegotiationStatus.pending && !isExpired;
  }

  /// ตรวจสอบว่าเป็นการต่อรองสำหรับสินค้าชิ้นเดียวหรือทั้งใบ
  bool get isItemSpecific => quotationItemId != null;

  @override
  List<Object?> get props => [
    id,
    quotationId,
    quotationItemId,
    userId,
    role,
    type,
    proposedPrice,
    proposedQuantity,
    message,
    status,
    parentNegotiationId,
    createdAt,
    updatedAt,
    expiresAt,
  ];
}

/// โมเดลสำหรับสร้างการต่อรองใหม่
class CreateNegotiationRequest extends Equatable {
  final int quotationId;
  final int? quotationItemId;
  final NegotiationType type;
  final double? proposedPrice;
  final double? proposedQuantity;
  final String? message;
  final int? expiresInHours; // จำนวนชั่วโมงที่ข้อเสนอจะหมดอายุ

  const CreateNegotiationRequest({
    required this.quotationId,
    this.quotationItemId,
    required this.type,
    this.proposedPrice,
    this.proposedQuantity,
    this.message,
    this.expiresInHours = 24, // ค่าเริ่มต้น 24 ชั่วโมง
  });

  factory CreateNegotiationRequest.fromJson(Map<String, dynamic> json) {
    return CreateNegotiationRequest(
      quotationId: json['quotation_id'] as int,
      quotationItemId: json['quotation_item_id'] as int?,
      type: NegotiationType.fromString(json['type'] as String? ?? 'note'),
      proposedPrice: (json['proposed_price'] as num?)?.toDouble(),
      proposedQuantity: (json['proposed_quantity'] as num?)?.toDouble(),
      message: json['message'] as String?,
      expiresInHours: json['expires_in_hours'] as int? ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotation_id': quotationId,
      'quotation_item_id': quotationItemId,
      'type': type.value,
      'proposed_price': proposedPrice,
      'proposed_quantity': proposedQuantity,
      'message': message,
      'expires_in_hours': expiresInHours,
    };
  }

  @override
  List<Object?> get props => [
    quotationId,
    quotationItemId,
    type,
    proposedPrice,
    proposedQuantity,
    message,
    expiresInHours,
  ];
}

/// โมเดลสำหรับตอบกลับการต่อรอง
class RespondNegotiationRequest extends Equatable {
  final int negotiationId;
  final NegotiationStatus response; // accepted, rejected, countered
  final double? counterPrice; // ใช้เมื่อ response = countered
  final double? counterQuantity; // ใช้เมื่อ response = countered
  final String? message;
  final int? expiresInHours;

  const RespondNegotiationRequest({
    required this.negotiationId,
    required this.response,
    this.counterPrice,
    this.counterQuantity,
    this.message,
    this.expiresInHours = 24,
  });

  factory RespondNegotiationRequest.fromJson(Map<String, dynamic> json) {
    return RespondNegotiationRequest(
      negotiationId: json['negotiation_id'] as int,
      response: NegotiationStatus.fromString(
        json['response'] as String? ?? 'pending',
      ),
      counterPrice: (json['counter_price'] as num?)?.toDouble(),
      counterQuantity: (json['counter_quantity'] as num?)?.toDouble(),
      message: json['message'] as String?,
      expiresInHours: json['expires_in_hours'] as int? ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'negotiation_id': negotiationId,
      'response': response.value,
      'counter_price': counterPrice,
      'counter_quantity': counterQuantity,
      'message': message,
      'expires_in_hours': expiresInHours,
    };
  }

  @override
  List<Object?> get props => [
    negotiationId,
    response,
    counterPrice,
    counterQuantity,
    message,
    expiresInHours,
  ];
}

/// สรุปการต่อรองของ quotation
class NegotiationSummary extends Equatable {
  final int quotationId;
  final int totalNegotiations;
  final int pendingNegotiations;
  final int acceptedNegotiations;
  final int rejectedNegotiations;
  final NegotiationModel? lastNegotiation;
  final bool canNegotiate; // สามารถต่อรองได้หรือไม่

  const NegotiationSummary({
    required this.quotationId,
    this.totalNegotiations = 0,
    this.pendingNegotiations = 0,
    this.acceptedNegotiations = 0,
    this.rejectedNegotiations = 0,
    this.lastNegotiation,
    this.canNegotiate = true,
  });

  factory NegotiationSummary.fromJson(Map<String, dynamic> json) {
    return NegotiationSummary(
      quotationId: json['quotation_id'] as int,
      totalNegotiations: json['total_negotiations'] as int? ?? 0,
      pendingNegotiations: json['pending_negotiations'] as int? ?? 0,
      acceptedNegotiations: json['accepted_negotiations'] as int? ?? 0,
      rejectedNegotiations: json['rejected_negotiations'] as int? ?? 0,
      lastNegotiation: json['last_negotiation'] != null
          ? NegotiationModel.fromJson(
              json['last_negotiation'] as Map<String, dynamic>,
            )
          : null,
      canNegotiate: json['can_negotiate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotation_id': quotationId,
      'total_negotiations': totalNegotiations,
      'pending_negotiations': pendingNegotiations,
      'accepted_negotiations': acceptedNegotiations,
      'rejected_negotiations': rejectedNegotiations,
      'last_negotiation': lastNegotiation?.toJson(),
      'can_negotiate': canNegotiate,
    };
  }

  @override
  List<Object?> get props => [
    quotationId,
    totalNegotiations,
    pendingNegotiations,
    acceptedNegotiations,
    rejectedNegotiations,
    lastNegotiation,
    canNegotiate,
  ];
}
