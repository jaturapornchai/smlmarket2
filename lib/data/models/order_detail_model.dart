import 'package:json_annotation/json_annotation.dart';

part 'order_detail_model.g.dart';

@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'order_id')
  final int orderId; // รหัสคำสั่งซื้อ (Primary Key)

  @JsonKey(name: 'order_number')
  final String orderNumber; // หมายเลขคำสั่งซื้อ (เฉพาะ)

  @JsonKey(name: 'customer_id')
  final int customerId; // รหัสลูกค้า

  @JsonKey(name: 'customer_name')
  final String customerName; // ชื่อลูกค้า

  @JsonKey(name: 'customer_email')
  final String? customerEmail; // อีเมลลูกค้า

  @JsonKey(name: 'customer_phone')
  final String? customerPhone; // เบอร์โทรลูกค้า

  @JsonKey(name: 'order_status')
  final String orderStatus; // สถานะคำสั่งซื้อ (Pending/Confirmed/Processing/Shipped/Delivered/Cancelled/Refunded)

  @JsonKey(name: 'order_type')
  final String? orderType; // ประเภทคำสั่งซื้อ (Online/Store/Phone/Fax)

  @JsonKey(name: 'payment_status')
  final String paymentStatus; // สถานะการชำระเงิน (Pending/Paid/PartiallyPaid/Failed/Refunded)

  @JsonKey(name: 'shipping_status')
  final String? shippingStatus; // สถานะการจัดส่ง (NotShipped/Processing/Shipped/InTransit/Delivered/Failed)

  @JsonKey(name: 'order_date')
  final DateTime orderDate; // วันที่สั่งซื้อ

  @JsonKey(name: 'required_date')
  final DateTime? requiredDate; // วันที่ต้องการให้จัดส่ง

  @JsonKey(name: 'shipped_date')
  final DateTime? shippedDate; // วันที่จัดส่ง

  @JsonKey(name: 'delivered_date')
  final DateTime? deliveredDate; // วันที่ส่งถึง

  @JsonKey(name: 'total_items')
  final int totalItems; // จำนวนสินค้าทั้งหมด

  @JsonKey(name: 'total_quantity')
  final int totalQuantity; // จำนวนชิ้นทั้งหมด

  @JsonKey(name: 'subtotal_amount')
  final double subtotalAmount; // ยอดรวมย่อย

  @JsonKey(name: 'discount_amount')
  final double? discountAmount; // ยอดส่วนลด

  @JsonKey(name: 'tax_amount')
  final double? taxAmount; // ยอดภาษี

  @JsonKey(name: 'shipping_amount')
  final double? shippingAmount; // ค่าจัดส่ง

  @JsonKey(name: 'total_amount')
  final double totalAmount; // ยอดรวมสุทธิ

  @JsonKey(name: 'paid_amount')
  final double? paidAmount; // ยอดที่ชำระแล้ว

  @JsonKey(name: 'balance_amount')
  final double? balanceAmount; // ยอดคงเหลือ

  @JsonKey(name: 'currency_code')
  final String? currencyCode; // รหัสสกุลเงิน

  @JsonKey(name: 'exchange_rate')
  final double? exchangeRate; // อัตราแลกเปลี่ยน

  @JsonKey(name: 'discount_code')
  final String? discountCode; // รหัสส่วนลด

  @JsonKey(name: 'discount_rate')
  final double? discountRate; // อัตราส่วนลด (%)

  @JsonKey(name: 'tax_rate')
  final double? taxRate; // อัตราภาษี (%)

  @JsonKey(name: 'payment_method')
  final String? paymentMethod; // วิธีการชำระเงิน (Cash/CreditCard/BankTransfer/PromptPay)

  @JsonKey(name: 'payment_reference')
  final String? paymentReference; // หมายเลขอ้างอิงการชำระเงิน

  @JsonKey(name: 'shipping_method')
  final String? shippingMethod; // วิธีการจัดส่ง (Pickup/Delivery/Express/Standard)

  @JsonKey(name: 'shipping_company')
  final String? shippingCompany; // บริษัทขนส่ง

  @JsonKey(name: 'tracking_number')
  final String? trackingNumber; // หมายเลขติดตาม

  @JsonKey(name: 'shipping_address_line1')
  final String? shippingAddressLine1; // ที่อยู่จัดส่ง บรรทัดที่ 1

  @JsonKey(name: 'shipping_address_line2')
  final String? shippingAddressLine2; // ที่อยู่จัดส่ง บรรทัดที่ 2

  @JsonKey(name: 'shipping_city')
  final String? shippingCity; // เมือง/อำเภอ (จัดส่ง)

  @JsonKey(name: 'shipping_state_province')
  final String? shippingStateProvince; // จังหวัด (จัดส่ง)

  @JsonKey(name: 'shipping_postal_code')
  final String? shippingPostalCode; // รหัสไปรษณีย์ (จัดส่ง)

  @JsonKey(name: 'shipping_country')
  final String? shippingCountry; // ประเทศ (จัดส่ง)

  @JsonKey(name: 'billing_address_line1')
  final String? billingAddressLine1; // ที่อยู่เรียกเก็บเงิน บรรทัดที่ 1

  @JsonKey(name: 'billing_address_line2')
  final String? billingAddressLine2; // ที่อยู่เรียกเก็บเงิน บรรทัดที่ 2

  @JsonKey(name: 'billing_city')
  final String? billingCity; // เมือง/อำเภอ (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_state_province')
  final String? billingStateProvince; // จังหวัด (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_postal_code')
  final String? billingPostalCode; // รหัสไปรษณีย์ (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_country')
  final String? billingCountry; // ประเทศ (เรียกเก็บเงิน)

  @JsonKey(name: 'special_instructions')
  final String? specialInstructions; // คำสั่งพิเศษ

  @JsonKey(name: 'internal_notes')
  final String? internalNotes; // หมายเหตุภายใน

  @JsonKey(name: 'customer_notes')
  final String? customerNotes; // หมายเหตุจากลูกค้า

  @JsonKey(name: 'priority_level')
  final String? priorityLevel; // ระดับความสำคัญ (Low/Normal/High/Urgent)

  @JsonKey(name: 'source_cart_id')
  final int? sourceCartId; // รหัสตะกร้าที่มาเป็นคำสั่งซื้อนี้

  @JsonKey(name: 'parent_order_id')
  final int? parentOrderId; // รหัสคำสั่งซื้อแม่ (สำหรับ split order)

  @JsonKey(name: 'sales_person_id')
  final int? salesPersonId; // รหัสพนักงานขาย

  @JsonKey(name: 'sales_person_name')
  final String? salesPersonName; // ชื่อพนักงานขาย

  @JsonKey(name: 'approved_by')
  final int? approvedBy; // รหัสผู้อนุมัติคำสั่งซื้อ

  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt; // วันที่อนุมัติ

  @JsonKey(name: 'cancelled_by')
  final int? cancelledBy; // รหัสผู้ยกเลิกคำสั่งซื้อ

  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt; // วันที่ยกเลิก

  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason; // เหตุผลการยกเลิก

  @JsonKey(name: 'refund_amount')
  final double? refundAmount; // ยอดเงินคืน

  @JsonKey(name: 'refund_reason')
  final String? refundReason; // เหตุผลการคืนเงิน

  @JsonKey(name: 'refunded_at')
  final DateTime? refundedAt; // วันที่คืนเงิน

  @JsonKey(name: 'created_by')
  final int? createdBy; // รหัสผู้สร้างคำสั่งซื้อ

  @JsonKey(name: 'updated_by')
  final int? updatedBy; // รหัสผู้อัปเดตคำสั่งซื้อล่าสุด

  @JsonKey(name: 'created_at')
  final DateTime? createdAt; // วันที่สร้างคำสั่งซื้อ

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt; // วันที่อัปเดตคำสั่งซื้อล่าสุด

  @JsonKey(name: 'version')
  final int? version; // เวอร์ชันข้อมูล

  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.orderStatus,
    this.orderType,
    required this.paymentStatus,
    this.shippingStatus,
    required this.orderDate,
    this.requiredDate,
    this.shippedDate,
    this.deliveredDate,
    required this.totalItems,
    required this.totalQuantity,
    required this.subtotalAmount,
    this.discountAmount,
    this.taxAmount,
    this.shippingAmount,
    required this.totalAmount,
    this.paidAmount,
    this.balanceAmount,
    this.currencyCode,
    this.exchangeRate,
    this.discountCode,
    this.discountRate,
    this.taxRate,
    this.paymentMethod,
    this.paymentReference,
    this.shippingMethod,
    this.shippingCompany,
    this.trackingNumber,
    this.shippingAddressLine1,
    this.shippingAddressLine2,
    this.shippingCity,
    this.shippingStateProvince,
    this.shippingPostalCode,
    this.shippingCountry,
    this.billingAddressLine1,
    this.billingAddressLine2,
    this.billingCity,
    this.billingStateProvince,
    this.billingPostalCode,
    this.billingCountry,
    this.specialInstructions,
    this.internalNotes,
    this.customerNotes,
    this.priorityLevel,
    this.sourceCartId,
    this.parentOrderId,
    this.salesPersonId,
    this.salesPersonName,
    this.approvedBy,
    this.approvedAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  // Helper methods สำหรับการตรวจสอบสถานะ
  bool get isPending => orderStatus.toLowerCase() == 'pending';
  bool get isConfirmed => orderStatus.toLowerCase() == 'confirmed';
  bool get isProcessing => orderStatus.toLowerCase() == 'processing';
  bool get isShipped => orderStatus.toLowerCase() == 'shipped';
  bool get isDelivered => orderStatus.toLowerCase() == 'delivered';
  bool get isCancelled => orderStatus.toLowerCase() == 'cancelled';
  bool get isRefunded => orderStatus.toLowerCase() == 'refunded';

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPendingPayment => paymentStatus.toLowerCase() == 'pending';
  bool get isPartiallyPaid => paymentStatus.toLowerCase() == 'partiallypaid';
  bool get isPaymentFailed => paymentStatus.toLowerCase() == 'failed';
  bool get isPaymentRefunded => paymentStatus.toLowerCase() == 'refunded';

  bool get isNotShipped => shippingStatus?.toLowerCase() == 'notshipped';
  bool get isShippingProcessing =>
      shippingStatus?.toLowerCase() == 'processing';
  bool get isInTransit => shippingStatus?.toLowerCase() == 'intransit';
  bool get isShippingDelivered => shippingStatus?.toLowerCase() == 'delivered';
  bool get isShippingFailed => shippingStatus?.toLowerCase() == 'failed';

  bool get hasDiscount => discountAmount != null && discountAmount! > 0;
  bool get hasShipping => shippingAmount != null && shippingAmount! > 0;
  bool get hasTax => taxAmount != null && taxAmount! > 0;
  bool get hasTrackingNumber =>
      trackingNumber != null && trackingNumber!.isNotEmpty;
  bool get hasPaymentReference =>
      paymentReference != null && paymentReference!.isNotEmpty;
  bool get isFullyPaid => paidAmount != null && paidAmount! >= totalAmount;
  bool get hasBalance => balanceAmount != null && balanceAmount! > 0;
  bool get isOverdue {
    if (requiredDate == null || isDelivered) return false;
    return DateTime.now().isAfter(requiredDate!);
  }

  double get averageItemPrice =>
      totalItems > 0 ? subtotalAmount / totalItems : 0.0;
  int get daysSinceOrder => DateTime.now().difference(orderDate).inDays;
  int get daysUntilRequired {
    if (requiredDate == null) return 0;
    return requiredDate!.difference(DateTime.now()).inDays;
  }

  String get fullShippingAddress {
    final parts = <String>[];
    if (shippingAddressLine1 != null) parts.add(shippingAddressLine1!);
    if (shippingAddressLine2 != null) parts.add(shippingAddressLine2!);
    if (shippingCity != null) parts.add(shippingCity!);
    if (shippingStateProvince != null) parts.add(shippingStateProvince!);
    if (shippingPostalCode != null) parts.add(shippingPostalCode!);
    if (shippingCountry != null) parts.add(shippingCountry!);
    return parts.join(', ');
  }

  String get fullBillingAddress {
    final parts = <String>[];
    if (billingAddressLine1 != null) parts.add(billingAddressLine1!);
    if (billingAddressLine2 != null) parts.add(billingAddressLine2!);
    if (billingCity != null) parts.add(billingCity!);
    if (billingStateProvince != null) parts.add(billingStateProvince!);
    if (billingPostalCode != null) parts.add(billingPostalCode!);
    if (billingCountry != null) parts.add(billingCountry!);
    return parts.join(', ');
  }
}
