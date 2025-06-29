// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      categoryId: (json['category_id'] as num).toInt(),
      categoryCode: json['category_code'] as String?,
      categoryName: json['category_name'] as String,
      categoryNameEn: json['category_name_en'] as String?,
      description: json['description'] as String?,
      parentCategoryId: (json['parent_category_id'] as num?)?.toInt(),
      parentCategoryName: json['parent_category_name'] as String?,
      level: (json['level'] as num).toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      iconUrl: json['icon_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      colorCode: json['color_code'] as String?,
      slug: json['slug'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      metaKeywords: json['meta_keywords'] as String?,
      isActive: json['is_active'] as bool,
      isFeatured: json['is_featured'] as bool?,
      isVisibleInMenu: json['is_visible_in_menu'] as bool?,
      isVisibleInSearch: json['is_visible_in_search'] as bool?,
      productCount: (json['product_count'] as num?)?.toInt(),
      subcategoryCount: (json['subcategory_count'] as num?)?.toInt(),
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),
      discountRate: (json['discount_rate'] as num?)?.toDouble(),
      taxRate: (json['tax_rate'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      path: json['path'] as String?,
      breadcrumb: (json['breadcrumb'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdBy: (json['created_by'] as num?)?.toInt(),
      updatedBy: (json['updated_by'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_code': instance.categoryCode,
      'category_name': instance.categoryName,
      'category_name_en': instance.categoryNameEn,
      'description': instance.description,
      'parent_category_id': instance.parentCategoryId,
      'parent_category_name': instance.parentCategoryName,
      'level': instance.level,
      'sort_order': instance.sortOrder,
      'image_url': instance.imageUrl,
      'icon_url': instance.iconUrl,
      'banner_url': instance.bannerUrl,
      'color_code': instance.colorCode,
      'slug': instance.slug,
      'meta_title': instance.metaTitle,
      'meta_description': instance.metaDescription,
      'meta_keywords': instance.metaKeywords,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'is_visible_in_menu': instance.isVisibleInMenu,
      'is_visible_in_search': instance.isVisibleInSearch,
      'product_count': instance.productCount,
      'subcategory_count': instance.subcategoryCount,
      'commission_rate': instance.commissionRate,
      'discount_rate': instance.discountRate,
      'tax_rate': instance.taxRate,
      'tags': instance.tags,
      'path': instance.path,
      'breadcrumb': instance.breadcrumb,
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
