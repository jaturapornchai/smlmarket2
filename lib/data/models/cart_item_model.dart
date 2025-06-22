import 'package:equatable/equatable.dart';

import 'order_item_model.dart';

/// โมเดลสินค้าในตระกร้า - เก็บข้อมูลสินค้าแต่ละชิ้นในตระกร้า
class CartItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในตระกร้า
  final int cartId; // รหัสตระกร้า (FK)
  final int productId; // รหัสสินค้า (FK)
  final String? barcode; // บาร์โค้ดสินค้า
  final String? unitCode; // รหัสหน่วยสินค้า
  final int quantity; // จำนวนสินค้า
  final double unitPrice; // ราคาต่อหน่วย
  final double totalPrice; // ราคารวม
  final DateTime? addedAt; // วันที่เพิ่มเข้าตระกร้า
  final DateTime? updatedAt; // วันที่แก้ไขล่าสุด

  const CartItemModel({
    this.id,
    required this.cartId,
    required this.productId,
    this.barcode,
    this.unitCode,
    this.quantity = 1,
    required this.unitPrice,
    required this.totalPrice,
    this.addedAt,
    this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toInt(),
      cartId: json['cart_id']?.toInt() ?? 0,
      productId: json['product_id']?.toInt() ?? 0,
      barcode: json['barcode']?.toString(),
      unitCode: json['unit_code']?.toString(),
      quantity: json['quantity']?.toInt() ?? 1,
      unitPrice: json['unit_price']?.toDouble() ?? 0.0,
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'barcode': barcode,
      'unit_code': unitCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'added_at': addedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    int? id,
    int? cartId,
    int? productId,
    String? barcode,
    String? unitCode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      barcode: barcode ?? this.barcode,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get calculatedTotalPrice => quantity * unitPrice;

  CartItemModel updateQuantity(int newQuantity) {
    return copyWith(
      quantity: newQuantity,
      totalPrice: newQuantity * unitPrice,
      updatedAt: DateTime.now(),
    );
  }

  /// แปลงข้อมูลจาก CartItem เป็น OrderItem
  OrderItemModel toOrderItem(int orderId, String productName) {
    return OrderItemModel(
      orderId: orderId,
      productId: productId,
      productName: productName,
      barcode: barcode,
      unitCode: unitCode,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cartId,
    productId,
    barcode,
    unitCode,
    quantity,
    unitPrice,
    totalPrice,
    addedAt,
    updatedAt,
  ];
}
