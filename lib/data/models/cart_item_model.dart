import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'order_item_model.dart';

part 'cart_item_model.g.dart';

/// Custom converter for numeric values that might come as strings
class NullableNumericConverter implements JsonConverter<double?, Object?> {
  const NullableNumericConverter();

  @override
  double? fromJson(Object? json) {
    if (json == null) return null;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) {
      return double.tryParse(json);
    }
    return null;
  }

  @override
  Object? toJson(double? object) => object;
}

/// Custom converter for non-nullable numeric values
class NumericConverter implements JsonConverter<double, Object?> {
  const NumericConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) return 0.0;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) {
      return double.tryParse(json) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Object toJson(double object) => object;
}

/// โมเดลสินค้าในตระกร้า - เก็บข้อมูลสินค้าแต่ละชิ้นในตระกร้า
@JsonSerializable()
class CartItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในตระกร้า
  @JsonKey(name: 'cart_id')
  final int cartId; // รหัสตระกร้า (FK)
  @JsonKey(name: 'ic_code')
  final String icCode; // รหัสสินค้า (FK) - ใช้ ic_code แทน product_id
  final String? barcode; // บาร์โค้ดสินค้า
  @JsonKey(name: 'unit_code')
  final String? unitCode; // รหัสหน่วยสินค้า
  @NumericConverter()
  final double quantity; // จำนวนสินค้า
  @JsonKey(name: 'unit_price')
  @NullableNumericConverter()
  final double? unitPrice; // ราคาต่อหน่วย
  @JsonKey(name: 'total_price')
  @NullableNumericConverter()
  final double? totalPrice; // ราคารวม
  @JsonKey(name: 'created_at')
  final DateTime? createdAt; // วันที่เพิ่มเข้าตระกร้า
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt; // วันที่แก้ไขล่าสุด

  const CartItemModel({
    this.id,
    required this.cartId,
    required this.icCode,
    this.barcode,
    this.unitCode,
    this.quantity = 1.0,
    this.unitPrice,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemModel copyWith({
    int? id,
    int? cartId,
    String? icCode,
    String? barcode,
    String? unitCode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      icCode: icCode ?? this.icCode,
      barcode: barcode ?? this.barcode,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity?.toDouble() ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get calculatedTotalPrice => quantity * (unitPrice ?? 0.0);

  CartItemModel updateQuantity(int newQuantity) {
    return copyWith(
      quantity: newQuantity,
      totalPrice: newQuantity * (unitPrice ?? 0.0),
      updatedAt: DateTime.now(),
    );
  }

  /// แปลงข้อมูลจาก CartItem เป็น OrderItem
  OrderItemModel toOrderItem(int orderId, String productName) {
    return OrderItemModel(
      orderId: orderId,
      icCode: icCode,
      productName: productName,
      barcode: barcode,
      unitCode: unitCode,
      quantity: quantity,
      unitPrice: unitPrice ?? 0.0,
      totalPrice: totalPrice ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cartId,
    icCode,
    barcode,
    unitCode,
    quantity,
    unitPrice,
    totalPrice,
    createdAt,
    updatedAt,
  ];
}
