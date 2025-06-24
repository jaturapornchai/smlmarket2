import 'package:equatable/equatable.dart';

import 'order_item_model.dart';

/// โมเดลสินค้าในตระกร้า - เก็บข้อมูลสินค้าแต่ละชิ้นในตระกร้า
class CartItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในตระกร้า
  final int cartId; // รหัสตระกร้า (FK)
  final String icCode; // รหัสสินค้า (FK) - ใช้ ic_code แทน product_id
  final String? barcode; // บาร์โค้ดสินค้า
  final String? unitCode; // รหัสหน่วยสินค้า
  final double quantity; // จำนวนสินค้า
  final double? unitPrice; // ราคาต่อหน่วย
  final double? totalPrice; // ราคารวม
  final DateTime? createdAt; // วันที่เพิ่มเข้าตระกร้า
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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toInt(),
      cartId: json['cart_id']?.toInt() ?? 0,
      icCode: json['ic_code']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      unitCode: json['unit_code']?.toString(),
      quantity: _parseDouble(json['quantity']) ?? 1.0,
      unitPrice: _parseDouble(json['unit_price']),
      totalPrice: _parseDouble(json['total_price']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Helper method to safely parse double from various types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'ic_code': icCode,
      'barcode': barcode,
      'unit_code': unitCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

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
