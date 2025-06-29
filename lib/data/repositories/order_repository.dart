import '../data_sources/order_remote_data_source.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders(int customerId);
  Future<OrderModel> getOrderById(int orderId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrderStatus(int orderId, String status);
  Future<List<OrderModel>> getAllOrders(); // For sales dashboard
  Future<Map<String, dynamic>> getSalesStatistics();
}

class OrderRepositoryImpl implements OrderRepository {
  final OrderDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderModel>> getOrders(int customerId) async {
    return await remoteDataSource.getOrders(customerId);
  }

  @override
  Future<OrderModel> getOrderById(int orderId) async {
    return await remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    return await remoteDataSource.createOrder(order);
  }

  @override
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    return await remoteDataSource.updateOrderStatus(orderId, status);
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    return await remoteDataSource.getAllOrders();
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics() async {
    return await remoteDataSource.getSalesStatistics();
  }
}
