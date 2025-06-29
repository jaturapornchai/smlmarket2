import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../utils/number_formatter.dart';
import '../../utils/service_locator.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/order_cubit.dart';
import '../widgets/app_navigation_bar.dart';

/// หน้าจอสั่งซื้อทันที
/// แสดงรายละเอียดคำสั่งซื้อและยืนยันการสั่งซื้อ
class QuickOrderScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;
  final int customerId;

  const QuickOrderScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.customerId,
  });

  @override
  State<QuickOrderScreen> createState() => _QuickOrderScreenState();
}

class _QuickOrderScreenState extends State<QuickOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  bool _isUrgent = false;
  DateTime? _requestedDeliveryDate;

  @override
  void dispose() {
    _notesController.dispose();
    _deliveryAddressController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavigationBar(
        title: 'สั่งซื้อทันที',
        showBackButton: true,
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
                    // หัวข้อสั่งซื้อ
                    _buildOrderHeader(),
                    const SizedBox(height: 20),

                    // รายการสินค้า
                    _buildItemsList(),
                    const SizedBox(height: 20),

                    // ข้อมูลการจัดส่ง
                    _buildDeliverySection(),
                    const SizedBox(height: 20),

                    // ข้อมูลติดต่อ
                    _buildContactSection(),
                    const SizedBox(height: 20),

                    // หมายเหตุ
                    _buildNotesSection(),
                    const SizedBox(height: 20),

                    // ตัวเลือกเพิ่มเติม
                    _buildOptionsSection(),
                  ],
                ),
              ),
            ),

            // ปุ่มยืนยันการสั่งซื้อ
            _buildConfirmButton(),
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
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'รายละเอียดคำสั่งซื้อ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('จำนวนรายการ: ${widget.cartItems.length} รายการ'),
                Text(
                  'ยอดรวม: ${NumberFormatter.formatCurrency(widget.totalAmount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการสินค้า',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cartItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.icCode,
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
                    Expanded(
                      child: Text(
                        NumberFormatter.formatQuantity(item.quantity),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        NumberFormatter.formatCurrency(item.unitPrice ?? 0),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        NumberFormatter.formatCurrency(item.totalPrice ?? 0),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลการจัดส่ง',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _deliveryAddressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่จัดส่ง *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกที่อยู่จัดส่ง';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDeliveryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'วันที่ต้องการรับสินค้า',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _requestedDeliveryDate != null
                      ? '${_requestedDeliveryDate!.day}/${_requestedDeliveryDate!.month}/${_requestedDeliveryDate!.year}'
                      : 'เลือกวันที่',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลติดต่อ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactPersonController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ติดต่อ *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกชื่อผู้ติดต่อ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactPhoneController,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรติดต่อ *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกเบอร์โทรติดต่อ';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หมายเหตุ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุเพิ่มเติม',
                border: OutlineInputBorder(),
                hintText: 'ระบุข้อมูลเพิ่มเติมที่ต้องการ...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวเลือกเพิ่มเติม',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('คำสั่งซื้อด่วน'),
              subtitle: const Text('แจ้งให้ admin พิจารณาเป็นลำดับแรก'),
              value: _isUrgent,
              onChanged: (value) => setState(() => _isUrgent = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 24),
              SizedBox(width: 8),
              Text(
                'ยืนยันสั่งซื้อ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDeliveryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() => _requestedDeliveryDate = selectedDate);
    }
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // แสดง dialog ยืนยัน
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการสั่งซื้อ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('จำนวนรายการ: ${widget.cartItems.length} รายการ'),
            Text(
              'ยอดรวม: ${NumberFormatter.formatCurrency(widget.totalAmount)}',
            ),
            const SizedBox(height: 8),
            const Text(
              'คำสั่งซื้อจะถูกส่งไปยัง Admin เพื่อพิจารณาอนุมัติ',
              style: TextStyle(color: Colors.grey),
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
              _createOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  void _createOrder() async {
    try {
      // สร้างข้อมูล OrderModel
      final orderCubit = sl<OrderCubit>();

      final order = OrderModel(
        cartId: 0, // TODO: ใช้ cart ID จริงจากตะกร้า
        customerId: widget.customerId,
        orderNumber: '', // จะถูกสร้างใหม่ในฐานข้อมูล
        status: OrderStatus.pending,
        totalAmount: widget.totalAmount,
        shippingAddress: _deliveryAddressController.text,
        paymentMethod: 'B2B_ORDER', // ระบบ B2B ไม่มีการชำระเงิน
        paymentStatus: PaymentStatus.pending,
        notes: _buildOrderNotes(),
        orderedAt: DateTime.now(),
      );

      // แสดง loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // สร้างคำสั่งซื้อ
      await orderCubit.createOrder(order);

      // ปิด loading dialog
      if (mounted) Navigator.pop(context);

      // ล้างตะกร้า
      await context.read<CartCubit>().clearCart(
        customerId: widget.customerId.toString(),
      );

      // แสดงข้อความสำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('สั่งซื้อเรียบร้อย! รอ Admin อนุมัติ')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // กลับไปหน้าหลัก
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // ปิด loading dialog ถ้ายังเปิดอยู่
      if (mounted) Navigator.pop(context);

      // แสดงข้อผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _buildOrderNotes() {
    final notes = <String>[];

    if (_notesController.text.isNotEmpty) {
      notes.add('หมายเหตุ: ${_notesController.text}');
    }

    if (_contactPersonController.text.isNotEmpty) {
      notes.add('ผู้ติดต่อ: ${_contactPersonController.text}');
    }

    if (_contactPhoneController.text.isNotEmpty) {
      notes.add('เบอร์ติดต่อ: ${_contactPhoneController.text}');
    }

    if (_requestedDeliveryDate != null) {
      notes.add(
        'วันที่ต้องการรับสินค้า: ${_requestedDeliveryDate!.day}/${_requestedDeliveryDate!.month}/${_requestedDeliveryDate!.year}',
      );
    }

    if (_isUrgent) {
      notes.add('🚨 คำสั่งซื้อด่วน - แจ้งให้ admin พิจารณาเป็นลำดับแรก');
    }

    return notes.join('\n');
  }
}
