import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../widgets/custom_app_bar.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'รายละเอียดคำสั่งซื้อ #${widget.order.orderNumber}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 16),
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildShippingSection(),
            const SizedBox(height: 16),
            _buildOrderItemsSection(),
            const SizedBox(height: 16),
            _buildSummarySection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ข้อมูลคำสั่งซื้อ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(widget.order.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('หมายเลขคำสั่งซื้อ', widget.order.orderNumber),
            _buildInfoRow(
              'วันที่สั่งซื้อ',
              _formatDate(widget.order.orderedAt ?? DateTime.now()),
            ),
            _buildInfoRow('วิธีการชำระเงิน', _getPaymentMethodText()),
            _buildInfoRow('สถานะการชำระ', _getPaymentStatusText()),
            if (widget.order.notes?.isNotEmpty == true)
              _buildInfoRow('หมายเหตุ', widget.order.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถานะการสั่งซื้อ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSection() {
    if (widget.order.shippingAddress?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ที่อยู่จัดส่ง',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.order.shippingAddress!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    final mockItems = _generateMockOrderItems();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการสินค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...mockItems.map((item) => _buildOrderItemCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'รหัส: ${item.icCode}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (item.barcode?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Barcode: ${item.barcode}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'จำนวน: ${item.quantity.toStringAsFixed(0)} ${item.unitCode ?? ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '฿${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปยอดรวม',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมทั้งสิ้น',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '฿${widget.order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.order.paymentStatus != PaymentStatus.paid) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/payment',
                  arguments: widget.order,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ชำระเงิน', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showCancelDialog();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'ยกเลิกคำสั่งซื้อ',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildStatusTimeline() {
    final statuses = [
      {'status': 'รอดำเนินการ', 'completed': true},
      {
        'status': 'ยืนยันแล้ว',
        'completed': _isStatusCompleted(OrderStatus.confirmed),
      },
      {
        'status': 'กำลังเตรียม',
        'completed': _isStatusCompleted(OrderStatus.processing),
      },
      {
        'status': 'จัดส่งแล้ว',
        'completed': _isStatusCompleted(OrderStatus.shipped),
      },
      {
        'status': 'ส่งมอบแล้ว',
        'completed': _isStatusCompleted(OrderStatus.delivered),
      },
    ];

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final statusData = entry.value;
        final isLast = index == statuses.length - 1;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusData['completed'] as bool
                        ? Colors.green
                        : Colors.grey[300],
                  ),
                  child: statusData['completed'] as bool
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  statusData['status'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: statusData['completed'] as bool
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: statusData['completed'] as bool
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _isStatusCompleted(OrderStatus targetStatus) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(widget.order.status);
    final targetIndex = statusOrder.indexOf(targetStatus);

    return currentIndex >= targetIndex;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodText() {
    switch (widget.order.paymentMethod) {
      case 'cash':
        return 'เงินสด';
      case 'credit_card':
        return 'บัตรเครดิต';
      case 'bank_transfer':
        return 'โอนเงิน';
      case 'qr_code':
        return 'QR Code';
      case 'prompt_pay':
        return 'พร้อมเพย์';
      default:
        return widget.order.paymentMethod ?? 'ไม่ระบุ';
    }
  }

  String _getPaymentStatusText() {
    switch (widget.order.paymentStatus) {
      case PaymentStatus.pending:
        return 'รอชำระเงิน';
      case PaymentStatus.paid:
        return 'ชำระแล้ว';
      case PaymentStatus.failed:
        return 'ชำระไม่สำเร็จ';
      case PaymentStatus.refunded:
        return 'คืนเงินแล้ว';
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกคำสั่งซื้อ'),
        content: const Text('คุณต้องการยกเลิกคำสั่งซื้อนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ไม่ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ยกเลิกคำสั่งซื้อแล้ว')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  List<OrderItemModel> _generateMockOrderItems() {
    return [
      OrderItemModel(
        id: 1,
        orderId: widget.order.id!,
        icCode: 'IC001',
        productName: 'สินค้าตัวอย่าง 1',
        barcode: '1234567890123',
        unitCode: 'ชิ้น',
        quantity: 2,
        unitPrice: 850.00,
        totalPrice: 1700.00,
      ),
      OrderItemModel(
        id: 2,
        orderId: widget.order.id!,
        icCode: 'IC002',
        productName: 'สินค้าตัวอย่าง 2',
        barcode: '9876543210987',
        unitCode: 'กล่อง',
        quantity: 1,
        unitPrice: 800.00,
        totalPrice: 800.00,
      ),
    ];
  }
}
