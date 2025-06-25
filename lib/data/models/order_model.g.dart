// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num?)?.toInt(),
  cartId: (json['cart_id'] as num).toInt(),
  customerId: (json['customer_id'] as num).toInt(),
  orderNumber: json['order_number'] as String,
  status: json['status'] == null
      ? OrderStatus.pending
      : const OrderStatusConverter().fromJson(json['status'] as String),
  totalAmount: (json['total_amount'] as num).toDouble(),
  shippingAddress: json['shipping_address'] as String?,
  paymentMethod: json['payment_method'] as String?,
  paymentStatus: json['payment_status'] == null
      ? PaymentStatus.pending
      : const PaymentStatusConverter().fromJson(
          json['payment_status'] as String,
        ),
  notes: json['notes'] as String?,
  orderedAt: json['ordered_at'] == null
      ? null
      : DateTime.parse(json['ordered_at'] as String),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cart_id': instance.cartId,
      'customer_id': instance.customerId,
      'order_number': instance.orderNumber,
      'status': const OrderStatusConverter().toJson(instance.status),
      'total_amount': instance.totalAmount,
      'shipping_address': instance.shippingAddress,
      'payment_method': instance.paymentMethod,
      'payment_status': const PaymentStatusConverter().toJson(
        instance.paymentStatus,
      ),
      'notes': instance.notes,
      'ordered_at': instance.orderedAt?.toIso8601String(),
    };
