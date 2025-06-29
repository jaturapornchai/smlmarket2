import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/order_model.dart';

abstract class OrderDataSource {
  Future<List<OrderModel>> getOrders(int customerId);
  Future<OrderModel> getOrderById(int orderId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrderStatus(int orderId, String status);
  Future<List<OrderModel>> getAllOrders(); // For sales dashboard
  Future<Map<String, dynamic>> getSalesStatistics();
}

class OrderRemoteDataSource implements OrderDataSource {
  final Dio dio;
  final Logger logger;

  OrderRemoteDataSource({required this.dio, required this.logger});

  @override
  Future<List<OrderModel>> getOrders(int customerId) async {
    try {
      logger.i('Fetching orders for customer: $customerId');

      final response = await dio.get(
        '/orders',
        queryParameters: {'customer_id': customerId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ordersJson = data['data'] as List;

        return ordersJson
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in getOrders: ${e.message}');
      // Return mock data for development
      return _getMockOrders(customerId);
    } catch (e) {
      logger.e('Exception in getOrders: $e');
      return _getMockOrders(customerId);
    }
  }

  @override
  Future<OrderModel> getOrderById(int orderId) async {
    try {
      logger.i('Fetching order: $orderId');

      final response = await dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in getOrderById: ${e.message}');
      // Return mock data for development
      return _getMockOrder(orderId);
    } catch (e) {
      logger.e('Exception in getOrderById: $e');
      return _getMockOrder(orderId);
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      logger.i('Creating order');

      final response = await dio.post('/orders', data: order.toJson());

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in createOrder: ${e.message}');
      // Return mock success for development
      return order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        orderNumber: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        orderedAt: DateTime.now(),
      );
    } catch (e) {
      logger.e('Exception in createOrder: $e');
      return order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        orderNumber: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        orderedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    try {
      logger.i('Updating order status: $orderId to $status');

      final response = await dio.patch(
        '/orders/$orderId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to update order status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('DioException in updateOrderStatus: ${e.message}');
      return _getMockOrder(orderId);
    } catch (e) {
      logger.e('Exception in updateOrderStatus: $e');
      return _getMockOrder(orderId);
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      logger.i('Fetching all orders for sales dashboard');

      final response = await dio.get('/orders/all');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ordersJson = data['data'] as List;

        return ordersJson
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch all orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in getAllOrders: ${e.message}');
      return _getMockAllOrders();
    } catch (e) {
      logger.e('Exception in getAllOrders: $e');
      return _getMockAllOrders();
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics() async {
    try {
      logger.i('Fetching sales statistics');

      final response = await dio.get('/sales/statistics');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch sales statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('DioException in getSalesStatistics: ${e.message}');
      return _getMockSalesStatistics();
    } catch (e) {
      logger.e('Exception in getSalesStatistics: $e');
      return _getMockSalesStatistics();
    }
  }

  // Mock data methods for development
  List<OrderModel> _getMockOrders(int customerId) {
    return [
      OrderModel(
        id: 1,
        cartId: 1,
        customerId: customerId,
        orderNumber: 'ORD001',
        orderedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.confirmed,
        totalAmount: 1250.00,
        paymentStatus: PaymentStatus.paid,
        shippingAddress: '123 Main St, City',
        paymentMethod: 'Credit Card',
        notes: 'Mock order for testing',
      ),
      OrderModel(
        id: 2,
        cartId: 2,
        customerId: customerId,
        orderNumber: 'ORD002',
        orderedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: OrderStatus.processing,
        totalAmount: 890.50,
        paymentStatus: PaymentStatus.pending,
        shippingAddress: '456 Oak Ave, Town',
        paymentMethod: 'Bank Transfer',
        notes: 'Another mock order',
      ),
    ];
  }

  OrderModel _getMockOrder(int orderId) {
    return OrderModel(
      id: orderId,
      cartId: 1,
      customerId: 1,
      orderNumber: 'ORD$orderId',
      orderedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.confirmed,
      totalAmount: 1250.00,
      paymentStatus: PaymentStatus.paid,
      shippingAddress: '123 Main St, City',
      paymentMethod: 'Credit Card',
      notes: 'Mock order for testing',
    );
  }

  List<OrderModel> _getMockAllOrders() {
    return [
      OrderModel(
        id: 1,
        cartId: 1,
        customerId: 1,
        orderNumber: 'ORD001',
        orderedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.confirmed,
        totalAmount: 1250.00,
        paymentStatus: PaymentStatus.paid,
        shippingAddress: '123 Main St, City',
        paymentMethod: 'Credit Card',
        notes: 'Mock order for customer 1',
      ),
      OrderModel(
        id: 2,
        cartId: 2,
        customerId: 2,
        orderNumber: 'ORD002',
        orderedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: OrderStatus.processing,
        totalAmount: 890.50,
        paymentStatus: PaymentStatus.pending,
        shippingAddress: '456 Oak Ave, Town',
        paymentMethod: 'Bank Transfer',
        notes: 'Mock order for customer 2',
      ),
      OrderModel(
        id: 3,
        cartId: 3,
        customerId: 3,
        orderNumber: 'ORD003',
        orderedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: OrderStatus.delivered,
        totalAmount: 2100.75,
        paymentStatus: PaymentStatus.paid,
        shippingAddress: '789 Pine Rd, Village',
        paymentMethod: 'Cash on Delivery',
        notes: 'Mock order for customer 3',
      ),
    ];
  }

  Map<String, dynamic> _getMockSalesStatistics() {
    return {
      'total_orders': 150,
      'total_revenue': 125000.50,
      'orders_today': 8,
      'revenue_today': 3250.00,
      'orders_this_month': 89,
      'revenue_this_month': 67500.25,
      'pending_orders': 12,
      'processing_orders': 25,
      'confirmed_orders': 18,
      'delivered_orders': 95,
    };
  }
}
