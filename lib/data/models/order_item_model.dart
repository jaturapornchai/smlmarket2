import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_model.g.dart';

/// โมเดลสินค้าในคำสั่งซื้อ - เก็บข้อมูลสินค้าแต่ละชิ้นในคำสั่งซื้อ
@JsonSerializable()
class OrderItemModel extends Equatable {
  final int? id; // รหัสรายการสินค้าในคำสั่งซื้อ
  @JsonKey(name: 'order_id')
  final int orderId; // รหัสคำสั่งซื้อ (FK)
  @JsonKey(name: 'ic_code')
  final String icCode; // รหัสสินค้า (FK) - ใช้ ic_code แทน product_id
  @JsonKey(name: 'product_name')
  final String productName; // ชื่อสินค้า (snapshot)
  final String? barcode; // บาร์โค้ดสินค้า (snapshot)
  @JsonKey(name: 'unit_code')
  final String? unitCode; // รหัสหน่วยสินค้า (snapshot)
  final double quantity; // จำนวนสินค้า
  @JsonKey(name: 'unit_price')
  final double unitPrice; // ราคาต่อหน่วย (snapshot)
  @JsonKey(name: 'total_price')
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

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
