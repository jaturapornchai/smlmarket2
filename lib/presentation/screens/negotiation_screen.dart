import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../utils/number_formatter.dart';
import '../cubit/quotation_cubit.dart';

/// หน้าจอการต่อรองราคาและขอยืนยันจำนวน
class NegotiationScreen extends StatefulWidget {
  final Quotation quotation;
  final QuotationItem? specificItem; // ถ้าต่อรองรายการเดียว

  const NegotiationScreen({
    super.key,
    required this.quotation,
    this.specificItem,
  });

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  NegotiationType _negotiationType = NegotiationType.price;
  List<ItemNegotiation> _itemNegotiations = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeNegotiations();
  }

  void _initializeNegotiations() {
    if (widget.specificItem != null) {
      // ต่อรองรายการเดียว
      _itemNegotiations = [
        ItemNegotiation.fromQuotationItem(widget.specificItem!),
      ];
    } else {
      // ต่อรองทั้งใบ
      _itemNegotiations = widget.quotation.items
          .where((item) => item.status == QuotationItemStatus.active)
          .map((item) => ItemNegotiation.fromQuotationItem(item))
          .toList();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    for (final negotiation in _itemNegotiations) {
      negotiation.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.specificItem != null
              ? 'ต่อรองรายการ ${widget.specificItem!.icCode}'
              : 'ต่อรองราคา ${widget.quotation.quotationNumber}',
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ประเภทการต่อรอง
                    _buildNegotiationTypeSelector(),
                    const SizedBox(height: 24),

                    // รายการสินค้าที่ต่อรอง
                    _buildItemsList(),
                    const SizedBox(height: 24),

                    // ข้อความแนบ
                    _buildMessageSection(),
                    const SizedBox(height: 24),

                    // สรุปการต่อรอง
                    _buildSummarySection(),
                  ],
                ),
              ),
            ),

            // ปุ่มดำเนินการ
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNegotiationTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'ประเภทการต่อรอง',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...NegotiationType.values
                .where((type) => type != NegotiationType.note)
                .map(
                  (type) => RadioListTile<NegotiationType>(
                    value: type,
                    groupValue: _negotiationType,
                    onChanged: (value) {
                      setState(() {
                        _negotiationType = value!;
                        _updateNegotiationItems();
                      });
                    },
                    title: Text(type.displayName),
                    subtitle: Text(_getNegotiationTypeDescription(type)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text(
              'รายการสินค้า',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._itemNegotiations.map(
          (negotiation) => _buildItemNegotiationCard(negotiation),
        ),
      ],
    );
  }

  Widget _buildItemNegotiationCard(ItemNegotiation negotiation) {
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
                  child: Text(
                    negotiation.icCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: negotiation.isActive,
                  onChanged: (value) {
                    setState(() {
                      negotiation.isActive = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (negotiation.isActive) ...[
              // แสดงข้อมูลปัจจุบัน
              _buildCurrentDataSection(negotiation),
              const SizedBox(height: 16),

              // ฟอร์มต่อรอง
              _buildNegotiationForm(negotiation),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ไม่รวมในการต่อรอง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDataSection(ItemNegotiation negotiation) {
    return Container(
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
            'ข้อมูลปัจจุบัน',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'จำนวน: ${NumberFormatter.formatQuantity(negotiation.currentQuantity)} ชิ้น',
                ),
              ),
              Expanded(
                child: Text(
                  'ราคา/หน่วย: ${NumberFormatter.formatCurrency(negotiation.currentUnitPrice)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ราคารวม: ${NumberFormatter.formatCurrency(negotiation.currentTotalPrice)}',
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationForm(ItemNegotiation negotiation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ข้อเสนอใหม่',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 12),

        if (_negotiationType == NegotiationType.quantity ||
            _negotiationType == NegotiationType.both) ...[
          // จำนวน
          TextFormField(
            controller: negotiation.quantityController,
            decoration: const InputDecoration(
              labelText: 'จำนวนที่เสนอ',
              suffixText: 'ชิ้น',
              border: OutlineInputBorder(),
              helperText: 'ใส่จำนวนที่ต้องการ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณาใส่จำนวน';
              }
              final quantity = double.tryParse(value);
              if (quantity == null || quantity <= 0) {
                return 'จำนวนต้องมากกว่า 0';
              }
              return null;
            },
            onChanged: (value) {
              negotiation.updateCalculations();
            },
          ),
          const SizedBox(height: 16),
        ],

        if (_negotiationType == NegotiationType.price ||
            _negotiationType == NegotiationType.both) ...[
          // ราคาต่อหน่วย
          TextFormField(
            controller: negotiation.unitPriceController,
            decoration: const InputDecoration(
              labelText: 'ราคาต่อหน่วยที่เสนอ',
              suffixText: 'บาท',
              border: OutlineInputBorder(),
              helperText: 'ใส่ราคาต่อหน่วยที่ต้องการ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณาใส่ราคา';
              }
              final price = double.tryParse(value);
              if (price == null || price < 0) {
                return 'ราคาต้องไม่ติดลบ';
              }
              return null;
            },
            onChanged: (value) {
              negotiation.updateCalculations();
            },
          ),
          const SizedBox(height: 16),
        ],

        // แสดงราคารวมที่คำนวณได้
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ราคารวมที่เสนอ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.formatCurrency(negotiation.proposedTotalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              if (negotiation.proposedTotalPrice !=
                  negotiation.currentTotalPrice) ...[
                const SizedBox(height: 4),
                Text(
                  negotiation.proposedTotalPrice < negotiation.currentTotalPrice
                      ? 'ลดราคา ${NumberFormatter.formatCurrency(negotiation.currentTotalPrice - negotiation.proposedTotalPrice)}'
                      : 'เพิ่มราคา ${NumberFormatter.formatCurrency(negotiation.proposedTotalPrice - negotiation.currentTotalPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        negotiation.proposedTotalPrice <
                            negotiation.currentTotalPrice
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'ข้อความแนบ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'ใส่ข้อความหรือเงื่อนไขเพิ่มเติม (ไม่บังคับ)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final activeNegotiations = _itemNegotiations
        .where((n) => n.isActive)
        .toList();
    if (activeNegotiations.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCurrentPrice = activeNegotiations
        .map((n) => n.currentTotalPrice)
        .reduce((a, b) => a + b);

    final totalProposedPrice = activeNegotiations
        .map((n) => n.proposedTotalPrice)
        .reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'สรุปการต่อรอง',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSummaryRow(
              'จำนวนรายการ',
              '${activeNegotiations.length} รายการ',
            ),
            _buildSummaryRow(
              'ราคาปัจจุบัน',
              NumberFormatter.formatCurrency(totalCurrentPrice),
            ),
            const Divider(),
            _buildSummaryRow(
              'ราคาที่เสนอ',
              NumberFormatter.formatCurrency(totalProposedPrice),
              isHighlight: true,
            ),

            if (totalProposedPrice != totalCurrentPrice) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: totalProposedPrice < totalCurrentPrice
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: totalProposedPrice < totalCurrentPrice
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      totalProposedPrice < totalCurrentPrice
                          ? Icons.trending_down
                          : Icons.trending_up,
                      color: totalProposedPrice < totalCurrentPrice
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        totalProposedPrice < totalCurrentPrice
                            ? 'ลดราคา ${NumberFormatter.formatCurrency(totalCurrentPrice - totalProposedPrice)}'
                            : 'เพิ่มราคา ${NumberFormatter.formatCurrency(totalProposedPrice - totalCurrentPrice)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: totalProposedPrice < totalCurrentPrice
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ยกเลิก'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitNegotiation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('ส่งข้อเสนอ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? null : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.blue.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getNegotiationTypeDescription(NegotiationType type) {
    switch (type) {
      case NegotiationType.price:
        return 'ต่อรองราคาเท่านั้น (จำนวนคงเดิม)';
      case NegotiationType.quantity:
        return 'ต่อรองจำนวนเท่านั้น (ราคาคงเดิม)';
      case NegotiationType.both:
        return 'ต่อรองทั้งราคาและจำนวน';
      case NegotiationType.note:
        return 'ข้อความเท่านั้น';
    }
  }

  void _updateNegotiationItems() {
    for (final negotiation in _itemNegotiations) {
      negotiation.updateForNegotiationType(_negotiationType);
    }
  }

  void _submitNegotiation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final activeNegotiations = _itemNegotiations
        .where((n) => n.isActive)
        .toList();
    if (activeNegotiations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกรายการที่ต้องการต่อรองอย่างน้อย 1 รายการ'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // สร้างข้อมูลการต่อรอง
      for (final negotiation in activeNegotiations) {
        final negotiationData = QuotationNegotiation(
          id: 0, // จะถูกสร้างใหม่ในฐานข้อมูล
          quotationId: widget.quotation.id,
          quotationItemId: null, // สำหรับการต่อรองทั้งใบ
          negotiationType: _negotiationType,
          fromRole: NegotiationRole.customer,
          toRole: NegotiationRole.seller,
          proposedQuantity:
              _negotiationType == NegotiationType.quantity ||
                  _negotiationType == NegotiationType.both
              ? negotiation.proposedQuantity
              : null,
          proposedUnitPrice:
              _negotiationType == NegotiationType.price ||
                  _negotiationType == NegotiationType.both
              ? negotiation.proposedUnitPrice
              : null,
          proposedTotalPrice:
              _negotiationType == NegotiationType.price ||
                  _negotiationType == NegotiationType.both ||
                  _negotiationType == NegotiationType.quantity
              ? negotiation.proposedTotalPrice
              : null,
          message: _messageController.text.trim().isNotEmpty
              ? _messageController.text.trim()
              : null,
          status: NegotiationStatus.pending,
          createdAt: DateTime.now(),
        );

        // เรียก API เพื่อส่งข้อเสนอผ่าน QuotationCubit
        final quotationCubit = context.read<QuotationCubit>();
        await quotationCubit.createNegotiation(negotiationData);
      }

      if (mounted) {
        Navigator.pop(context, true); // ส่งค่า true เพื่อบอกว่าส่งข้อเสนอสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งข้อเสนอเรียบร้อย รอการตอบกลับจากผู้ขาย'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

/// คลาสสำหรับเก็บข้อมูลการต่อรองของแต่ละรายการ
class ItemNegotiation {
  final String icCode;
  final double currentQuantity;
  final double currentUnitPrice;
  final double currentTotalPrice;

  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  bool isActive;

  ItemNegotiation({
    required this.icCode,
    required this.currentQuantity,
    required this.currentUnitPrice,
    required this.currentTotalPrice,
    this.isActive = true,
  }) : quantityController = TextEditingController(
         text: currentQuantity.toString(),
       ),
       unitPriceController = TextEditingController(
         text: currentUnitPrice.toString(),
       );

  factory ItemNegotiation.fromQuotationItem(QuotationItem item) {
    return ItemNegotiation(
      icCode: item.icCode,
      currentQuantity: item.requestedQuantity,
      currentUnitPrice: item.requestedUnitPrice,
      currentTotalPrice: item.requestedTotalPrice,
    );
  }

  double get proposedQuantity {
    return double.tryParse(quantityController.text) ?? currentQuantity;
  }

  double get proposedUnitPrice {
    return double.tryParse(unitPriceController.text) ?? currentUnitPrice;
  }

  double get proposedTotalPrice {
    return proposedQuantity * proposedUnitPrice;
  }

  void updateCalculations() {
    // จะถูกเรียกเมื่อมีการเปลี่ยนแปลงค่า เพื่อให้ UI อัปเดต
  }

  void updateForNegotiationType(NegotiationType type) {
    switch (type) {
      case NegotiationType.price:
        quantityController.text = currentQuantity.toString();
        break;
      case NegotiationType.quantity:
        unitPriceController.text = currentUnitPrice.toString();
        break;
      case NegotiationType.both:
        // ไม่ต้องทำอะไร ให้ผู้ใช้แก้ไขได้ทั้งคู่
        break;
      case NegotiationType.note:
        quantityController.text = currentQuantity.toString();
        unitPriceController.text = currentUnitPrice.toString();
        break;
    }
  }

  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
  }
}
