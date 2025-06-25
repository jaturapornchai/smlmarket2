import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../utils/number_formatter.dart';
import '../../utils/thai_date_formatter.dart';
import '../cubit/quotation_cubit.dart';
import '../cubit/quotation_state.dart';
import 'quotation_detail_screen.dart';

/// หน้าจอรายการใบขอยืนยันราคาและขอยืนยันจำนวน
class QuotationListScreen extends StatefulWidget {
  final int customerId;

  const QuotationListScreen({
    super.key,
    this.customerId = 123, // TODO: ใช้ customer ID จริงจาก session
  });

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  QuotationStatus? filterStatus;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเมื่อเปิดหน้าจอ
    context.read<QuotationCubit>().loadQuotations(widget.customerId);
  }

  Future<void> _loadQuotations() async {
    context.read<QuotationCubit>().loadQuotations(widget.customerId);
  }

  List<Quotation> _filterQuotations(List<Quotation> quotations) {
    if (filterStatus == null) return quotations;
    return quotations.where((q) => q.status == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ใบขอยืนยันราคาและขอยืนยันจำนวน'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // นำทางกลับไปหน้าแรก (ProductSearchScreen) แทนการกลับแบบปกติ
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          },
          tooltip: 'กลับหน้าแรก',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuotations,
          ),
        ],
      ),
      body: BlocConsumer<QuotationCubit, QuotationState>(
        listener: (context, state) {
          if (state is QuotationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (filterStatus != null) _buildFilterChip(),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(QuotationState state) {
    if (state is QuotationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuotationLoaded) {
      final filteredQuotations = _filterQuotations(state.quotations);

      if (filteredQuotations.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _loadQuotations,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredQuotations.length,
          itemBuilder: (context, index) {
            final quotation = filteredQuotations[index];
            return _buildQuotationCard(quotation);
          },
        ),
      );
    }

    return _buildEmptyState();
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Chip(
            label: Text('กรอง: ${filterStatus!.displayName}'),
            onDeleted: () {
              setState(() {
                filterStatus = null;
              });
            },
            backgroundColor: Colors.blue.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่มีใบขอยืนยันราคา',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เมื่อคุณสร้างใบขอยืนยันราคาจากตะกร้า\nจะแสดงรายการที่นี่',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard(Quotation quotation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToQuotationDetail(quotation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quotation.quotationNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(quotation.status),
                ],
              ),
              const SizedBox(height: 12),

              // สรุปข้อมูล
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.shopping_cart,
                      'จำนวนสินค้า',
                      '${NumberFormatter.formatQuantity(quotation.totalItems)} ชิ้น',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'ยอดรวม',
                      NumberFormatter.formatCurrency(quotation.totalAmount),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ข้อมูลเพิ่มเติม
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'วันที่สร้าง',
                      ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(
                        quotation.createdAt,
                      ),
                    ),
                  ),
                  if (quotation.expiresAt != null)
                    Expanded(
                      child: _buildInfoItem(
                        Icons.schedule,
                        'หมดอายุ',
                        ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(
                          quotation.expiresAt!,
                        ),
                        color: _isExpiringSoon(quotation.expiresAt!)
                            ? Colors.orange.shade600
                            : null,
                      ),
                    ),
                ],
              ),

              // แสดงจำนวนการต่อรอง (ถ้ามี)
              if (quotation.negotiations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'มีการต่อรอง ${quotation.negotiations.length} ครั้ง',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // หมายเหตุ (ถ้ามี)
              if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
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
                      Text(
                        quotation.notes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรองตามสถานะ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('แสดงทั้งหมด'),
              leading: Radio<QuotationStatus?>(
                value: null,
                groupValue: filterStatus,
                onChanged: (value) {
                  setState(() {
                    filterStatus = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...QuotationStatus.values.map(
              (status) => ListTile(
                title: Text(status.displayName),
                leading: Radio<QuotationStatus?>(
                  value: status,
                  groupValue: filterStatus,
                  onChanged: (value) {
                    setState(() {
                      filterStatus = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuotationDetail(Quotation quotation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationDetailScreen(quotation: quotation),
      ),
    );
  }
}
