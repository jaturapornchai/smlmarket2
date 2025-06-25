import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cart_item_model.dart';
import 'order_model.dart';

part 'cart_model.g.dart';

/// Custom converter สำหรับ CartStatus
class CartStatusConverter implements JsonConverter<CartStatus, String> {
  const CartStatusConverter();

  @override
  CartStatus fromJson(String value) {
    switch (value) {
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

  @override
  String toJson(CartStatus value) => value.name;
}

/// Custom converter สำหรับ double ที่อาจมาเป็น string หรือ number
class DoubleStringConverter implements JsonConverter<double, Object?> {
  const DoubleStringConverter();

  @override
  double fromJson(Object? value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Object toJson(double value) => value;
}

/// สถานะของตระกร้าสินค้า
enum CartStatus {
  active, // กำลังใช้งาน
  completed, // สั่งซื้อแล้ว
  cancelled, // ยกเลิก
}

/// โมเดลตระกร้าสินค้า - เก็บข้อมูลตระกร้าหลักของผู้ใช้
@JsonSerializable()
class CartModel extends Equatable {
  final int? id; // รหัสตระกร้า
  @JsonKey(name: 'customer_id')
  final int? customerId; // รหัสลูกค้า - ใช้ customer_id แทน user_id
  @CartStatusConverter()
  final CartStatus status; // สถานะตระกร้า
  @JsonKey(name: 'total_amount')
  @DoubleStringConverter()
  final double totalAmount; // จำนวนเงินรวม
  @JsonKey(name: 'total_items')
  @DoubleStringConverter()
  final double totalItems; // จำนวนสินค้าทั้งหมด
  @JsonKey(name: 'created_at')
  final DateTime? createdAt; // วันที่สร้าง
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt; // วันที่แก้ไขล่าสุด

  const CartModel({
    this.id,
    this.customerId,
    this.status = CartStatus.active,
    this.totalAmount = 0.0,
    this.totalItems = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartModel copyWith({
    int? id,
    int? customerId,
    CartStatus? status,
    double? totalAmount,
    double? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
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
      customerId: customerId ?? 0,
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
      (sum, item) => sum + (item.totalPrice ?? 0.0),
    );
    final newTotalItems = items.fold<double>(
      0.0,
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
    customerId,
    status,
    totalAmount,
    totalItems,
    createdAt,
    updatedAt,
  ];
}
