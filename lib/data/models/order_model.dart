import 'package:equatable/equatable.dart';

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
class OrderModel extends Equatable {
  final int? id; // รหัสคำสั่งซื้อ
  final int cartId; // รหัสตระกร้า (FK)
  final int customerId; // รหัสลูกค้า (FK) - ใช้ customer_id แทน user_id
  final String orderNumber; // หมายเลขคำสั่งซื้อ
  final OrderStatus status; // สถานะคำสั่งซื้อ
  final double totalAmount; // จำนวนเงินรวม
  final String? shippingAddress; // ที่อยู่จัดส่ง
  final String? paymentMethod; // วิธีการชำระเงิน
  final PaymentStatus paymentStatus; // สถานะการชำระเงิน
  final String? notes; // หมายเหตุ
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toInt(),
      cartId: json['cart_id']?.toInt() ?? 0,
      customerId: json['customer_id']?.toInt() ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      status: _parseOrderStatus(json['status']),
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      shippingAddress: json['shipping_address']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      notes: json['notes']?.toString(),
      orderedAt: json['ordered_at'] != null
          ? DateTime.parse(json['ordered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'customer_id': customerId,
      'order_number': orderNumber,
      'status': status.name,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus.name,
      'notes': notes,
      'ordered_at': orderedAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
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

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
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
