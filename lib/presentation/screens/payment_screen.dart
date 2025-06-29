import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import '../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'qr_code';
  bool isProcessing = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'qr_code',
      'name': 'QR Code',
      'icon': Icons.qr_code,
      'description': 'สแกน QR Code เพื่อชำระเงิน',
    },
    {
      'id': 'prompt_pay',
      'name': 'พร้อมเพย์',
      'icon': Icons.payment,
      'description': 'ชำระผ่าน PromptPay',
    },
    {
      'id': 'bank_transfer',
      'name': 'โอนเงิน',
      'icon': Icons.account_balance,
      'description': 'โอนเงินผ่านธนาคาร',
    },
    {
      'id': 'credit_card',
      'name': 'บัตรเครดิต',
      'icon': Icons.credit_card,
      'description': 'ชำระด้วยบัตรเครดิต/เดบิต',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'ชำระเงิน'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  _buildPaymentDetails(),
                ],
              ),
            ),
          ),
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปคำสั่งซื้อ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'คำสั่งซื้อ #${widget.order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPaymentStatusText(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมที่ต้องชำระ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '฿${widget.order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
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

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกวิธีการชำระเงิน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...paymentMethods.map((method) => _buildPaymentMethodTile(method)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        value: method['id'],
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
        title: Row(
          children: [
            Icon(
              method['icon'],
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              method['name'],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Text(
          method['description'],
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildPaymentDetails() {
    switch (selectedPaymentMethod) {
      case 'qr_code':
        return _buildQRCodePayment();
      case 'prompt_pay':
        return _buildPromptPayPayment();
      case 'bank_transfer':
        return _buildBankTransferPayment();
      case 'credit_card':
        return _buildCreditCardPayment();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQRCodePayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'สแกน QR Code เพื่อชำระเงิน',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'QR Code',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยอดเงิน: ฿${widget.order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptPayPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ชำระผ่าน PromptPay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('หมายเลข PromptPay', '0XX-XXX-XXXX'),
            _buildInfoRow('ชื่อบัญชี', 'บริษัท SML จำกัด'),
            _buildInfoRow(
              'ยอดเงินที่ต้องชำระ',
              '฿${widget.order.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'กรุณาโอนเงินตามยอดที่ระบุ และแนบหลักฐานการโอนเงิน',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'โอนเงินผ่านธนาคาร',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ธนาคาร', 'ธนาคารกรุงเทพ'),
            _buildInfoRow('เลขที่บัญชี', 'XXX-X-XXXXX-X'),
            _buildInfoRow('ชื่อบัญชี', 'บริษัท SML จำกัด'),
            _buildInfoRow(
              'ยอดเงินที่ต้องชำระ',
              '฿${widget.order.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'กรุณาโอนเงินภายใน 24 ชั่วโมง และแนบหลักฐานการโอนเงิน',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ชำระด้วยบัตรเครดิต/เดบิต',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'หมายเลขบัตร',
                hintText: 'XXXX XXXX XXXX XXXX',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'วันหมดอายุ',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: 'XXX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ถือบัตร',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดรวม',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _getPaymentButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
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

  String _getPaymentButtonText() {
    switch (selectedPaymentMethod) {
      case 'qr_code':
      case 'prompt_pay':
        return 'ยืนยันการชำระเงิน';
      case 'bank_transfer':
        return 'แนบหลักฐานการโอนเงิน';
      case 'credit_card':
        return 'ชำระเงินด้วยบัตร';
      default:
        return 'ชำระเงิน';
    }
  }

  void _processPayment() async {
    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessing = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('ชำระเงินสำเร็จ'),
            ],
          ),
          content: Text(
            'ชำระเงินสำหรับคำสั่งซื้อ #${widget.order.orderNumber} เรียบร้อยแล้ว',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to order detail
                Navigator.pop(context); // Go back to order list
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }
}
