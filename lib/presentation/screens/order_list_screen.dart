import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class OrderListScreen extends StatefulWidget {
  final int customerId;

  const OrderListScreen({super.key, required this.customerId});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    // Load orders for customer
    context.read<OrderCubit>().getOrders(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'รายการคำสั่งซื้อ'),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('ทั้งหมด', true),
            const SizedBox(width: 8),
            _buildFilterChip('รอดำเนินการ', false),
            const SizedBox(width: 8),
            _buildFilterChip('ยืนยันแล้ว', false),
            const SizedBox(width: 8),
            _buildFilterChip('กำลังเตรียม', false),
            const SizedBox(width: 8),
            _buildFilterChip('จัดส่งแล้ว', false),
            const SizedBox(width: 8),
            _buildFilterChip('สำเร็จ', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Filter orders by status
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor,
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildOrdersList() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const LoadingWidget();
        } else if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return const EmptyStateWidget(
              message: 'ยังไม่มีคำสั่งซื้อ',
              icon: Icons.shopping_bag_outlined,
            );
          }
          return _buildOrdersListView(state.orders);
        } else if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderCubit>().getOrders(widget.customerId);
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }
        return const EmptyStateWidget(
          message: 'ยังไม่มีคำสั่งซื้อ',
          icon: Icons.shopping_bag_outlined,
        );
      },
    );
  }

  Widget _buildOrdersListView(List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/order-detail', arguments: order);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'คำสั่งซื้อ #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'วันที่สั่งซื้อ: ${_formatDate(order.orderedAt ?? DateTime.now())}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'คำสั่งซื้อ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    '฿${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (order.paymentStatus != PaymentStatus.paid) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ชำระเงิน'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case OrderStatus.pending:
        statusText = 'รอดำเนินการ';
        statusColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        statusText = 'ยืนยันแล้ว';
        statusColor = Colors.green;
        break;
      case OrderStatus.processing:
        statusText = 'กำลังเตรียม';
        statusColor = Colors.blue;
        break;
      case OrderStatus.shipped:
        statusText = 'จัดส่งแล้ว';
        statusColor = Colors.purple;
        break;
      case OrderStatus.delivered:
        statusText = 'ส่งมอบแล้ว';
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusText = 'ยกเลิก';
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPaymentDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ชำระเงิน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('คำสั่งซื้อ #${order.orderNumber}'),
            const SizedBox(height: 8),
            Text(
              'ยอดรวม: ฿${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/payment', arguments: order);
            },
            child: const Text('ไปหน้าชำระเงิน'),
          ),
        ],
      ),
    );
  }
}
