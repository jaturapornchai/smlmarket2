import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductSearchState extends Equatable {
  const ProductSearchState();

  @override
  List<Object?> get props => [];
}

class ProductSearchInitial extends ProductSearchState {}

class ProductSearchLoading extends ProductSearchState {}

class ProductSearchLoadingMore extends ProductSearchState {
  final List<ProductModel> currentProducts;
  final String query;
  final bool aiEnabled;

  const ProductSearchLoadingMore({
    required this.currentProducts,
    required this.query,
    required this.aiEnabled,
  });

  @override
  List<Object?> get props => [currentProducts, query, aiEnabled];
}

class ProductSearchSuccess extends ProductSearchState {
  final List<ProductModel> products;
  final String query;
  final bool aiEnabled;
  final int total;
  final bool hasReachedMax;

  const ProductSearchSuccess({
    required this.products,
    required this.query,
    required this.aiEnabled,
    required this.total,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [products, query, aiEnabled, total, hasReachedMax];

  // เพิ่ม getter สำหรับความเข้ากันได้
  bool get isLoadingMore => false;

  ProductSearchSuccess copyWith({
    List<ProductModel>? products,
    String? query,
    bool? aiEnabled,
    int? total,
    bool? hasReachedMax,
  }) {
    return ProductSearchSuccess(
      products: products ?? this.products,
      query: query ?? this.query,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ProductSearchError extends ProductSearchState {
  final String message;
  final String? query;

  const ProductSearchError({required this.message, this.query});

  @override
  List<Object?> get props => [message, query];
}

class ProductSearchEmpty extends ProductSearchState {
  final String query;

  const ProductSearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}
