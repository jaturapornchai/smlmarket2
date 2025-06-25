// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  id: (json['id'] as num?)?.toInt(),
  customerId: (json['customer_id'] as num?)?.toInt(),
  status: json['status'] == null
      ? CartStatus.active
      : const CartStatusConverter().fromJson(json['status'] as String),
  totalAmount: json['total_amount'] == null
      ? 0.0
      : const DoubleStringConverter().fromJson(json['total_amount']),
  totalItems: json['total_items'] == null
      ? 0.0
      : const DoubleStringConverter().fromJson(json['total_items']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'status': const CartStatusConverter().toJson(instance.status),
  'total_amount': const DoubleStringConverter().toJson(instance.totalAmount),
  'total_items': const DoubleStringConverter().toJson(instance.totalItems),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
