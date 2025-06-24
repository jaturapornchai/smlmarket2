import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../utils/number_formatter.dart';
import 'negotiation_screen.dart';

/// หน้าจอรายละเอียดใบขอยืนยันราคาและขอยืนยันจำนวน
class QuotationDetailScreen extends StatefulWidget {
  final Quotation quotation;

  const QuotationDetailScreen({super.key, required this.quotation});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Quotation currentQuotation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    currentQuotation = widget.quotation;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentQuotation.quotationNumber),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshQuotation,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (currentQuotation.status == QuotationStatus.pending ||
                  currentQuotation.status == QuotationStatus.negotiating)
                const PopupMenuItem(
                  value: 'negotiate',
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline),
                      SizedBox(width: 8),
                      Text('ต่อรองราคา'),
                    ],
                  ),
                ),
              if (currentQuotation.status == QuotationStatus.pending ||
                  currentQuotation.status == QuotationStatus.negotiating)
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text('ยกเลิก', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'ข้อมูลใบ'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'รายการสินค้า'),
            Tab(icon: Icon(Icons.chat_bubble), text: 'ประวัติการต่อรอง'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuotationInfoTab(),
          _buildItemsTab(),
          _buildNegotiationHistoryTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildQuotationInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // สถานะใบขอยืนยัน
          _buildStatusCard(),
          const SizedBox(height: 16),

          // ข้อมูลทั่วไป
          _buildInfoCard(),
          const SizedBox(height: 16),

          // สรุปราคา
          _buildPriceSummaryCard(),
          const SizedBox(height: 16),

          // หมายเหตุ
          if (currentQuotation.notes != null ||
              currentQuotation.sellerNotes != null)
            _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'สถานะใบขอยืนยัน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(currentQuotation.status),
                if (currentQuotation.expiresAt != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'หมดอายุ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(currentQuotation.expiresAt!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _isExpiringSoon(currentQuotation.expiresAt!)
                              ? Colors.orange.shade600
                              : null,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'ข้อมูลทั่วไป',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('เลขที่ใบขอยืนยัน', currentQuotation.quotationNumber),
            _buildInfoRow(
              'วันที่สร้าง',
              DateFormat('dd/MM/yyyy HH:mm').format(currentQuotation.createdAt),
            ),
            _buildInfoRow(
              'อัปเดตล่าสุด',
              DateFormat('dd/MM/yyyy HH:mm').format(currentQuotation.updatedAt),
            ),
            if (currentQuotation.confirmedAt != null)
              _buildInfoRow(
                'วันที่ยืนยัน',
                DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(currentQuotation.confirmedAt!),
              ),
            if (currentQuotation.cancelledAt != null)
              _buildInfoRow(
                'วันที่ยกเลิก',
                DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(currentQuotation.cancelledAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'สรุปราคา',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              'จำนวนสินค้า',
              '${NumberFormatter.formatQuantity(currentQuotation.totalItems)} ชิ้น',
            ),
            _buildPriceRow(
              'ราคาเดิม',
              NumberFormatter.formatCurrency(
                currentQuotation.originalTotalAmount,
              ),
            ),
            const Divider(),
            _buildPriceRow(
              'ราคาที่ขอ',
              NumberFormatter.formatCurrency(currentQuotation.totalAmount),
              isTotal: true,
            ),
            if (currentQuotation.originalTotalAmount !=
                currentQuotation.totalAmount) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          currentQuotation.totalAmount <
                              currentQuotation.originalTotalAmount
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentQuotation.totalAmount <
                              currentQuotation.originalTotalAmount
                          ? 'ลดราคา ${NumberFormatter.formatCurrency(currentQuotation.originalTotalAmount - currentQuotation.totalAmount)}'
                          : 'เพิ่มราคา ${NumberFormatter.formatCurrency(currentQuotation.totalAmount - currentQuotation.originalTotalAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            currentQuotation.totalAmount <
                                currentQuotation.originalTotalAmount
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'หมายเหตุ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (currentQuotation.notes != null) ...[
              _buildNoteSection(
                'หมายเหตุจากลูกค้า',
                currentQuotation.notes!,
                Colors.blue.shade50,
              ),
              if (currentQuotation.sellerNotes != null)
                const SizedBox(height: 12),
            ],
            if (currentQuotation.sellerNotes != null)
              _buildNoteSection(
                'หมายเหตุจากผู้ขาย',
                currentQuotation.sellerNotes!,
                Colors.green.shade50,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentQuotation.items.length,
      itemBuilder: (context, index) {
        final item = currentQuotation.items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(QuotationItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ข้อมูลสินค้า
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.icCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.barcode != null)
                        Text(
                          'บาร์โค้ด: ${item.barcode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildItemStatusChip(item.status),
              ],
            ),
            const SizedBox(height: 12),

            // เปรียบเทียบราคาและจำนวน
            _buildComparisonTable(item),

            // หมายเหตุรายการ
            if (item.itemNotes != null && item.itemNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'หมายเหตุ:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.itemNotes!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(QuotationItem item) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _buildTableCell('', isHeader: true),
            _buildTableCell('จำนวน', isHeader: true),
            _buildTableCell('ราคา/หน่วย', isHeader: true),
            _buildTableCell('รวม', isHeader: true),
          ],
        ),
        // ราคาเดิม
        TableRow(
          children: [
            _buildTableCell('เดิม', isLabel: true),
            _buildTableCell(
              NumberFormatter.formatQuantity(item.originalQuantity),
            ),
            _buildTableCell(
              NumberFormatter.formatCurrency(item.originalUnitPrice),
            ),
            _buildTableCell(
              NumberFormatter.formatCurrency(item.originalTotalPrice),
            ),
          ],
        ),
        // ราคาที่ขอ
        TableRow(
          decoration: BoxDecoration(color: Colors.blue.shade50),
          children: [
            _buildTableCell('ที่ขอ', isLabel: true),
            _buildTableCell(
              NumberFormatter.formatQuantity(item.requestedQuantity),
            ),
            _buildTableCell(
              NumberFormatter.formatCurrency(item.requestedUnitPrice),
            ),
            _buildTableCell(
              NumberFormatter.formatCurrency(item.requestedTotalPrice),
            ),
          ],
        ),
        // ราคาที่เสนอ (ถ้ามี)
        if (item.offeredQuantity != null || item.offeredUnitPrice != null)
          TableRow(
            decoration: BoxDecoration(color: Colors.orange.shade50),
            children: [
              _buildTableCell('ที่เสนอ', isLabel: true),
              _buildTableCell(
                item.offeredQuantity != null
                    ? NumberFormatter.formatQuantity(item.offeredQuantity!)
                    : '-',
              ),
              _buildTableCell(
                item.offeredUnitPrice != null
                    ? NumberFormatter.formatCurrency(item.offeredUnitPrice!)
                    : '-',
              ),
              _buildTableCell(
                item.offeredTotalPrice != null
                    ? NumberFormatter.formatCurrency(item.offeredTotalPrice!)
                    : '-',
              ),
            ],
          ),
        // ราคาสุดท้าย (ถ้ามี)
        if (item.finalQuantity != null || item.finalUnitPrice != null)
          TableRow(
            decoration: BoxDecoration(color: Colors.green.shade50),
            children: [
              _buildTableCell('ตกลง', isLabel: true),
              _buildTableCell(
                item.finalQuantity != null
                    ? NumberFormatter.formatQuantity(item.finalQuantity!)
                    : '-',
              ),
              _buildTableCell(
                item.finalUnitPrice != null
                    ? NumberFormatter.formatCurrency(item.finalUnitPrice!)
                    : '-',
              ),
              _buildTableCell(
                item.finalTotalPrice != null
                    ? NumberFormatter.formatCurrency(item.finalTotalPrice!)
                    : '-',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildNegotiationHistoryTab() {
    if (currentQuotation.negotiations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติการต่อรอง',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อมีการต่อรองราคาจะแสดงประวัติที่นี่',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentQuotation.negotiations.length,
      itemBuilder: (context, index) {
        final negotiation = currentQuotation.negotiations[index];
        return _buildNegotiationCard(negotiation);
      },
    );
  }

  Widget _buildNegotiationCard(QuotationNegotiation negotiation) {
    final isFromCustomer = negotiation.fromRole == NegotiationRole.customer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCustomer) const Spacer(),
          Flexible(
            flex: 4,
            child: Card(
              color: isFromCustomer
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isFromCustomer
                              ? Colors.blue.shade600
                              : Colors.green.shade600,
                          child: Icon(
                            isFromCustomer ? Icons.person : Icons.store,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                negotiation.fromRole.displayName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(negotiation.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildNegotiationStatusChip(negotiation.status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ประเภทการต่อรอง
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ต่อรอง${negotiation.negotiationType.displayName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // ข้อมูลที่เสนอ
                    if (negotiation.proposedQuantity != null ||
                        negotiation.proposedUnitPrice != null ||
                        negotiation.proposedTotalPrice != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ข้อเสนอ:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (negotiation.proposedQuantity != null)
                              Text(
                                'จำนวน: ${NumberFormatter.formatQuantity(negotiation.proposedQuantity!)} ชิ้น',
                              ),
                            if (negotiation.proposedUnitPrice != null)
                              Text(
                                'ราคา/หน่วย: ${NumberFormatter.formatCurrency(negotiation.proposedUnitPrice!)}',
                              ),
                            if (negotiation.proposedTotalPrice != null)
                              Text(
                                'ราคารวม: ${NumberFormatter.formatCurrency(negotiation.proposedTotalPrice!)}',
                              ),
                          ],
                        ),
                      ),
                    ],

                    // ข้อความ
                    if (negotiation.message != null &&
                        negotiation.message!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(negotiation.message!),
                      ),
                    ],

                    // วันที่ตอบกลับ
                    if (negotiation.respondedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ตอบกลับเมื่อ: ${DateFormat('dd/MM/yyyy HH:mm').format(negotiation.respondedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isFromCustomer) const Spacer(),
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (currentQuotation.status != QuotationStatus.pending &&
        currentQuotation.status != QuotationStatus.negotiating) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelQuotation,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade600),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ยกเลิก'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _startNegotiation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ต่อรองราคา'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildStatusChip(QuotationStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case QuotationStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case QuotationStatus.confirmed:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case QuotationStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case QuotationStatus.negotiating:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case QuotationStatus.completed:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildItemStatusChip(QuotationItemStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(
          color: status == QuotationItemStatus.active
              ? Colors.green.shade700
              : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: status == QuotationItemStatus.active
          ? Colors.green.shade100
          : Colors.red.shade100,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildNegotiationStatusChip(NegotiationStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case NegotiationStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case NegotiationStatus.accepted:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case NegotiationStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case NegotiationStatus.countered:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? null : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(
    String title,
    String content,
    Color backgroundColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isLabel = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader || isLabel ? FontWeight.bold : FontWeight.normal,
          color: isLabel ? Colors.grey.shade700 : null,
        ),
        textAlign: isHeader || isLabel ? TextAlign.left : TextAlign.right,
      ),
    );
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

  // Action methods
  void _refreshQuotation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: เรียก API เพื่อโหลดข้อมูลใหม่
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รีเฟรชข้อมูลเรียบร้อย')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'negotiate':
        _startNegotiation();
        break;
      case 'cancel':
        _cancelQuotation();
        break;
    }
  }

  void _startNegotiation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NegotiationScreen(quotation: currentQuotation),
      ),
    ).then((result) {
      if (result == true) {
        // ถ้าส่งข้อเสนอสำเร็จ ให้รีเฟรชข้อมูล
        _refreshQuotation();
      }
    });
  }

  void _cancelQuotation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก'),
        content: const Text('คุณต้องการยกเลิกใบขอยืนยันราคานี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ไม่'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: เรียก API ยกเลิก
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ยกเลิกใบขอยืนยันราคาเรียบร้อย')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }
}
