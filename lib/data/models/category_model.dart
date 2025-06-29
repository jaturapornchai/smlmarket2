import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  @JsonKey(name: 'category_id')
  final int categoryId; // รหัสหมวดหมู่ (Primary Key)

  @JsonKey(name: 'category_code')
  final String? categoryCode; // รหัสหมวดหมู่ (เฉพาะ)

  @JsonKey(name: 'category_name')
  final String categoryName; // ชื่อหมวดหมู่

  @JsonKey(name: 'category_name_en')
  final String? categoryNameEn; // ชื่อหมวดหมู่ภาษาอังกฤษ

  @JsonKey(name: 'description')
  final String? description; // คำอธิบายหมวดหมู่

  @JsonKey(name: 'parent_category_id')
  final int? parentCategoryId; // รหัสหมวดหมู่แม่ (สำหรับ hierarchical structure)

  @JsonKey(name: 'parent_category_name')
  final String? parentCategoryName; // ชื่อหมวดหมู่แม่

  @JsonKey(name: 'level')
  final int level; // ระดับของหมวดหมู่ (0 = หมวดหมู่หลัก, 1 = หมวดหมู่ย่อย, 2 = หมวดหมู่ย่อยระดับ 2)

  @JsonKey(name: 'sort_order')
  final int? sortOrder; // ลำดับการแสดง

  @JsonKey(name: 'image_url')
  final String? imageUrl; // รูปภาพประจำหมวดหมู่

  @JsonKey(name: 'icon_url')
  final String? iconUrl; // ไอคอนประจำหมวดหมู่

  @JsonKey(name: 'banner_url')
  final String? bannerUrl; // แบนเนอร์ประจำหมวดหมู่

  @JsonKey(name: 'color_code')
  final String? colorCode; // รหัสสีประจำหมวดหมู่ (HEX)

  @JsonKey(name: 'slug')
  final String? slug; // URL slug สำหรับ SEO

  @JsonKey(name: 'meta_title')
  final String? metaTitle; // หัวข้อ SEO

  @JsonKey(name: 'meta_description')
  final String? metaDescription; // คำอธิบาย SEO

  @JsonKey(name: 'meta_keywords')
  final String? metaKeywords; // คำค้นหา SEO

  @JsonKey(name: 'is_active')
  final bool isActive; // สถานะใช้งาน (true = ใช้งาน, false = ไม่ใช้งาน)

  @JsonKey(name: 'is_featured')
  final bool? isFeatured; // หมวดหมู่แนะนำ (true = แนะนำ, false = ไม่แนะนำ)

  @JsonKey(name: 'is_visible_in_menu')
  final bool? isVisibleInMenu; // แสดงในเมนู (true = แสดง, false = ไม่แสดง)

  @JsonKey(name: 'is_visible_in_search')
  final bool? isVisibleInSearch; // ค้นหาได้ (true = ค้นหาได้, false = ค้นหาไม่ได้)

  @JsonKey(name: 'product_count')
  final int? productCount; // จำนวนสินค้าในหมวดหมู่

  @JsonKey(name: 'subcategory_count')
  final int? subcategoryCount; // จำนวนหมวดหมู่ย่อย

  @JsonKey(name: 'commission_rate')
  final double? commissionRate; // อัตราค่าคอมมิชชัน (%)

  @JsonKey(name: 'discount_rate')
  final double? discountRate; // อัตราส่วนลดพิเศษ (%)

  @JsonKey(name: 'tax_rate')
  final double? taxRate; // อัตราภาษี (%)

  @JsonKey(name: 'tags')
  final List<String>? tags; // แท็กสำหรับการค้นหา

  @JsonKey(name: 'path')
  final String? path; // เส้นทางแบบ hierarchical (เช่น "อิเล็กทรอนิกส์ > โทรศัพท์")

  @JsonKey(name: 'breadcrumb')
  final List<String>? breadcrumb; // Breadcrumb navigation

  @JsonKey(name: 'created_by')
  final int? createdBy; // รหัสผู้สร้างข้อมูล

  @JsonKey(name: 'updated_by')
  final int? updatedBy; // รหัสผู้อัปเดตข้อมูลล่าสุด

  @JsonKey(name: 'created_at')
  final DateTime? createdAt; // วันที่สร้างข้อมูล

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt; // วันที่อัปเดตข้อมูลล่าสุด

  const CategoryModel({
    required this.categoryId,
    this.categoryCode,
    required this.categoryName,
    this.categoryNameEn,
    this.description,
    this.parentCategoryId,
    this.parentCategoryName,
    required this.level,
    this.sortOrder,
    this.imageUrl,
    this.iconUrl,
    this.bannerUrl,
    this.colorCode,
    this.slug,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    required this.isActive,
    this.isFeatured,
    this.isVisibleInMenu,
    this.isVisibleInSearch,
    this.productCount,
    this.subcategoryCount,
    this.commissionRate,
    this.discountRate,
    this.taxRate,
    this.tags,
    this.path,
    this.breadcrumb,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  // Helper methods
  bool get isRootCategory => level == 0; // หมวดหมู่หลัก
  bool get isSubcategory => level > 0; // หมวดหมู่ย่อย
  bool get hasSubcategories => (subcategoryCount ?? 0) > 0; // มีหมวดหมู่ย่อย
  bool get hasProducts => (productCount ?? 0) > 0; // มีสินค้า
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty; // มีรูปภาพ
  bool get hasIcon => iconUrl != null && iconUrl!.isNotEmpty; // มีไอคอน
  bool get hasBanner =>
      bannerUrl != null && bannerUrl!.isNotEmpty; // มีแบนเนอร์
  bool get hasSpecialDiscount =>
      discountRate != null && discountRate! > 0; // มีส่วนลดพิเศษ
  bool get hasCommission =>
      commissionRate != null && commissionRate! > 0; // มีค่าคอมมิชชัน
  bool get isPopular => (productCount ?? 0) > 50; // หมวดหมู่ยอดนิยม

  String get displayName => categoryName; // ชื่อที่แสดง
  String get fullDisplayName => categoryNameEn != null
      ? '$categoryName ($categoryNameEn)'
      : categoryName; // ชื่อเต็มที่แสดง
  String get levelDisplayName {
    switch (level) {
      case 0:
        return 'หมวดหมู่หลัก';
      case 1:
        return 'หมวดหมู่ย่อย';
      case 2:
        return 'หมวดหมู่ย่อยระดับ 2';
      case 3:
        return 'หมวดหมู่ย่อยระดับ 3';
      default:
        return 'หมวดหมู่ระดับ $level';
    }
  }

  String get statusDisplayName {
    if (!isActive) return 'ไม่ใช้งาน';
    if (isFeatured == true) return 'แนะนำ';
    return 'ปกติ';
  }

  // สร้าง breadcrumb navigation
  String get breadcrumbString => breadcrumb?.join(' > ') ?? displayName;

  // สร้าง full path
  String get fullPath => path ?? displayName;
}
