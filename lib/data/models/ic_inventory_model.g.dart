// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ic_inventory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcInventoryModel _$IcInventoryModelFromJson(Map<String, dynamic> json) =>
    IcInventoryModel(
      code: json['code'] as String,
      name: json['name'] as String?,
      unitStandardCode: json['unit_standard_code'] as String?,
      itemType: (json['item_type'] as num?)?.toInt() ?? 0,
      rowOrderRef: (json['row_order_ref'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      qtyAvailable: (json['qty_available'] as num?)?.toDouble() ?? 0.0,
      imgUrl: json['img_url'] as String?,
      balanceQty: (json['balance_qty'] as num?)?.toDouble() ?? 0.0,
      soldQty: (json['sold_qty'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$IcInventoryModelToJson(IcInventoryModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'unit_standard_code': instance.unitStandardCode,
      'item_type': instance.itemType,
      'row_order_ref': instance.rowOrderRef,
      'price': instance.price,
      'sale_price': instance.salePrice,
      'final_price': instance.finalPrice,
      'discount_price': instance.discountPrice,
      'discount_percent': instance.discountPercent,
      'qty_available': instance.qtyAvailable,
      'img_url': instance.imgUrl,
      'balance_qty': instance.balanceQty,
      'sold_qty': instance.soldQty,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
