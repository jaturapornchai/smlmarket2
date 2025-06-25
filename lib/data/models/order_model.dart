import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

/// Custom converter สำหรับ OrderStatus
class OrderStatusConverter implements JsonConverter<OrderStatus, String> {
  const OrderStatusConverter();

  @override
  OrderStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  String toJson(OrderStatus value) => value.name;
}

/// Custom converter สำหรับ PaymentStatus
class PaymentStatusConverter implements JsonConverter<PaymentStatus, String> {
  const PaymentStatusConverter();

  @override
  PaymentStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  String toJson(PaymentStatus value) => value.name;
}

/// สถานะของคำสั่งซื้อ
enum OrderStatus {
  pending, // รอดำเนินการ
  confirmed, // ยืนยันแล้ว
  processing, // กำลังเตรียมของ
  shipped, // จัดส่งแล้ว
  delivered, // ส่งถึงแล้ว
  cancelled, // ยกเลิก
}

/// สถานะการชำระเงิน
enum PaymentStatus {
  pending, // รอชำระ
  paid, // ชำระแล้ว
  failed, // ชำระไม่สำเร็จ
  refunded, // คืนเงินแล้ว
}

/// โมเดลคำสั่งซื้อ - เก็บข้อมูลคำสั่งซื้อหลัก
@JsonSerializable()
class OrderModel extends Equatable {
  final int? id; // รหัสคำสั่งซื้อ
  @JsonKey(name: 'cart_id')
  final int cartId; // รหัสตระกร้า (FK)
  @JsonKey(name: 'customer_id')
  final int customerId; // รหัสลูกค้า (FK) - ใช้ customer_id แทน user_id
  @JsonKey(name: 'order_number')
  final String orderNumber; // หมายเลขคำสั่งซื้อ
  @OrderStatusConverter()
  final OrderStatus status; // สถานะคำสั่งซื้อ
  @JsonKey(name: 'total_amount')
  final double totalAmount; // จำนวนเงินรวม
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress; // ที่อยู่จัดส่ง
  @JsonKey(name: 'payment_method')
  final String? paymentMethod; // วิธีการชำระเงิน
  @JsonKey(name: 'payment_status')
  @PaymentStatusConverter()
  final PaymentStatus paymentStatus; // สถานะการชำระเงิน
  final String? notes; // หมายเหตุ
  @JsonKey(name: 'ordered_at')
  final DateTime? orderedAt; // วันที่สั่งซื้อ

  const OrderModel({
    this.id,
    required this.cartId,
    required this.customerId,
    required this.orderNumber,
    this.status = OrderStatus.pending,
    required this.totalAmount,
    this.shippingAddress,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    this.orderedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    int? id,
    int? cartId,
    int? customerId,
    String? orderNumber,
    OrderStatus? status,
    double? totalAmount,
    String? shippingAddress,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    String? notes,
    DateTime? orderedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      orderedAt: orderedAt ?? this.orderedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cartId,
    customerId,
    orderNumber,
    status,
    totalAmount,
    shippingAddress,
    paymentMethod,
    paymentStatus,
    notes,
    orderedAt,
  ];
}
