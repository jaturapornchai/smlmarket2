import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final int userId; // รหัสผู้ใช้งาน (Primary Key)

  @JsonKey(name: 'username')
  final String username; // ชื่อผู้ใช้งาน (สำหรับเข้าสู่ระบบ)

  @JsonKey(name: 'email')
  final String? email; // อีเมล

  @JsonKey(name: 'password_hash')
  final String passwordHash; // รหัสผ่านที่เข้ารหัสแล้ว

  @JsonKey(name: 'first_name')
  final String firstName; // ชื่อจริง

  @JsonKey(name: 'last_name')
  final String lastName; // นามสกุล

  @JsonKey(name: 'full_name')
  final String? fullName; // ชื่อเต็ม

  @JsonKey(name: 'display_name')
  final String? displayName; // ชื่อที่แสดง

  @JsonKey(name: 'phone_number')
  final String? phoneNumber; // หมายเลขโทรศัพท์

  @JsonKey(name: 'mobile_number')
  final String? mobileNumber; // หมายเลขโทรศัพท์มือถือ

  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth; // วันเกิด

  @JsonKey(name: 'gender')
  final String? gender; // เพศ (Male/Female/Other)

  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl; // URL รูปโปรไฟล์

  @JsonKey(name: 'user_type')
  final String userType; // ประเภทผู้ใช้ (Customer/Staff/Admin/Supplier)

  @JsonKey(name: 'user_role')
  final String userRole; // บทบาท (User/Manager/SuperAdmin)

  @JsonKey(name: 'customer_id')
  final int? customerId; // รหัสลูกค้า (ถ้าเป็น Customer)

  @JsonKey(name: 'staff_id')
  final int? staffId; // รหัสพนักงาน (ถ้าเป็น Staff)

  @JsonKey(name: 'supplier_id')
  final int? supplierId; // รหัสผู้จำหน่าย (ถ้าเป็น Supplier)

  @JsonKey(name: 'company_name')
  final String? companyName; // ชื่อบริษัท

  @JsonKey(name: 'tax_id')
  final String? taxId; // เลขประจำตัวผู้เสียภาษี

  @JsonKey(name: 'address_line1')
  final String? addressLine1; // ที่อยู่บรรทัดที่ 1

  @JsonKey(name: 'address_line2')
  final String? addressLine2; // ที่อยู่บรรทัดที่ 2

  @JsonKey(name: 'city')
  final String? city; // เมือง

  @JsonKey(name: 'state_province')
  final String? stateProvince; // จังหวัด/รัฐ

  @JsonKey(name: 'postal_code')
  final String? postalCode; // รหัสไปรษณีย์

  @JsonKey(name: 'country')
  final String? country; // ประเทศ

  @JsonKey(name: 'is_active')
  final bool isActive; // สถานะใช้งาน (true = ใช้งาน, false = ปิดใช้งาน)

  @JsonKey(name: 'is_verified')
  final bool? isVerified; // สถานะการยืนยัน (true = ยืนยันแล้ว, false = ยังไม่ยืนยัน)

  @JsonKey(name: 'is_online')
  final bool? isOnline; // สถานะออนไลน์ (true = ออนไลน์, false = ออฟไลน์)

  @JsonKey(name: 'email_verified')
  final bool? emailVerified; // สถานะการยืนยันอีเมล

  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified; // สถานะการยืนยันเบอร์โทร

  @JsonKey(name: 'two_factor_enabled')
  final bool? twoFactorEnabled; // เปิดใช้งาน 2FA (true = เปิด, false = ปิด)

  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage; // ภาษาที่ต้องการ (th/en)

  @JsonKey(name: 'timezone')
  final String? timezone; // เขตเวลา

  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt; // วันที่เข้าสู่ระบบล่าสุด

  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt; // วันที่มีกิจกรรมล่าสุด

  @JsonKey(name: 'password_changed_at')
  final DateTime? passwordChangedAt; // วันที่เปลี่ยนรหัสผ่านล่าสุด

  @JsonKey(name: 'account_locked_at')
  final DateTime? accountLockedAt; // วันที่บัญชีถูกล็อค

  @JsonKey(name: 'failed_login_attempts')
  final int? failedLoginAttempts; // จำนวนครั้งที่เข้าสู่ระบบไม่สำเร็จ

  @JsonKey(name: 'credit_limit')
  final double? creditLimit; // วงเงินเครดิต (สำหรับลูกค้า)

  @JsonKey(name: 'credit_balance')
  final double? creditBalance; // ยอดเครดิตคงเหลือ

  @JsonKey(name: 'loyalty_points')
  final int? loyaltyPoints; // แต้มสะสม

  @JsonKey(name: 'discount_rate')
  final double? discountRate; // อัตราส่วนลดพิเศษ (%)

  @JsonKey(name: 'notes')
  final String? notes; // หมายเหตุ

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

  const UserModel({
    required this.userId,
    required this.username,
    this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.displayName,
    this.phoneNumber,
    this.mobileNumber,
    this.dateOfBirth,
    this.gender,
    this.profileImageUrl,
    required this.userType,
    required this.userRole,
    this.customerId,
    this.staffId,
    this.supplierId,
    this.companyName,
    this.taxId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    required this.isActive,
    this.isVerified,
    this.isOnline,
    this.emailVerified,
    this.phoneVerified,
    this.twoFactorEnabled,
    this.preferredLanguage,
    this.timezone,
    this.lastLoginAt,
    this.lastActivityAt,
    this.passwordChangedAt,
    this.accountLockedAt,
    this.failedLoginAttempts,
    this.creditLimit,
    this.creditBalance,
    this.loyaltyPoints,
    this.discountRate,
    this.notes,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper methods
  String get displayNameOrUsername => displayName ?? username;
  String get fullDisplayName => fullName ?? '$firstName $lastName';
  bool get isCustomer => userType.toLowerCase() == 'customer';
  bool get isStaff => userType.toLowerCase() == 'staff';
  bool get isAdmin => userType.toLowerCase() == 'admin';
  bool get isSupplier => userType.toLowerCase() == 'supplier';
  bool get isAccountLocked => accountLockedAt != null;
  bool get hasExcessiveFailedLogins => (failedLoginAttempts ?? 0) >= 5;
  bool get isVerifiedUser => isVerified == true && emailVerified == true;
}
