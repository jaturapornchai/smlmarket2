import 'package:json_annotation/json_annotation.dart';

part 'supplier_model.g.dart';

@JsonSerializable()
class SupplierModel {
  @JsonKey(name: 'supplier_id')
  final int supplierId; // รหัสผู้จำหน่าย (Primary Key)

  @JsonKey(name: 'supplier_code')
  final String? supplierCode; // รหัสผู้จำหน่าย (เฉพาะ)

  @JsonKey(name: 'supplier_name')
  final String supplierName; // ชื่อผู้จำหน่าย

  @JsonKey(name: 'company_name')
  final String? companyName; // ชื่อบริษัท

  @JsonKey(name: 'company_name_en')
  final String? companyNameEn; // ชื่อบริษัทภาษาอังกฤษ

  @JsonKey(name: 'business_type')
  final String? businessType; // ประเภทธุรกิจ (Manufacturer/Distributor/Wholesaler/Retailer)

  @JsonKey(name: 'contact_person')
  final String? contactPerson; // ชื่อผู้ติดต่อ

  @JsonKey(name: 'contact_title')
  final String? contactTitle; // ตำแหน่งผู้ติดต่อ

  @JsonKey(name: 'email')
  final String? email; // อีเมลหลัก

  @JsonKey(name: 'secondary_email')
  final String? secondaryEmail; // อีเมลสำรอง

  @JsonKey(name: 'phone')
  final String? phone; // เบอร์โทรศัพท์หลัก

  @JsonKey(name: 'mobile')
  final String? mobile; // เบอร์โทรศัพท์มือถือ

  @JsonKey(name: 'fax')
  final String? fax; // เบอร์แฟกซ์

  @JsonKey(name: 'website')
  final String? website; // เว็บไซต์

  @JsonKey(name: 'tax_id')
  final String? taxId; // เลขประจำตัวผู้เสียภาษี

  @JsonKey(name: 'vat_registration')
  final String? vatRegistration; // ทะเบียนภาษีมูลค่าเพิ่ม

  @JsonKey(name: 'business_license')
  final String? businessLicense; // ใบอนุญาตประกอบธุรกิจ

  @JsonKey(name: 'address_line1')
  final String? addressLine1; // ที่อยู่บรรทัดที่ 1

  @JsonKey(name: 'address_line2')
  final String? addressLine2; // ที่อยู่บรรทัดที่ 2

  @JsonKey(name: 'city')
  final String? city; // เมือง/อำเภอ

  @JsonKey(name: 'state_province')
  final String? stateProvince; // จังหวัด/รัฐ

  @JsonKey(name: 'postal_code')
  final String? postalCode; // รหัสไปรษณีย์

  @JsonKey(name: 'country')
  final String? country; // ประเทศ

  @JsonKey(name: 'billing_address_line1')
  final String? billingAddressLine1; // ที่อยู่เรียกเก็บเงิน บรรทัดที่ 1

  @JsonKey(name: 'billing_address_line2')
  final String? billingAddressLine2; // ที่อยู่เรียกเก็บเงิน บรรทัดที่ 2

  @JsonKey(name: 'billing_city')
  final String? billingCity; // เมือง/อำเภอ (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_state_province')
  final String? billingStateProvince; // จังหวัด/รัฐ (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_postal_code')
  final String? billingPostalCode; // รหัสไปรษณีย์ (เรียกเก็บเงิน)

  @JsonKey(name: 'billing_country')
  final String? billingCountry; // ประเทศ (เรียกเก็บเงิน)

  @JsonKey(name: 'bank_name')
  final String? bankName; // ชื่อธนาคาร

  @JsonKey(name: 'bank_branch')
  final String? bankBranch; // สาขาธนาคาร

  @JsonKey(name: 'account_number')
  final String? accountNumber; // เลขที่บัญชี

  @JsonKey(name: 'account_name')
  final String? accountName; // ชื่อบัญชี

  @JsonKey(name: 'swift_code')
  final String? swiftCode; // รหัส SWIFT

  @JsonKey(name: 'payment_terms')
  final String? paymentTerms; // เงื่อนไขการชำระเงิน (Cash/Credit/30Days/60Days/90Days)

  @JsonKey(name: 'payment_method')
  final String? paymentMethod; // วิธีการชำระเงิน (BankTransfer/Check/Cash/CreditCard)

  @JsonKey(name: 'credit_limit')
  final double? creditLimit; // วงเงินเครดิต

  @JsonKey(name: 'credit_days')
  final int? creditDays; // วันเครดิต

  @JsonKey(name: 'currency_code')
  final String? currencyCode; // รหัสสกุลเงิน

  @JsonKey(name: 'delivery_terms')
  final String? deliveryTerms; // เงื่อนไขการจัดส่ง (FOB/CIF/EXW/DDP)

  @JsonKey(name: 'lead_time_days')
  final int? leadTimeDays; // ระยะเวลานำเข้า (วัน)

  @JsonKey(name: 'minimum_order_amount')
  final double? minimumOrderAmount; // ยอดสั่งซื้อขั้นต่ำ

  @JsonKey(name: 'discount_rate')
  final double? discountRate; // อัตราส่วนลด (%)

  @JsonKey(name: 'supplier_rating')
  final double? supplierRating; // คะแนนประเมินผู้จำหน่าย (1-5)

  @JsonKey(name: 'quality_rating')
  final double? qualityRating; // คะแนนคุณภาพสินค้า (1-5)

  @JsonKey(name: 'delivery_rating')
  final double? deliveryRating; // คะแนนการจัดส่ง (1-5)

  @JsonKey(name: 'service_rating')
  final double? serviceRating; // คะแนนการบริการ (1-5)

  @JsonKey(name: 'is_active')
  final bool isActive; // สถานะใช้งาน (true = ใช้งาน, false = ไม่ใช้งาน)

  @JsonKey(name: 'is_preferred')
  final bool? isPreferred; // ผู้จำหน่ายที่ต้องการ (true = ต้องการ, false = ไม่ต้องการ)

  @JsonKey(name: 'is_blacklisted')
  final bool? isBlacklisted; // ติดดำ (true = ติดดำ, false = ไม่ติดดำ)

  @JsonKey(name: 'is_verified')
  final bool? isVerified; // ยืนยันแล้ว (true = ยืนยันแล้ว, false = ยังไม่ยืนยัน)

  @JsonKey(name: 'verification_date')
  final DateTime? verificationDate; // วันที่ยืนยัน

  @JsonKey(name: 'contract_start_date')
  final DateTime? contractStartDate; // วันที่เริ่มสัญญา

  @JsonKey(name: 'contract_end_date')
  final DateTime? contractEndDate; // วันที่สิ้นสุดสัญญา

  @JsonKey(name: 'last_order_date')
  final DateTime? lastOrderDate; // วันที่สั่งซื้อล่าสุด

  @JsonKey(name: 'last_payment_date')
  final DateTime? lastPaymentDate; // วันที่ชำระเงินล่าสุด

  @JsonKey(name: 'total_orders')
  final int? totalOrders; // จำนวนคำสั่งซื้อทั้งหมด

  @JsonKey(name: 'total_amount')
  final double? totalAmount; // ยอดซื้อทั้งหมด

  @JsonKey(name: 'outstanding_amount')
  final double? outstandingAmount; // ยอดค้างชำระ

  @JsonKey(name: 'products_count')
  final int? productsCount; // จำนวนสินค้าที่จำหน่าย

  @JsonKey(name: 'categories')
  final List<String>? categories; // หมวดหมู่สินค้าที่จำหน่าย

  @JsonKey(name: 'specializations')
  final List<String>? specializations; // ความเชี่ยวชาญ

  @JsonKey(name: 'certifications')
  final List<String>? certifications; // ใบรับรอง

  @JsonKey(name: 'documents')
  final List<String>? documents; // เอกสารที่เกี่ยวข้อง

  @JsonKey(name: 'notes')
  final String? notes; // หมายเหตุ

  @JsonKey(name: 'internal_notes')
  final String? internalNotes; // หมายเหตุภายใน

  @JsonKey(name: 'created_by')
  final int? createdBy; // รหัสผู้สร้างข้อมูล

  @JsonKey(name: 'updated_by')
  final int? updatedBy; // รหัสผู้อัปเดตข้อมูลล่าสุด

  @JsonKey(name: 'created_at')
  final DateTime? createdAt; // วันที่สร้างข้อมูล

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt; // วันที่อัปเดตข้อมูลล่าสุด

  @JsonKey(name: 'version')
  final int? version; // เวอร์ชันข้อมูล

  const SupplierModel({
    required this.supplierId,
    this.supplierCode,
    required this.supplierName,
    this.companyName,
    this.companyNameEn,
    this.businessType,
    this.contactPerson,
    this.contactTitle,
    this.email,
    this.secondaryEmail,
    this.phone,
    this.mobile,
    this.fax,
    this.website,
    this.taxId,
    this.vatRegistration,
    this.businessLicense,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.billingAddressLine1,
    this.billingAddressLine2,
    this.billingCity,
    this.billingStateProvince,
    this.billingPostalCode,
    this.billingCountry,
    this.bankName,
    this.bankBranch,
    this.accountNumber,
    this.accountName,
    this.swiftCode,
    this.paymentTerms,
    this.paymentMethod,
    this.creditLimit,
    this.creditDays,
    this.currencyCode,
    this.deliveryTerms,
    this.leadTimeDays,
    this.minimumOrderAmount,
    this.discountRate,
    this.supplierRating,
    this.qualityRating,
    this.deliveryRating,
    this.serviceRating,
    required this.isActive,
    this.isPreferred,
    this.isBlacklisted,
    this.isVerified,
    this.verificationDate,
    this.contractStartDate,
    this.contractEndDate,
    this.lastOrderDate,
    this.lastPaymentDate,
    this.totalOrders,
    this.totalAmount,
    this.outstandingAmount,
    this.productsCount,
    this.categories,
    this.specializations,
    this.certifications,
    this.documents,
    this.notes,
    this.internalNotes,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) =>
      _$SupplierModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierModelToJson(this);

  // Helper methods
  bool get hasOutstandingBalance =>
      outstandingAmount != null && outstandingAmount! > 0; // มียอดค้างชำระ
  bool get hasGoodRating => (supplierRating ?? 0) >= 4.0; // มีคะแนนดี
  bool get isLongTermPartner =>
      totalOrders != null && totalOrders! >= 100; // เป็นพาร์ทเนอร์ระยะยาว
  bool get isRecentlyActive {
    if (lastOrderDate == null) return false;
    return DateTime.now().difference(lastOrderDate!).inDays <= 90;
  } // มีกิจกรรมล่าสุด

  bool get hasValidContract {
    if (contractEndDate == null) return true;
    return DateTime.now().isBefore(contractEndDate!);
  } // สัญญายังไม่หมดอายุ

  bool get contractExpiringSoon {
    if (contractEndDate == null) return false;
    final daysUntilExpiry = contractEndDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  } // สัญญาใกล้หมดอายุ

  bool get hasExcellentQuality => (qualityRating ?? 0) >= 4.5; // คุณภาพดีเยี่ยม
  bool get hasExcellentDelivery =>
      (deliveryRating ?? 0) >= 4.5; // การจัดส่งดีเยี่ยม
  bool get hasExcellentService =>
      (serviceRating ?? 0) >= 4.5; // การบริการดีเยี่ยม
  bool get isTopSupplier =>
      hasGoodRating &&
      isRecentlyActive &&
      !hasOutstandingBalance; // ผู้จำหน่ายชั้นนำ

  String get displayName => supplierName; // ชื่อที่แสดง
  String get fullDisplayName => companyName != null
      ? '$supplierName ($companyName)'
      : supplierName; // ชื่อเต็มที่แสดง

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1 != null) parts.add(addressLine1!);
    if (addressLine2 != null) parts.add(addressLine2!);
    if (city != null) parts.add(city!);
    if (stateProvince != null) parts.add(stateProvince!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  } // ที่อยู่เต็ม

  String get fullBillingAddress {
    final parts = <String>[];
    if (billingAddressLine1 != null) parts.add(billingAddressLine1!);
    if (billingAddressLine2 != null) parts.add(billingAddressLine2!);
    if (billingCity != null) parts.add(billingCity!);
    if (billingStateProvince != null) parts.add(billingStateProvince!);
    if (billingPostalCode != null) parts.add(billingPostalCode!);
    if (billingCountry != null) parts.add(billingCountry!);
    return parts.join(', ');
  } // ที่อยู่เรียกเก็บเงินเต็ม

  String get bankDetails {
    final parts = <String>[];
    if (bankName != null) parts.add('ธนาคาร: $bankName');
    if (bankBranch != null) parts.add('สาขา: $bankBranch');
    if (accountNumber != null) parts.add('เลขที่บัญชี: $accountNumber');
    if (accountName != null) parts.add('ชื่อบัญชี: $accountName');
    return parts.join('\n');
  } // รายละเอียดธนาคาร

  double get averageRating {
    final ratings = <double>[];
    if (supplierRating != null) ratings.add(supplierRating!);
    if (qualityRating != null) ratings.add(qualityRating!);
    if (deliveryRating != null) ratings.add(deliveryRating!);
    if (serviceRating != null) ratings.add(serviceRating!);
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  } // คะแนนเฉลี่ย

  String get statusDisplayName {
    if (!isActive) return 'ไม่ใช้งาน';
    if (isBlacklisted == true) return 'ติดดำ';
    if (isPreferred == true) return 'ผู้จำหน่ายที่ต้องการ';
    if (isTopSupplier) return 'ผู้จำหน่ายชั้นนำ';
    if (hasGoodRating) return 'ผู้จำหน่ายดี';
    return 'ปกติ';
  } // สถานะแสดง

  String get businessTypeDisplayName {
    switch (businessType?.toLowerCase()) {
      case 'manufacturer':
        return 'ผู้ผลิต';
      case 'distributor':
        return 'ผู้จัดจำหน่าย';
      case 'wholesaler':
        return 'ขายส่ง';
      case 'retailer':
        return 'ขายปลีก';
      default:
        return businessType ?? 'ไม่ระบุ';
    }
  } // ประเภทธุรกิจแสดง

  int get daysSinceLastOrder {
    if (lastOrderDate == null) return -1;
    return DateTime.now().difference(lastOrderDate!).inDays;
  } // จำนวนวันนับจากคำสั่งซื้อล่าสุด

  int get contractDaysRemaining {
    if (contractEndDate == null) return -1;
    return contractEndDate!.difference(DateTime.now()).inDays;
  } // จำนวนวันที่เหลือของสัญญา
}
