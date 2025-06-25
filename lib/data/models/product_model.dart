import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  // ✅ Existing fields
  final String? id;
  final String? code;
  final String? name;
  final String? unitStandardCode;
  final int? itemType;
  final int? rowOrderRef;
  final int? searchPriority;
  final double? price; // เก็บไว้เพื่อ backward compatibility
  final String? imgUrl;
  final int? balanceQty;
  final double? similarityScore;
  // 🆕 NEW fields
  final double? salePrice;
  final String? premiumWord;
  final double? discountPrice;
  final double? discountPercent;
  final String? discountWord;
  final double? finalPrice;
  final double? soldQty;
  final int? multiPacking;
  final String? multiPackingName;
  final String? barcodes;
  final double? qtyAvailable; // 🔥 NEWEST field

  const ProductModel({
    // ✅ Existing fields
    this.id,
    this.code,
    this.name,
    this.unitStandardCode,
    this.itemType,
    this.rowOrderRef,
    this.searchPriority,
    this.price,
    this.imgUrl,
    this.balanceQty,
    this.similarityScore, // 🆕 NEW fields
    this.salePrice,
    this.premiumWord,
    this.discountPrice,
    this.discountPercent,
    this.discountWord,
    this.finalPrice,
    this.soldQty,
    this.multiPacking,
    this.multiPackingName,
    this.barcodes,
    this.qtyAvailable, // 🔥 NEWEST field
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // ✅ Existing fields
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      unitStandardCode: json['unit_standard_code']?.toString(),
      itemType: json['item_type']?.toInt(),
      rowOrderRef: json['row_order_ref']?.toInt(),
      searchPriority: json['search_priority']?.toInt(),
      price: _parseDouble(json['price']), // backward compatibility
      imgUrl: json['img_url']?.toString(),
      balanceQty: json['balance_qty']?.toInt(),
      similarityScore: _parseDouble(json['similarity_score']), // 🆕 NEW fields
      salePrice: _parseDouble(json['sale_price']),
      premiumWord: json['premium_word']?.toString(),
      discountPrice: _parseDouble(json['discount_price']),
      discountPercent: _parseDouble(json['discount_percent']),
      discountWord: json['discount_word']?.toString(),
      finalPrice: _parseDouble(json['final_price']),
      soldQty: _parseDouble(json['sold_qty']),
      multiPacking: json['multi_packing']?.toInt(),
      multiPackingName: json['multi_packing_name']?.toString(),
      barcodes: json['barcodes']?.toString(),
      qtyAvailable: _parseDouble(json['qty_available']), // 🔥 NEWEST field
    );
  }
  Map<String, dynamic> toJson() {
    return {
      // ✅ Existing fields
      'id': id,
      'code': code,
      'name': name,
      'unit_standard_code': unitStandardCode,
      'item_type': itemType,
      'row_order_ref': rowOrderRef,
      'search_priority': searchPriority,
      'price': price,
      'img_url': imgUrl,
      'balance_qty': balanceQty,
      'similarity_score': similarityScore, // 🆕 NEW fields
      'sale_price': salePrice,
      'premium_word': premiumWord,
      'discount_price': discountPrice,
      'discount_percent': discountPercent,
      'discount_word': discountWord,
      'final_price': finalPrice,
      'sold_qty': soldQty,
      'multi_packing': multiPacking,
      'multi_packing_name': multiPackingName,
      'barcodes': barcodes,
      'qty_available': qtyAvailable, // 🔥 NEWEST field
    };
  }

  @override
  List<Object?> get props => [
    // ✅ Existing fields
    id,
    code,
    name,
    unitStandardCode,
    itemType,
    rowOrderRef,
    searchPriority,
    price,
    imgUrl,
    balanceQty,
    similarityScore, // 🆕 NEW fields
    salePrice,
    premiumWord,
    discountPrice,
    discountPercent,
    discountWord,
    finalPrice,
    soldQty,
    multiPacking,
    multiPackingName,
    barcodes,
    qtyAvailable, // 🔥 NEWEST field
  ];
  // 🛠️ Helper methods for better price handling
  double get displayPrice {
    return finalPrice ?? salePrice ?? price ?? 0.0;
  }

  bool get hasDiscount {
    return (discountPrice != null && discountPrice! > 0) ||
        (discountPercent != null && discountPercent! > 0) ||
        (discountWord != null && discountWord!.isNotEmpty);
  }

  bool get hasPriceDiscrepancy {
    return salePrice != null && finalPrice != null && salePrice != finalPrice;
  }

  bool get hasDiscountPrice {
    return discountPrice != null && discountPrice! > 0;
  }

  bool get hasDiscountPercent {
    return discountPercent != null && discountPercent! > 0;
  }

  bool get hasDiscountWord {
    return discountWord != null && discountWord!.isNotEmpty;
  }

  bool get hasSoldQty {
    return soldQty != null && soldQty! > 0;
  }

  bool get hasPremiumWord {
    return premiumWord != null && premiumWord!.isNotEmpty;
  }

  bool get hasMultiPackingName {
    return multiPackingName != null && multiPackingName!.isNotEmpty;
  }

  double get availableQty {
    return qtyAvailable ?? 0.0;
  }

  List<String> get barcodeList {
    if (barcodes == null || barcodes!.isEmpty) return [];
    return barcodes!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> get packingOptions {
    if (multiPackingName == null || multiPackingName!.isEmpty) return [];
    return multiPackingName!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool get hasMultiplePacking {
    return multiPacking == 1 && packingOptions.isNotEmpty;
  }

  /// Helper method to safely parse dynamic values to double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
