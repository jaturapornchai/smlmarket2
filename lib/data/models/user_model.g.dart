// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: (json['user_id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String?,
  passwordHash: json['password_hash'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  fullName: json['full_name'] as String?,
  displayName: json['display_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  dateOfBirth: json['date_of_birth'] == null
      ? null
      : DateTime.parse(json['date_of_birth'] as String),
  gender: json['gender'] as String?,
  profileImageUrl: json['profile_image_url'] as String?,
  userType: json['user_type'] as String,
  userRole: json['user_role'] as String,
  customerId: (json['customer_id'] as num?)?.toInt(),
  staffId: (json['staff_id'] as num?)?.toInt(),
  supplierId: (json['supplier_id'] as num?)?.toInt(),
  companyName: json['company_name'] as String?,
  taxId: json['tax_id'] as String?,
  addressLine1: json['address_line1'] as String?,
  addressLine2: json['address_line2'] as String?,
  city: json['city'] as String?,
  stateProvince: json['state_province'] as String?,
  postalCode: json['postal_code'] as String?,
  country: json['country'] as String?,
  isActive: json['is_active'] as bool,
  isVerified: json['is_verified'] as bool?,
  isOnline: json['is_online'] as bool?,
  emailVerified: json['email_verified'] as bool?,
  phoneVerified: json['phone_verified'] as bool?,
  twoFactorEnabled: json['two_factor_enabled'] as bool?,
  preferredLanguage: json['preferred_language'] as String?,
  timezone: json['timezone'] as String?,
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  passwordChangedAt: json['password_changed_at'] == null
      ? null
      : DateTime.parse(json['password_changed_at'] as String),
  accountLockedAt: json['account_locked_at'] == null
      ? null
      : DateTime.parse(json['account_locked_at'] as String),
  failedLoginAttempts: (json['failed_login_attempts'] as num?)?.toInt(),
  creditLimit: (json['credit_limit'] as num?)?.toDouble(),
  creditBalance: (json['credit_balance'] as num?)?.toDouble(),
  loyaltyPoints: (json['loyalty_points'] as num?)?.toInt(),
  discountRate: (json['discount_rate'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
  updatedBy: (json['updated_by'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  version: (json['version'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'email': instance.email,
  'password_hash': instance.passwordHash,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'full_name': instance.fullName,
  'display_name': instance.displayName,
  'phone_number': instance.phoneNumber,
  'mobile_number': instance.mobileNumber,
  'date_of_birth': instance.dateOfBirth?.toIso8601String(),
  'gender': instance.gender,
  'profile_image_url': instance.profileImageUrl,
  'user_type': instance.userType,
  'user_role': instance.userRole,
  'customer_id': instance.customerId,
  'staff_id': instance.staffId,
  'supplier_id': instance.supplierId,
  'company_name': instance.companyName,
  'tax_id': instance.taxId,
  'address_line1': instance.addressLine1,
  'address_line2': instance.addressLine2,
  'city': instance.city,
  'state_province': instance.stateProvince,
  'postal_code': instance.postalCode,
  'country': instance.country,
  'is_active': instance.isActive,
  'is_verified': instance.isVerified,
  'is_online': instance.isOnline,
  'email_verified': instance.emailVerified,
  'phone_verified': instance.phoneVerified,
  'two_factor_enabled': instance.twoFactorEnabled,
  'preferred_language': instance.preferredLanguage,
  'timezone': instance.timezone,
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'last_activity_at': instance.lastActivityAt?.toIso8601String(),
  'password_changed_at': instance.passwordChangedAt?.toIso8601String(),
  'account_locked_at': instance.accountLockedAt?.toIso8601String(),
  'failed_login_attempts': instance.failedLoginAttempts,
  'credit_limit': instance.creditLimit,
  'credit_balance': instance.creditBalance,
  'loyalty_points': instance.loyaltyPoints,
  'discount_rate': instance.discountRate,
  'notes': instance.notes,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'version': instance.version,
};
