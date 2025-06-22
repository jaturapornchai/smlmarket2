import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final CartItemModel cartItem;
  final String message;

  const CartSuccess({
    required this.cartItem,
    required this.message,
  });

  @override
  List<Object?> get props => [cartItem, message];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StockCheckSuccess extends CartState {
  final bool hasStock;
  final double availableQuantity;
  final int productId;

  const StockCheckSuccess({
    required this.hasStock,
    required this.availableQuantity,
    required this.productId,
  });

  @override
  List<Object?> get props => [hasStock, availableQuantity, productId];
}
