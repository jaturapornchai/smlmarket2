import 'package:json_annotation/json_annotation.dart';

part 'ar_customer_model.g.dart';

@JsonSerializable()
class ArCustomerModel {
  final String code; // Primary Key
  @JsonKey(name: 'price_level')
  final String? priceLevel;
  @JsonKey(name: 'row_order_ref')
  final int rowOrderRef;

  const ArCustomerModel({
    required this.code,
    this.priceLevel,
    this.rowOrderRef = 0,
  });

  factory ArCustomerModel.fromJson(Map<String, dynamic> json) =>
      _$ArCustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArCustomerModelToJson(this);

  // For UserModel compatibility
  factory ArCustomerModel.fromUserJson(Map<String, dynamic> json) {
    return ArCustomerModel(
      code: json['id']?.toString() ?? json['code']?.toString() ?? '',
      priceLevel: json['price_level']?.toString(),
      rowOrderRef: json['row_order_ref']?.toInt() ?? 0,
    );
  }

  // Convert to UserModel format for backward compatibility
  Map<String, dynamic> toUserJson() {
    return {
      'id': code,
      'code': code,
      'price_level': priceLevel,
      'row_order_ref': rowOrderRef,
    };
  }

  @override
  String toString() {
    return 'ArCustomerModel(code: $code, priceLevel: $priceLevel)';
  }
}
