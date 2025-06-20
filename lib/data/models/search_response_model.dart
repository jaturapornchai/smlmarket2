import 'package:equatable/equatable.dart';
import 'product_model.dart';

class SearchResponseModel extends Equatable {
  final bool success;
  final SearchDataModel? data;
  final String? message;

  const SearchResponseModel({required this.success, this.data, this.message});

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? SearchDataModel.fromJson(json['data'])
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson(), 'message': message};
  }

  @override
  List<Object?> get props => [success, data, message];
}

class SearchDataModel extends Equatable {
  final List<ProductModel> products;
  final int total;

  const SearchDataModel({required this.products, required this.total});
  factory SearchDataModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    final List<ProductModel> products = dataList
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchDataModel(
      products: products,
      total: json['total'] ?? json['total_count'] ?? products.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': products.map((product) => product.toJson()).toList(),
      'total': total,
    };
  }

  @override
  List<Object?> get props => [products, total];
}
