// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ar_customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArCustomerModel _$ArCustomerModelFromJson(Map<String, dynamic> json) =>
    ArCustomerModel(
      code: json['code'] as String,
      priceLevel: json['price_level'] as String?,
      rowOrderRef: (json['row_order_ref'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ArCustomerModelToJson(ArCustomerModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'price_level': instance.priceLevel,
      'row_order_ref': instance.rowOrderRef,
    };
