// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: (json['id'] as num?)?.toInt(),
      orderId: (json['order_id'] as num).toInt(),
      icCode: json['ic_code'] as String,
      productName: json['product_name'] as String,
      barcode: json['barcode'] as String?,
      unitCode: json['unit_code'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'ic_code': instance.icCode,
      'product_name': instance.productName,
      'barcode': instance.barcode,
      'unit_code': instance.unitCode,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
    };
