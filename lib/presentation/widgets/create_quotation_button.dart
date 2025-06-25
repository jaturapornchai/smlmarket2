import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../utils/quotation_number_helper.dart';
import '../cubit/quotation_cubit.dart';
import '../screens/quotation_detail_screen.dart';

/// Widget ปุ่มสร้างใบขอยืนยันราคาและขอยืนยันจำนวน
class CreateQuotationButton extends StatefulWidget {
  final CartModel cart;
  final List<CartItemModel> cartItems;
  final VoidCallback? onSuccess;

  const CreateQuotationButton({
    super.key,
    required this.cart,
    required this.cartItems,
    this.onSuccess,
  });

  @override
  State<CreateQuotationButton> createState() => _CreateQuotationButtonState();
}

class _CreateQuotationButtonState extends State<CreateQuotationButton> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่าตะกร้ามีสินค้าหรือไม่
    if (widget.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _isCreating ? null : _createQuotation,
        icon: _isCreating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.request_quote),
        label: Text(
          _isCreating ? 'กำลังสร้าง...' : 'สร้างใบขอยืนยันราคาและจำนวน',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _createQuotation() async {
    setState(() {
      _isCreating = true;
    });

    try {
      // สร้างใบขอยืนยันราคาจากข้อมูลตะกร้า
      final quotation = await _buildQuotationFromCart();

      // ใช้ QuotationCubit สร้างใบขอยืนยันราคา
      final cubit = context.read<QuotationCubit>();
      await cubit.createQuotation(quotation, quotation.items);

      if (mounted) {
        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างใบขอยืนยันราคาและจำนวนสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // นำทางไปหน้ารายละเอียดใบขอยืนยันราคา
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuotationDetailScreen(quotation: quotation),
          ),
        );

        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<Quotation> _buildQuotationFromCart() async {
    // สร้างหมายเลขใบขอยืนยันราคา
    final quotationNumber = QuotationNumberHelper.generateQuotationNumber();

    // คำนวณยอดรวม
    final totalAmount = widget.cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.quantity * (item.unitPrice ?? 0.0)),
    );

    // สร้าง QuotationItems จาก CartItems
    final quotationItems = widget.cartItems.map((cartItem) {
      final unitPrice = cartItem.unitPrice ?? 0.0;
      return QuotationItem(
        id: 0, // จะได้จาก database
        quotationId: 0, // จะได้จาก database
        icCode: cartItem.icCode,
        barcode: cartItem.barcode,
        unitCode: cartItem.unitCode,
        originalQuantity: cartItem.quantity,
        originalUnitPrice: unitPrice,
        originalTotalPrice: cartItem.quantity * unitPrice,
        requestedQuantity: cartItem.quantity, // เริ่มต้นเหมือนกับต้นฉบับ
        requestedUnitPrice: unitPrice, // เริ่มต้นเหมือนกับต้นฉบับ
        requestedTotalPrice: cartItem.quantity * unitPrice,
        status: QuotationItemStatus.active,
        itemNotes: 'สร้างจากตะกร้าสินค้า',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    return Quotation(
      id: 0, // จะได้จาก database
      cartId: widget.cart.id!,
      customerId: widget.cart.customerId ?? 123,
      quotationNumber: quotationNumber,
      status: QuotationStatus.pending,
      totalAmount: totalAmount,
      totalItems: widget.cartItems.length.toDouble(),
      originalTotalAmount: totalAmount,
      notes: 'ใบขอยืนยันราคาและจำนวนที่สร้างจากตะกร้าสินค้า',
      items: quotationItems,
      negotiations: [], // เริ่มต้นไม่มีการเจรจา
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
