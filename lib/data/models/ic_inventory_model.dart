import 'package:json_annotation/json_annotation.dart';

part 'ic_inventory_model.g.dart';

@JsonSerializable()
class IcInventoryModel {
  final String code; // Primary Key
  final String? name;
  @JsonKey(name: 'unit_standard_code')
  final String? unitStandardCode;
  @JsonKey(name: 'item_type')
  final int itemType;
  @JsonKey(name: 'row_order_ref')
  final int rowOrderRef;
  final double price;
  @JsonKey(name: 'sale_price')
  final double? salePrice;
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  @JsonKey(name: 'discount_price')
  final double? discountPrice;
  @JsonKey(name: 'discount_percent')
  final double? discountPercent;
  @JsonKey(name: 'qty_available')
  final double qtyAvailable;
  @JsonKey(name: 'img_url')
  final String? imgUrl;
  @JsonKey(name: 'balance_qty')
  final double balanceQty;
  @JsonKey(name: 'sold_qty')
  final double soldQty;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const IcInventoryModel({
    required this.code,
    this.name,
    this.unitStandardCode,
    this.itemType = 0,
    this.rowOrderRef = 0,
    this.price = 0.0,
    this.salePrice,
    this.finalPrice,
    this.discountPrice,
    this.discountPercent,
    this.qtyAvailable = 0.0,
    this.imgUrl,
    this.balanceQty = 0.0,
    this.soldQty = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory IcInventoryModel.fromJson(Map<String, dynamic> json) =>
      _$IcInventoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$IcInventoryModelToJson(this);

  // For ProductModel compatibility
  factory IcInventoryModel.fromProductJson(Map<String, dynamic> json) {
    return IcInventoryModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString(),
      unitStandardCode: json['unit_standard_code']?.toString(),
      itemType: json['item_type']?.toInt() ?? 0,
      rowOrderRef: json['row_order_ref']?.toInt() ?? 0,
      price: _parseDouble(json['price']) ?? 0.0,
      salePrice: _parseDouble(json['sale_price']),
      finalPrice: _parseDouble(json['final_price']),
      discountPrice: _parseDouble(json['discount_price']),
      discountPercent: _parseDouble(json['discount_percent']),
      qtyAvailable: _parseDouble(json['qty_available']) ?? 0.0,
      imgUrl: json['img_url']?.toString(),
      balanceQty: _parseDouble(json['balance_qty']) ?? 0.0,
      soldQty: _parseDouble(json['sold_qty']) ?? 0.0,
      isActive: json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Convert to ProductModel for backward compatibility
  Map<String, dynamic> toProductJson() {
    return {
      'id': code,
      'code': code,
      'name': name,
      'unit_standard_code': unitStandardCode,
      'item_type': itemType,
      'row_order_ref': rowOrderRef,
      'price': price,
      'sale_price': salePrice,
      'final_price': finalPrice,
      'discount_price': discountPrice,
      'discount_percent': discountPercent,
      'qty_available': qtyAvailable,
      'img_url': imgUrl,
      'balance_qty': balanceQty,
      'sold_qty': soldQty,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'IcInventoryModel(code: $code, name: $name, price: $price, qtyAvailable: $qtyAvailable)';
  }
}
