import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository;
  final Logger logger;

  OrderCubit({required this.repository, required this.logger})
    : super(OrderInitial());

  /// ดึงรายการคำสั่งซื้อของลูกค้า
  Future<void> getOrders(int customerId) async {
    try {
      emit(OrderLoading());
      logger.i('Fetching orders for customer: $customerId');

      final orders = await repository.getOrders(customerId);
      emit(OrderLoaded(orders));

      logger.i('Successfully loaded ${orders.length} orders');
    } catch (e) {
      logger.e('Error fetching orders: $e');
      emit(OrderError('ไม่สามารถดึงข้อมูลคำสั่งซื้อได้: $e'));
    }
  }

  /// ดึงรายละเอียดคำสั่งซื้อ
  Future<void> getOrderById(int orderId) async {
    try {
      emit(OrderLoading());
      logger.i('Fetching order details: $orderId');

      final order = await repository.getOrderById(orderId);
      emit(OrderDetailLoaded(order));

      logger.i('Successfully loaded order: ${order.orderNumber}');
    } catch (e) {
      logger.e('Error fetching order details: $e');
      emit(OrderError('ไม่สามารถดึงข้อมูลคำสั่งซื้อได้: $e'));
    }
  }

  /// สร้างคำสั่งซื้อใหม่
  Future<void> createOrder(OrderModel order) async {
    try {
      emit(OrderLoading());
      logger.i('Creating new order for customer: ${order.customerId}');

      final createdOrder = await repository.createOrder(order);
      emit(OrderCreated(createdOrder));

      logger.i('Successfully created order: ${createdOrder.orderNumber}');
    } catch (e) {
      logger.e('Error creating order: $e');
      emit(OrderError('ไม่สามารถสร้างคำสั่งซื้อได้: $e'));
    }
  }

  /// อัปเดตสถานะคำสั่งซื้อ
  Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    try {
      emit(OrderLoading());
      logger.i('Updating order status: $orderId to ${status.name}');

      final updatedOrder = await repository.updateOrderStatus(
        orderId,
        status.name,
      );
      emit(OrderStatusUpdated(updatedOrder));

      logger.i(
        'Successfully updated order status: ${updatedOrder.orderNumber}',
      );
    } catch (e) {
      logger.e('Error updating order status: $e');
      emit(OrderError('ไม่สามารถอัปเดตสถานะคำสั่งซื้อได้: $e'));
    }
  }

  /// ดึงสถิติการขาย (สำหรับพนักงาน)
  Future<void> getSalesStatistics() async {
    try {
      emit(SalesStatsLoading());
      logger.i('Fetching sales statistics');

      final stats = await repository.getSalesStatistics();
      final allOrders = await repository.getAllOrders();

      emit(SalesStatsLoaded(statistics: stats, allOrders: allOrders));

      logger.i('Successfully loaded sales statistics');
    } catch (e) {
      logger.e('Error fetching sales statistics: $e');
      emit(SalesStatsError('ไม่สามารถดึงข้อมูลสถิติการขายได้: $e'));
    }
  }

  /// ดึงคำสั่งซื้อทั้งหมด (สำหรับพนักงาน)
  Future<void> getAllOrders() async {
    try {
      emit(OrderLoading());
      logger.i('Fetching all orders for staff');

      final orders = await repository.getAllOrders();
      emit(OrderLoaded(orders));

      logger.i('Successfully loaded ${orders.length} orders for staff');
    } catch (e) {
      logger.e('Error fetching all orders: $e');
      emit(OrderError('ไม่สามารถดึงข้อมูลคำสั่งซื้อได้: $e'));
    }
  }

  /// รีเซ็ตสถานะ
  void reset() {
    emit(OrderInitial());
  }
}
