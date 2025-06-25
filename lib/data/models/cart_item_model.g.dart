// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: (json['id'] as num?)?.toInt(),
      cartId: (json['cart_id'] as num).toInt(),
      icCode: json['ic_code'] as String,
      barcode: json['barcode'] as String?,
      unitCode: json['unit_code'] as String?,
      quantity: json['quantity'] == null
          ? 1.0
          : const NumericConverter().fromJson(json['quantity']),
      unitPrice: const NullableNumericConverter().fromJson(json['unit_price']),
      totalPrice: const NullableNumericConverter().fromJson(
        json['total_price'],
      ),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CartItemModelToJson(
  CartItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'cart_id': instance.cartId,
  'ic_code': instance.icCode,
  'barcode': instance.barcode,
  'unit_code': instance.unitCode,
  'quantity': const NumericConverter().toJson(instance.quantity),
  'unit_price': const NullableNumericConverter().toJson(instance.unitPrice),
  'total_price': const NullableNumericConverter().toJson(instance.totalPrice),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
