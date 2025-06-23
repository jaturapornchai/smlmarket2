import 'package:equatable/equatable.dart';

import '../../data/models/cart_item_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double totalAmount;
  final int totalItems;
  final int? cartId;

  const CartLoaded({
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    this.cartId,
  });

  @override
  List<Object?> get props => [items, totalAmount, totalItems, cartId];
}

class CartSuccess extends CartState {
  final CartItemModel? cartItem;
  final String message;

  const CartSuccess({this.cartItem, required this.message});

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
  final int availableQuantity;
  final String icCode;

  const StockCheckSuccess({
    required this.hasStock,
    required this.availableQuantity,
    required this.icCode,
  });

  @override
  List<Object?> get props => [hasStock, availableQuantity, icCode];
}
