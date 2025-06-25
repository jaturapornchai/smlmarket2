import 'package:json_annotation/json_annotation.dart';

/// สถานะใบขอยืนยันราคาและขอยืนยันจำนวน
@JsonEnum(valueField: 'value')
enum QuotationStatus {
  pending('pending', 'รอการยืนยัน'),
  confirmed('confirmed', 'ยืนยันแล้ว'),
  cancelled('cancelled', 'ยกเลิก'),
  negotiating('negotiating', 'กำลังต่อรอง'),
  completed('completed', 'สำเร็จ');

  const QuotationStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static QuotationStatus fromString(String value) {
    return QuotationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => QuotationStatus.pending,
    );
  }
}

/// สถานะรายการสินค้าในใบขอยืนยัน
@JsonEnum(valueField: 'value')
enum QuotationItemStatus {
  active('active', 'ใช้งาน'),
  cancelled('cancelled', 'ยกเลิก');

  const QuotationItemStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static QuotationItemStatus fromString(String value) {
    return QuotationItemStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => QuotationItemStatus.active,
    );
  }
}

/// ประเภทการต่อรอง
@JsonEnum(valueField: 'value')
enum NegotiationType {
  price('price', 'ราคา'),
  quantity('quantity', 'จำนวน'),
  both('both', 'ทั้งราคาและจำนวน'),
  note('note', 'หมายเหตุ');

  const NegotiationType(this.value, this.displayName);

  final String value;
  final String displayName;

  static NegotiationType fromString(String value) {
    return NegotiationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NegotiationType.note,
    );
  }
}

/// สถานะการต่อรอง
@JsonEnum(valueField: 'value')
enum NegotiationStatus {
  pending('pending', 'รอการตอบกลับ'),
  accepted('accepted', 'ยอมรับ'),
  rejected('rejected', 'ปฏิเสธ'),
  countered('countered', 'เสนอกลับ');

  const NegotiationStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static NegotiationStatus fromString(String value) {
    return NegotiationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NegotiationStatus.pending,
    );
  }
}

/// บทบาทในการต่อรอง
@JsonEnum(valueField: 'value')
enum NegotiationRole {
  customer('customer', 'ลูกค้า'),
  seller('seller', 'ผู้ขาย');

  const NegotiationRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static NegotiationRole fromString(String value) {
    return NegotiationRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => NegotiationRole.customer,
    );
  }
}
