import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/quotation_model.dart';
import '../../data/models/quotation_enums.dart';
import '../../utils/number_formatter.dart';
import '../../utils/service_locator.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/quotation_cubit.dart';
import '../widgets/cart_item_widget_new.dart';
import '../widgets/cart_summary_widget.dart';
import '../widgets/empty_cart_widget.dart';
import 'quotation_list_screen.dart';

/// 🛒 หน้าจอตระกร้าสินค้า
/// แสดงรายการสินค้าในตระกร้า พร้อมฟังก์ชันจัดการ
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  void _loadCartData() {
    // โหลดข้อมูลตระกร้าสำหรับลูกค้าปัจจุบัน (ใช้ customer_id = 1 เป็นตัวอย่าง)
    context.read<CartCubit>().loadCart(customerId: '1');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: BlocConsumer<CartCubit, CartState>(
        listener: _handleStateListener,
        buildWhen: (previous, current) {
          // Rebuild เฉพาะเมื่อ state เปลี่ยนจริงๆ
          if (previous.runtimeType != current.runtimeType) return true;
          if (current is CartLoaded && previous is CartLoaded) {
            // ตรวจสอบว่าข้อมูลจริงๆ เปลี่ยนแปลงหรือไม่
            if (previous.items.length != current.items.length) return true;
            if (previous.totalAmount != current.totalAmount) return true;
            if (previous.totalItems != current.totalItems) return true;

            // ⭐ ตรวจสอบการเปลี่ยนแปลงของ stockQuantities
            if (previous.stockQuantities.length !=
                current.stockQuantities.length)
              return true;
            for (final icCode in current.stockQuantities.keys) {
              if (previous.stockQuantities[icCode] !=
                  current.stockQuantities[icCode]) {
                return true;
              }
            }

            // ตรวจสอบการเปลี่ยนแปลงใน items แต่ละตัว
            for (int i = 0; i < current.items.length; i++) {
              if (i >= previous.items.length) return true;
              final prevItem = previous.items[i];
              final currItem = current.items[i];
              if (prevItem.quantity != currItem.quantity ||
                  prevItem.totalPrice != currItem.totalPrice ||
                  prevItem.icCode != currItem.icCode) {
                return true;
              }
            }
            return false; // ไม่มีการเปลี่ยนแปลง
          }
          return true;
        },
        builder: _buildBody,
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        buildWhen: (previous, current) {
          // Rebuild bottom bar เฉพาะเมื่อจำเป็น
          if (current is CartLoaded && previous is CartLoaded) {
            return previous.items.length != current.items.length ||
                previous.totalAmount != current.totalAmount;
          }
          return previous.runtimeType != current.runtimeType;
        },
        builder: (context, state) {
          if (state is CartLoaded && state.items.isNotEmpty) {
            return _buildCheckoutButton(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// สร้าง AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'ตระกร้าสินค้า',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.blue.shade600,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoaded && state.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(),
                tooltip: 'ล้างตระกร้า',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// จัดการ State Listener
  void _handleStateListener(BuildContext context, CartState state) {
    if (state is CartError) {
      _showErrorSnackBar(state.message);
    } else if (state is CartSuccess) {
      _showSuccessSnackBar(state.message);
    }
  }

  /// สร้าง Body หลัก
  Widget _buildBody(BuildContext context, CartState state) {
    if (state is CartLoading) {
      return _buildLoadingWidget();
    } else if (state is CartLoaded) {
      if (state.items.isEmpty) {
        return const EmptyCartWidget();
      }
      return _buildCartContent(state);
    } else if (state is CartError) {
      return _buildErrorWidget(state.message);
    }

    return const EmptyCartWidget();
  }

  /// Widget สำหรับแสดงการโหลด
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'กำลังโหลดตระกร้าสินค้า...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Widget สำหรับแสดงข้อผิดพลาด
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCartData,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างเนื้อหาตระกร้า
  Widget _buildCartContent(CartLoaded state) {
    return Column(
      children: [
        // สรุปตระกร้า
        CartSummaryWidget(
          totalItems: state.totalItems,
          totalAmount: state.totalAmount,
        ),

        // รายการสินค้า
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final qtyAvailable = state.stockQuantities[item.icCode];
              return CartItemWidget(
                key: ValueKey('cart_item_${item.icCode}_${item.id}'),
                item: item,
                qtyAvailable: qtyAvailable,
                onQuantityChanged: (newQuantity) =>
                    _updateQuantity(item, newQuantity),
                onRemove: () => _removeItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  /// สร้างปุ่มเปิดใบขอยืนยันราคาและขอยืนยันจำนวน
  Widget _buildCheckoutButton(CartLoaded state) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // แสดงยอดรวม
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดรวมทั้งหมด:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                NumberFormatter.formatCurrency(state.totalAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ปุ่มเปิดใบขอยืนยันราคาและขอยืนยันจำนวน
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(state),
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
                  Icon(Icons.shopping_cart_checkout, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'ดำเนินการเปิดใบขอยืนยันราคาและขอยืนยันจำนวน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// อัพเดทจำนวนสินค้า
  void _updateQuantity(CartItemModel item, double newQuantity) {
    if (newQuantity <= 0.0) {
      _removeItem(item);
      return;
    }

    context.read<CartCubit>().updateCartItemQuantity(
      icCode: item.icCode,
      newQuantity: newQuantity,
    );

    _logger.d('Update quantity for ${item.icCode}: $newQuantity');
  }

  /// ลบสินค้าออกจากตระกร้า
  void _removeItem(CartItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ "${item.icCode}" ออกจากตระกร้าหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartCubit>().removeFromCart(icCode: item.icCode);
              _logger.d('Remove item: ${item.icCode}');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  /// แสดง Dialog ยืนยันการล้างตระกร้า
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างตระกร้า'),
        content: const Text('คุณต้องการล้างสินค้าในตระกร้าทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartCubit>().clearCart();
              _logger.d('Clear cart');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ล้างทั้งหมด'),
          ),
        ],
      ),
    );
  }

  /// ดำเนินการเปิดใบขอยืนยันราคาและขอยืนยันจำนวน
  void _proceedToCheckout(CartLoaded state) {
    // TODO: Navigate to quotation confirmation screen
    _logger.d(
      'Opening price and quantity confirmation request with ${state.items.length} items',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ดำเนินการเปิดใบขอยืนยันราคาและขอยืนยันจำนวน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('จำนวนสินค้า: ${state.totalItems} ชิ้น'),
            const SizedBox(height: 8),
            Text(
              'ยอดรวม: ${NumberFormatter.formatCurrency(state.totalAmount)}',
            ),
            const SizedBox(height: 16),
            const Text('ต้องการเปิดใบขอยืนยันราคาและขอยืนยันจำนวนหรือไม่?'),
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
              _navigateToQuotationCreation(state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('เปิดใบขอยืนยัน'),
          ),
        ],
      ),
    );
  }

  /// นำทางไปสร้างใบขอยืนยันราคา
  void _navigateToQuotationCreation(CartLoaded state) async {
    try {
      // สร้างใบขอยืนยันราคาจากข้อมูลตะกร้า
      _logger.d('Creating quotation with ${state.items.length} items');

      // ตรวจสอบข้อมูลก่อนสร้าง
      if (state.items.isEmpty) {
        _showErrorSnackBar('ไม่มีสินค้าในตะกร้า');
        return;
      }

      if (state.cartId == null) {
        _showErrorSnackBar('ไม่พบข้อมูลตระกร้า');
        return;
      }

      // แสดง loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // สร้างใบยืนยันราคา
      final quotationCubit = sl<QuotationCubit>();

      // สร้างข้อมูลใบยืนยันราคา
      final quotationItems = state.items
          .map(
            (item) => QuotationItem(
              id: 0, // จะถูกสร้างใหม่ในฐานข้อมูล
              quotationId: 0, // จะถูกสร้างใหม่ในฐานข้อมูล
              icCode: item.icCode,
              barcode: item.barcode,
              unitCode: item.unitCode,
              originalQuantity: item.quantity,
              originalUnitPrice: item.unitPrice ?? 0.0,
              originalTotalPrice: item.totalPrice ?? 0.0,
              requestedQuantity: item.quantity,
              requestedUnitPrice: item.unitPrice ?? 0.0,
              requestedTotalPrice: item.totalPrice ?? 0.0,
              status: QuotationItemStatus.active,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();

      final quotation = Quotation(
        id: 0, // จะถูกสร้างใหม่ในฐานข้อมูล
        cartId: state.cartId!,
        customerId: 1,
        quotationNumber: '', // จะถูกสร้างใหม่
        status: QuotationStatus.pending,
        totalAmount: state.totalAmount,
        totalItems: state.totalItems,
        originalTotalAmount: state.totalAmount,
        notes: 'สร้างจากตะกร้าสินค้า',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // สร้างใบยืนยันราคา
      await quotationCubit.createQuotation(quotation, quotationItems);

      // ล้างตะกร้าหลังจากสร้างใบยืนยันราคาสำเร็จ
      await context.read<CartCubit>().clearCart(customerId: '1');

      // ปิด loading dialog
      if (mounted) Navigator.pop(context);

      // นำทางไปหน้ารายการใบยืนยันราคา
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: quotationCubit,
              child: const QuotationListScreen(customerId: 1),
            ),
          ),
        );
      }

      // แสดงข้อความสำเร็จ
      _showSuccessSnackBar('สร้างใบยืนยันราคาสำเร็จ ตะกร้าได้ถูกล้างแล้ว');
    } catch (e) {
      // ปิด loading dialog ถ้ายังเปิดอยู่
      if (mounted) Navigator.pop(context);

      _logger.e('Error creating quotation: $e');
      _showErrorSnackBar(
        'เกิดข้อผิดพลาดในการสร้างใบยืนยันราคา: ${e.toString()}',
      );
    }
  }

  /// แสดง Success SnackBar
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
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
  }

  /// แสดง Error SnackBar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
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
