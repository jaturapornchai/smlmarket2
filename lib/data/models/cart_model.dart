import 'package:equatable/equatable.dart';

import 'cart_item_model.dart';
import 'order_model.dart';

/// สถานะของตระกร้าสินค้า
enum CartStatus {
  active, // กำลังใช้งาน
  completed, // สั่งซื้อแล้ว
  cancelled, // ยกเลิก
}

/// โมเดลตระกร้าสินค้า - เก็บข้อมูลตระกร้าหลักของผู้ใช้
class CartModel extends Equatable {
  final int? id; // รหัสตระกร้า
  final int? userId; // รหัสผู้ใช้
  final CartStatus status; // สถานะตระกร้า
  final double totalAmount; // จำนวนเงินรวม
  final int totalItems; // จำนวนสินค้าทั้งหมด
  final DateTime? createdAt; // วันที่สร้าง
  final DateTime? updatedAt; // วันที่แก้ไขล่าสุด

  const CartModel({
    this.id,
    this.userId,
    this.status = CartStatus.active,
    this.totalAmount = 0.0,
    this.totalItems = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id']?.toInt(),
      userId: json['user_id']?.toInt(),
      status: _parseStatus(json['status']),
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      totalItems: json['total_items']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status.name,
      'total_amount': totalAmount,
      'total_items': totalItems,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static CartStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return CartStatus.active;
      case 'completed':
        return CartStatus.completed;
      case 'cancelled':
        return CartStatus.cancelled;
      default:
        return CartStatus.active;
    }
  }

  CartModel copyWith({
    int? id,
    int? userId,
    CartStatus? status,
    double? totalAmount,
    int? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// แปลงตระกร้าเป็นคำสั่งซื้อ
  OrderModel toOrder({
    required String orderNumber,
    String? shippingAddress,
    String? paymentMethod,
    String? notes,
  }) {
    return OrderModel(
      cartId: id ?? 0,
      userId: userId ?? 0,
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      orderedAt: DateTime.now(),
    );
  }

  /// อัพเดทยอดรวมของตระกร้า
  CartModel updateTotals({required List<CartItemModel> items}) {
    final newTotalAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final newTotalItems = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return copyWith(
      totalAmount: newTotalAmount,
      totalItems: newTotalItems,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    totalAmount,
    totalItems,
    createdAt,
    updatedAt,
  ];
}
