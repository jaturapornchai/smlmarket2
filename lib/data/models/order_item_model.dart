import 'package:equatable/equatable.dart';

/// โมเดลสินค้าในคำสั่งซื้อ - เก็บข้อมูลสินค้าแต่ละชิ้นในคำสั่งซื้อ
class OrderItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในคำสั่งซื้อ
  final int orderId; // รหัสคำสั่งซื้อ (FK)
  final int productId; // รหัสสินค้า (FK)
  final String productName; // ชื่อสินค้า (snapshot)
  final String? barcode; // บาร์โค้ดสินค้า (snapshot)
  final String? unitCode; // รหัสหน่วยสินค้า (snapshot)
  final int quantity; // จำนวนสินค้า
  final double unitPrice; // ราคาต่อหน่วย (snapshot)
  final double totalPrice; // ราคารวม

  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.barcode,
    this.unitCode,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toInt(),
      orderId: json['order_id']?.toInt() ?? 0,
      productId: json['product_id']?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      unitCode: json['unit_code']?.toString(),
      quantity: json['quantity']?.toInt() ?? 1,
      unitPrice: json['unit_price']?.toDouble() ?? 0.0,
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'barcode': barcode,
      'unit_code': unitCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    String? barcode,
    String? unitCode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  double get calculatedTotalPrice => quantity * unitPrice;

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    productName,
    barcode,
    unitCode,
    quantity,
    unitPrice,
    totalPrice,
  ];
}
