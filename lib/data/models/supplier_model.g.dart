// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplierModel _$SupplierModelFromJson(Map<String, dynamic> json) =>
    SupplierModel(
      supplierId: (json['supplier_id'] as num).toInt(),
      supplierCode: json['supplier_code'] as String?,
      supplierName: json['supplier_name'] as String,
      companyName: json['company_name'] as String?,
      companyNameEn: json['company_name_en'] as String?,
      businessType: json['business_type'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactTitle: json['contact_title'] as String?,
      email: json['email'] as String?,
      secondaryEmail: json['secondary_email'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      fax: json['fax'] as String?,
      website: json['website'] as String?,
      taxId: json['tax_id'] as String?,
      vatRegistration: json['vat_registration'] as String?,
      businessLicense: json['business_license'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      stateProvince: json['state_province'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      billingAddressLine1: json['billing_address_line1'] as String?,
      billingAddressLine2: json['billing_address_line2'] as String?,
      billingCity: json['billing_city'] as String?,
      billingStateProvince: json['billing_state_province'] as String?,
      billingPostalCode: json['billing_postal_code'] as String?,
      billingCountry: json['billing_country'] as String?,
      bankName: json['bank_name'] as String?,
      bankBranch: json['bank_branch'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      swiftCode: json['swift_code'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      paymentMethod: json['payment_method'] as String?,
      creditLimit: (json['credit_limit'] as num?)?.toDouble(),
      creditDays: (json['credit_days'] as num?)?.toInt(),
      currencyCode: json['currency_code'] as String?,
      deliveryTerms: json['delivery_terms'] as String?,
      leadTimeDays: (json['lead_time_days'] as num?)?.toInt(),
      minimumOrderAmount: (json['minimum_order_amount'] as num?)?.toDouble(),
      discountRate: (json['discount_rate'] as num?)?.toDouble(),
      supplierRating: (json['supplier_rating'] as num?)?.toDouble(),
      qualityRating: (json['quality_rating'] as num?)?.toDouble(),
      deliveryRating: (json['delivery_rating'] as num?)?.toDouble(),
      serviceRating: (json['service_rating'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool,
      isPreferred: json['is_preferred'] as bool?,
      isBlacklisted: json['is_blacklisted'] as bool?,
      isVerified: json['is_verified'] as bool?,
      verificationDate: json['verification_date'] == null
          ? null
          : DateTime.parse(json['verification_date'] as String),
      contractStartDate: json['contract_start_date'] == null
          ? null
          : DateTime.parse(json['contract_start_date'] as String),
      contractEndDate: json['contract_end_date'] == null
          ? null
          : DateTime.parse(json['contract_end_date'] as String),
      lastOrderDate: json['last_order_date'] == null
          ? null
          : DateTime.parse(json['last_order_date'] as String),
      lastPaymentDate: json['last_payment_date'] == null
          ? null
          : DateTime.parse(json['last_payment_date'] as String),
      totalOrders: (json['total_orders'] as num?)?.toInt(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble(),
      productsCount: (json['products_count'] as num?)?.toInt(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specializations: (json['specializations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      internalNotes: json['internal_notes'] as String?,
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

Map<String, dynamic> _$SupplierModelToJson(SupplierModel instance) =>
    <String, dynamic>{
      'supplier_id': instance.supplierId,
      'supplier_code': instance.supplierCode,
      'supplier_name': instance.supplierName,
      'company_name': instance.companyName,
      'company_name_en': instance.companyNameEn,
      'business_type': instance.businessType,
      'contact_person': instance.contactPerson,
      'contact_title': instance.contactTitle,
      'email': instance.email,
      'secondary_email': instance.secondaryEmail,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'fax': instance.fax,
      'website': instance.website,
      'tax_id': instance.taxId,
      'vat_registration': instance.vatRegistration,
      'business_license': instance.businessLicense,
      'address_line1': instance.addressLine1,
      'address_line2': instance.addressLine2,
      'city': instance.city,
      'state_province': instance.stateProvince,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'billing_address_line1': instance.billingAddressLine1,
      'billing_address_line2': instance.billingAddressLine2,
      'billing_city': instance.billingCity,
      'billing_state_province': instance.billingStateProvince,
      'billing_postal_code': instance.billingPostalCode,
      'billing_country': instance.billingCountry,
      'bank_name': instance.bankName,
      'bank_branch': instance.bankBranch,
      'account_number': instance.accountNumber,
      'account_name': instance.accountName,
      'swift_code': instance.swiftCode,
      'payment_terms': instance.paymentTerms,
      'payment_method': instance.paymentMethod,
      'credit_limit': instance.creditLimit,
      'credit_days': instance.creditDays,
      'currency_code': instance.currencyCode,
      'delivery_terms': instance.deliveryTerms,
      'lead_time_days': instance.leadTimeDays,
      'minimum_order_amount': instance.minimumOrderAmount,
      'discount_rate': instance.discountRate,
      'supplier_rating': instance.supplierRating,
      'quality_rating': instance.qualityRating,
      'delivery_rating': instance.deliveryRating,
      'service_rating': instance.serviceRating,
      'is_active': instance.isActive,
      'is_preferred': instance.isPreferred,
      'is_blacklisted': instance.isBlacklisted,
      'is_verified': instance.isVerified,
      'verification_date': instance.verificationDate?.toIso8601String(),
      'contract_start_date': instance.contractStartDate?.toIso8601String(),
      'contract_end_date': instance.contractEndDate?.toIso8601String(),
      'last_order_date': instance.lastOrderDate?.toIso8601String(),
      'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
      'total_orders': instance.totalOrders,
      'total_amount': instance.totalAmount,
      'outstanding_amount': instance.outstandingAmount,
      'products_count': instance.productsCount,
      'categories': instance.categories,
      'specializations': instance.specializations,
      'certifications': instance.certifications,
      'documents': instance.documents,
      'notes': instance.notes,
      'internal_notes': instance.internalNotes,
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'version': instance.version,
    };
