import 'package:equatable/equatable.dart';

/// โมเดลสินค้าในคำสั่งซื้อ - เก็บข้อมูลสินค้าแต่ละชิ้นในคำสั่งซื้อ
class OrderItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในคำสั่งซื้อ
  final int orderId; // รหัสคำสั่งซื้อ (FK)
  final String icCode; // รหัสสินค้า (FK) - ใช้ ic_code แทน product_id
  final String productName; // ชื่อสินค้า (snapshot)
  final String? barcode; // บาร์โค้ดสินค้า (snapshot)
  final String? unitCode; // รหัสหน่วยสินค้า (snapshot)
  final double quantity; // จำนวนสินค้า
  final double unitPrice; // ราคาต่อหน่วย (snapshot)
  final double totalPrice; // ราคารวม

  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.icCode,
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
      icCode: json['ic_code']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      unitCode: json['unit_code']?.toString(),
      quantity: json['quantity']?.toDouble() ?? 1.0,
      unitPrice: json['unit_price']?.toDouble() ?? 0.0,
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'ic_code': icCode,
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
    String? icCode,
    String? productName,
    String? barcode,
    String? unitCode,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      icCode: icCode ?? this.icCode,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity?.toDouble() ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  double get calculatedTotalPrice => quantity * unitPrice;

  @override
  List<Object?> get props => [
    id,
    orderId,
    icCode,
    productName,
    barcode,
    unitCode,
    quantity,
    unitPrice,
    totalPrice,
  ];
}
