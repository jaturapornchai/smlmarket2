// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotationItem _$QuotationItemFromJson(Map<String, dynamic> json) =>
    QuotationItem(
      id: (json['id'] as num).toInt(),
      quotationId: (json['quotation_id'] as num).toInt(),
      icCode: json['ic_code'] as String,
      barcode: json['barcode'] as String?,
      unitCode: json['unit_code'] as String?,
      originalQuantity: const DoubleConverter().fromJson(
        json['original_quantity'],
      ),
      originalUnitPrice: const DoubleConverter().fromJson(
        json['original_unit_price'],
      ),
      originalTotalPrice: const DoubleConverter().fromJson(
        json['original_total_price'],
      ),
      requestedQuantity: const DoubleConverter().fromJson(
        json['requested_quantity'],
      ),
      requestedUnitPrice: const DoubleConverter().fromJson(
        json['requested_unit_price'],
      ),
      requestedTotalPrice: const DoubleConverter().fromJson(
        json['requested_total_price'],
      ),
      offeredQuantity: const NullableDoubleConverter().fromJson(
        json['offered_quantity'],
      ),
      offeredUnitPrice: const NullableDoubleConverter().fromJson(
        json['offered_unit_price'],
      ),
      offeredTotalPrice: const NullableDoubleConverter().fromJson(
        json['offered_total_price'],
      ),
      finalQuantity: const NullableDoubleConverter().fromJson(
        json['final_quantity'],
      ),
      finalUnitPrice: const NullableDoubleConverter().fromJson(
        json['final_unit_price'],
      ),
      finalTotalPrice: const NullableDoubleConverter().fromJson(
        json['final_total_price'],
      ),
      status:
          $enumDecodeNullable(_$QuotationItemStatusEnumMap, json['status']) ??
          QuotationItemStatus.active,
      itemNotes: json['item_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$QuotationItemToJson(QuotationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quotation_id': instance.quotationId,
      'ic_code': instance.icCode,
      'barcode': instance.barcode,
      'unit_code': instance.unitCode,
      'original_quantity': const DoubleConverter().toJson(
        instance.originalQuantity,
      ),
      'original_unit_price': const DoubleConverter().toJson(
        instance.originalUnitPrice,
      ),
      'original_total_price': const DoubleConverter().toJson(
        instance.originalTotalPrice,
      ),
      'requested_quantity': const DoubleConverter().toJson(
        instance.requestedQuantity,
      ),
      'requested_unit_price': const DoubleConverter().toJson(
        instance.requestedUnitPrice,
      ),
      'requested_total_price': const DoubleConverter().toJson(
        instance.requestedTotalPrice,
      ),
      'offered_quantity': const NullableDoubleConverter().toJson(
        instance.offeredQuantity,
      ),
      'offered_unit_price': const NullableDoubleConverter().toJson(
        instance.offeredUnitPrice,
      ),
      'offered_total_price': const NullableDoubleConverter().toJson(
        instance.offeredTotalPrice,
      ),
      'final_quantity': const NullableDoubleConverter().toJson(
        instance.finalQuantity,
      ),
      'final_unit_price': const NullableDoubleConverter().toJson(
        instance.finalUnitPrice,
      ),
      'final_total_price': const NullableDoubleConverter().toJson(
        instance.finalTotalPrice,
      ),
      'status': _$QuotationItemStatusEnumMap[instance.status]!,
      'item_notes': instance.itemNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$QuotationItemStatusEnumMap = {
  QuotationItemStatus.active: 'active',
  QuotationItemStatus.cancelled: 'cancelled',
};

QuotationNegotiation _$QuotationNegotiationFromJson(
  Map<String, dynamic> json,
) => QuotationNegotiation(
  id: (json['id'] as num).toInt(),
  quotationId: (json['quotation_id'] as num).toInt(),
  quotationItemId: (json['quotation_item_id'] as num?)?.toInt(),
  negotiationType: $enumDecode(
    _$NegotiationTypeEnumMap,
    json['negotiation_type'],
  ),
  fromRole: $enumDecode(_$NegotiationRoleEnumMap, json['from_role']),
  toRole: $enumDecode(_$NegotiationRoleEnumMap, json['to_role']),
  proposedQuantity: (json['proposed_quantity'] as num?)?.toDouble(),
  proposedUnitPrice: (json['proposed_unit_price'] as num?)?.toDouble(),
  proposedTotalPrice: (json['proposed_total_price'] as num?)?.toDouble(),
  message: json['message'] as String?,
  status:
      $enumDecodeNullable(_$NegotiationStatusEnumMap, json['status']) ??
      NegotiationStatus.pending,
  respondedAt: json['responded_at'] == null
      ? null
      : DateTime.parse(json['responded_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$QuotationNegotiationToJson(
  QuotationNegotiation instance,
) => <String, dynamic>{
  'id': instance.id,
  'quotation_id': instance.quotationId,
  'quotation_item_id': instance.quotationItemId,
  'negotiation_type': _$NegotiationTypeEnumMap[instance.negotiationType]!,
  'from_role': _$NegotiationRoleEnumMap[instance.fromRole]!,
  'to_role': _$NegotiationRoleEnumMap[instance.toRole]!,
  'proposed_quantity': instance.proposedQuantity,
  'proposed_unit_price': instance.proposedUnitPrice,
  'proposed_total_price': instance.proposedTotalPrice,
  'message': instance.message,
  'status': _$NegotiationStatusEnumMap[instance.status]!,
  'responded_at': instance.respondedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$NegotiationTypeEnumMap = {
  NegotiationType.price: 'price',
  NegotiationType.quantity: 'quantity',
  NegotiationType.both: 'both',
  NegotiationType.note: 'note',
};

const _$NegotiationRoleEnumMap = {
  NegotiationRole.customer: 'customer',
  NegotiationRole.seller: 'seller',
};

const _$NegotiationStatusEnumMap = {
  NegotiationStatus.pending: 'pending',
  NegotiationStatus.accepted: 'accepted',
  NegotiationStatus.rejected: 'rejected',
  NegotiationStatus.countered: 'countered',
};

Quotation _$QuotationFromJson(Map<String, dynamic> json) => Quotation(
  id: (json['id'] as num).toInt(),
  cartId: (json['cart_id'] as num).toInt(),
  customerId: (json['customer_id'] as num).toInt(),
  quotationNumber: json['quotation_number'] as String,
  status:
      $enumDecodeNullable(_$QuotationStatusEnumMap, json['status']) ??
      QuotationStatus.pending,
  totalAmount: const DoubleConverter().fromJson(json['total_amount']),
  totalItems: const DoubleConverter().fromJson(json['total_items']),
  originalTotalAmount: const DoubleConverter().fromJson(
    json['original_total_amount'],
  ),
  notes: json['notes'] as String?,
  sellerNotes: json['seller_notes'] as String?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  confirmedAt: json['confirmed_at'] == null
      ? null
      : DateTime.parse(json['confirmed_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => QuotationItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  negotiations:
      (json['negotiations'] as List<dynamic>?)
          ?.map((e) => QuotationNegotiation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$QuotationToJson(Quotation instance) => <String, dynamic>{
  'id': instance.id,
  'cart_id': instance.cartId,
  'customer_id': instance.customerId,
  'quotation_number': instance.quotationNumber,
  'status': _$QuotationStatusEnumMap[instance.status]!,
  'total_amount': const DoubleConverter().toJson(instance.totalAmount),
  'total_items': const DoubleConverter().toJson(instance.totalItems),
  'original_total_amount': const DoubleConverter().toJson(
    instance.originalTotalAmount,
  ),
  'notes': instance.notes,
  'seller_notes': instance.sellerNotes,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'confirmed_at': instance.confirmedAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'items': instance.items,
  'negotiations': instance.negotiations,
};

const _$QuotationStatusEnumMap = {
  QuotationStatus.pending: 'pending',
  QuotationStatus.confirmed: 'confirmed',
  QuotationStatus.cancelled: 'cancelled',
  QuotationStatus.negotiating: 'negotiating',
  QuotationStatus.completed: 'completed',
};
