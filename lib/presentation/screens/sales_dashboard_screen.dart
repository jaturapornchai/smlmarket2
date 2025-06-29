import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../cubit/order_cubit.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state_widget.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load sales statistics and orders
    context.read<OrderCubit>().getSalesStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sales Dashboard'),
      body: Column(
        children: [
          _buildStatsCards(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingQuotations(),
                _buildNegotiations(),
                _buildCompletedQuotations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'รออนุมัติ',
              '12',
              Colors.orange,
              Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'กำลังต่อรอง',
              '5',
              Colors.blue,
              Icons.handshake,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'สำเร็จแล้ว',
              '38',
              Colors.green,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'รออนุมัติ'),
          Tab(text: 'กำลังต่อรอง'),
          Tab(text: 'สำเร็จแล้ว'),
        ],
      ),
    );
  }

  Widget _buildPendingQuotations() {
    final quotations = _generateMockQuotations(QuotationStatus.pending);

    if (quotations.isEmpty) {
      return const EmptyStateWidget(
        message: 'ไม่มีใบยืนยันราคาที่รออนุมัติ',
        icon: Icons.pending_actions,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotations.length,
      itemBuilder: (context, index) {
        final quotation = quotations[index];
        return _buildQuotationCard(quotation, _buildPendingActions(quotation));
      },
    );
  }

  Widget _buildNegotiations() {
    final quotations = _generateMockQuotations(QuotationStatus.negotiating);

    if (quotations.isEmpty) {
      return const EmptyStateWidget(
        message: 'ไม่มีใบยืนยันราคาที่กำลังต่อรอง',
        icon: Icons.handshake,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotations.length,
      itemBuilder: (context, index) {
        final quotation = quotations[index];
        return _buildQuotationCard(
          quotation,
          _buildNegotiationActions(quotation),
        );
      },
    );
  }

  Widget _buildCompletedQuotations() {
    final quotations = _generateMockQuotations(QuotationStatus.confirmed);

    if (quotations.isEmpty) {
      return const EmptyStateWidget(
        message: 'ไม่มีใบยืนยันราคาที่สำเร็จแล้ว',
        icon: Icons.check_circle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotations.length,
      itemBuilder: (context, index) {
        final quotation = quotations[index];
        return _buildQuotationCard(
          quotation,
          _buildCompletedActions(quotation),
        );
      },
    );
  }

  Widget _buildQuotationCard(Quotation quotation, Widget actions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ใบยืนยัน #${quotation.quotationNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(quotation.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ลูกค้า ID: ${quotation.customerId}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'วันที่สร้าง: ${_formatDate(quotation.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quotation.totalItems.toStringAsFixed(0)} รายการ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '฿${quotation.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (quotation.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quotation.notes!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            actions,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(QuotationStatus status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case QuotationStatus.pending:
        statusText = 'รออนุมัติ';
        statusColor = Colors.orange;
        break;
      case QuotationStatus.confirmed:
        statusText = 'อนุมัติแล้ว';
        statusColor = Colors.green;
        break;
      case QuotationStatus.cancelled:
        statusText = 'ยกเลิก';
        statusColor = Colors.red;
        break;
      case QuotationStatus.negotiating:
        statusText = 'กำลังต่อรอง';
        statusColor = Colors.blue;
        break;
      case QuotationStatus.completed:
        statusText = 'สำเร็จ';
        statusColor = Colors.green;
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

  Widget _buildPendingActions(Quotation quotation) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(quotation),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('ปฏิเสธ'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _approveQuotation(quotation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('อนุมัติ'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showNegotiationDialog(quotation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('ต่อรอง'),
          ),
        ),
      ],
    );
  }

  Widget _buildNegotiationActions(Quotation quotation) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(quotation),
            child: const Text('ยกเลิก'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showNegotiationDialog(quotation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('ต่อรองใหม่'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _approveQuotation(quotation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยอมรับ'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActions(Quotation quotation) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/quotation-detail',
                arguments: quotation,
              );
            },
            child: const Text('ดูรายละเอียด'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _createOrderFromQuotation(quotation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('สร้างออเดอร์'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _approveQuotation(Quotation quotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('อนุมัติใบยืนยันราคา'),
        content: Text(
          'คุณต้องการอนุมัติใบยืนยันราคา #${quotation.quotationNumber} หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement approve logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อนุมัติใบยืนยันราคาแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('อนุมัติ'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Quotation quotation) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ปฏิเสธใบยืนยันราคา'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'คุณต้องการปฏิเสธใบยืนยันราคา #${quotation.quotationNumber} หรือไม่?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'เหตุผล (ไม่บังคับ)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              // TODO: Implement reject logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ปฏิเสธใบยืนยันราคาแล้ว'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ปฏิเสธ'),
          ),
        ],
      ),
    );
  }

  void _showNegotiationDialog(Quotation quotation) {
    final priceController = TextEditingController(
      text: quotation.totalAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เสนอราคาใหม่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ใบยืนยันราคา #${quotation.quotationNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'ราคาใหม่',
                border: OutlineInputBorder(),
                prefixText: '฿',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'หมายเหตุ (ไม่บังคับ)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              // TODO: Implement negotiation logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งข้อเสนอใหม่แล้ว'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('ส่งข้อเสนอ'),
          ),
        ],
      ),
    );
  }

  void _createOrderFromQuotation(Quotation quotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างคำสั่งซื้อ'),
        content: Text(
          'คุณต้องการสร้างคำสั่งซื้อจากใบยืนยันราคา #${quotation.quotationNumber} หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement create order logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('สร้างคำสั่งซื้อแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('สร้างคำสั่งซื้อ'),
          ),
        ],
      ),
    );
  }

  List<Quotation> _generateMockQuotations(QuotationStatus status) {
    final baseQuotations = [
      Quotation(
        id: 1,
        cartId: 1,
        customerId: 1,
        quotationNumber: 'QU-2025-001',
        status: status,
        totalAmount: 2500.00,
        totalItems: 3,
        originalTotalAmount: 2800.00,
        notes: 'ต้องการสินค้าคุณภาพดี',
        sellerNotes: null,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        confirmedAt: null,
        cancelledAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Quotation(
        id: 2,
        cartId: 2,
        customerId: 2,
        quotationNumber: 'QU-2025-002',
        status: status,
        totalAmount: 1800.00,
        totalItems: 2,
        originalTotalAmount: 1800.00,
        notes: 'ขอราคาพิเศษ',
        sellerNotes: null,
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        confirmedAt: null,
        cancelledAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];

    return baseQuotations;
  }
}
