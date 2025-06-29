import 'package:equatable/equatable.dart';

import '../../data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;

  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrderState {
  final OrderModel order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderStatusUpdated extends OrderState {
  final OrderModel order;

  const OrderStatusUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Sales Dashboard specific states
class SalesStatsLoading extends OrderState {}

class SalesStatsLoaded extends OrderState {
  final Map<String, dynamic> statistics;
  final List<OrderModel> allOrders;

  const SalesStatsLoaded({required this.statistics, required this.allOrders});

  @override
  List<Object?> get props => [statistics, allOrders];
}

class SalesStatsError extends OrderState {
  final String message;

  const SalesStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
