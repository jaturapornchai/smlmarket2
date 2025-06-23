import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  final Logger logger;
  String? _currentCustomerId;
  String? _currentCartId;

  CartCubit({required this.repository, required this.logger})
    : super(CartInitial());

  Future<void> addToCart({
    required ProductModel product,
    required int quantity,
    int userId = 1, // ตัวอย่าง userId
  }) async {
    try {
      emit(CartLoading());

      // ตรวจสอบข้อมูลสินค้า
      if (product.id == null || product.id!.isEmpty) {
        emit(const CartError(message: 'ข้อมูลสินค้าไม่ถูกต้อง'));
        return;
      }

      final icCode = product.id!; // ใช้ product.id เป็น icCode โดยตรง

      // ตรวจสอบราคา
      final unitPrice =
          product.finalPrice ?? product.salePrice ?? product.price ?? 0.0;
      if (unitPrice <= 0) {
        emit(const CartError(message: 'ราคาสินค้าไม่ถูกต้อง'));
        return;
      }

      logger.d(
        'Adding to cart: IC Code: $icCode, Quantity: $quantity, Price: $unitPrice',
      );

      // เพิ่มสินค้าเข้าตระกร้า
      final cartItem = await repository.addProductToCart(
        customerId: userId,
        icCode: icCode,
        barcode: product.barcodes?.isNotEmpty == true
            ? product.barcodes!.split(',').first.trim()
            : null,
        unitCode: product.unitStandardCode,
        quantity: quantity,
        unitPrice: unitPrice,
      );

      emit(
        CartSuccess(
          cartItem: cartItem,
          message: 'เพิ่มสินค้าเข้าตระกร้าเรียบร้อย',
        ),
      );

      logger.d('Successfully added to cart: ${cartItem.toJson()}');
    } catch (e) {
      logger.e('Error adding to cart: $e');

      String errorMessage = 'เกิดข้อผิดพลาดในการเพิ่มสินค้า';
      if (e.toString().contains('สินค้าไม่เพียงพอ')) {
        errorMessage = 'สินค้าไม่เพียงพอ กรุณาลดจำนวน';
      } else if (e.toString().contains('No active cart found')) {
        errorMessage = 'ไม่สามารถสร้างตระกร้าได้';
      }

      emit(CartError(message: errorMessage));
    }
  }

  Future<void> checkStock({
    required String icCode,
    required int requestedQuantity,
  }) async {
    try {
      emit(CartLoading());

      final hasStock = await repository.checkStockAvailability(
        icCode: icCode,
        requestedQuantity: requestedQuantity,
      );

      // ดึงข้อมูลจำนวนที่มีอยู่
      final availableQty = await repository.getAvailableQuantity(
        icCode: icCode,
      );

      emit(
        StockCheckSuccess(
          hasStock: hasStock,
          availableQuantity: availableQty,
          icCode: icCode,
        ),
      );

      logger.d(
        'Stock check: IC Code $icCode, Available: $availableQty, Requested: $requestedQuantity, HasStock: $hasStock',
      );
    } catch (e) {
      logger.e('Error checking stock: $e');
      emit(const CartError(message: 'ไม่สามารถตรวจสอบสต็อกได้'));
    }
  }

  Future<void> loadCart({String? customerId}) async {
    try {
      emit(CartLoading());

      final customer = customerId ?? _currentCustomerId ?? '1';
      _currentCustomerId = customer;

      logger.i('🛒 [CUBIT] Loading cart for customer: $customer');

      // ดึงรายการสินค้าในตระกร้า
      final items = await repository.getCartItems(
        customerId: int.parse(customer),
      );

      // คำนวณยอดรวม
      double totalAmount = 0.0;
      int totalItems = 0;
      for (var item in items) {
        totalAmount += (item.unitPrice ?? 0.0) * item.quantity;
        totalItems += item.quantity;
      }

      // เก็บ cartId ของ item แรกเพื่อใช้ในการอัปเดต
      if (items.isNotEmpty) {
        _currentCartId = items.first.cartId.toString();
      }

      logger.i(
        '✅ [CUBIT] Cart loaded successfully: ${items.length} items, Total: \$${totalAmount.toStringAsFixed(2)}',
      );

      emit(
        CartLoaded(
          items: items,
          totalAmount: totalAmount,
          totalItems: totalItems,
          cartId: int.tryParse(_currentCartId ?? ''),
        ),
      );
    } catch (e) {
      logger.e('❌ [CUBIT] Error loading cart: $e');
      emit(const CartError(message: 'ไม่สามารถโหลดตระกร้าได้'));
    }
  }

  Future<void> updateCartItemQuantity({
    required String icCode,
    required int newQuantity,
  }) async {
    try {
      emit(CartLoading());

      await repository.updateCartItemQuantity(
        icCode: icCode,
        quantity: newQuantity,
        customerId: int.parse(_currentCustomerId ?? '1'),
      );

      logger.d('✅ [CUBIT] Updated quantity for $icCode: $newQuantity');

      // Reload cart to get updated data
      await loadCart(customerId: _currentCustomerId);
    } catch (e) {
      logger.e('❌ [CUBIT] Error updating quantity: $e');
      emit(const CartError(message: 'ไม่สามารถอัพเดทจำนวนสินค้าได้'));
    }
  }

  Future<void> removeFromCart({required String icCode}) async {
    try {
      emit(CartLoading());

      await repository.removeFromCart(
        icCode: icCode,
        customerId: int.parse(_currentCustomerId ?? '1'),
      );

      logger.d('✅ [CUBIT] Removed $icCode from cart');

      // Reload cart to get updated data
      await loadCart(customerId: _currentCustomerId);
    } catch (e) {
      logger.e('❌ [CUBIT] Error removing from cart: $e');
      emit(const CartError(message: 'ไม่สามารถลบสินค้าได้'));
    }
  }

  Future<void> clearCart({String? customerId}) async {
    try {
      emit(CartLoading());

      await repository.clearCart(
        customerId: int.parse(customerId ?? _currentCustomerId ?? '1'),
      );

      _currentCartId = null;

      emit(
        const CartLoaded(
          items: [],
          totalAmount: 0.0,
          totalItems: 0,
          cartId: null,
        ),
      );

      logger.d('✅ [CUBIT] Cart cleared successfully');
    } catch (e) {
      logger.e('❌ [CUBIT] Error clearing cart: $e');
      emit(const CartError(message: 'ไม่สามารถล้างตระกร้าได้'));
    }
  }

  Future<void> createOrder({String? customerId}) async {
    try {
      emit(CartLoading());

      final order = await repository.createOrder(
        customerId: int.parse(customerId ?? _currentCustomerId ?? '1'),
      );

      emit(
        CartSuccess(
          cartItem: null,
          message: 'สร้างคำสั่งซื้อเรียบร้อย: ${order.id}',
        ),
      );

      logger.d('✅ [CUBIT] Order created successfully: ${order.id}');
    } catch (e) {
      logger.e('❌ [CUBIT] Error creating order: $e');
      emit(const CartError(message: 'ไม่สามารถสร้างคำสั่งซื้อได้'));
    }
  }

  /// ตรวจสอบว่าสินค้ามีอยู่ในตะกร้าแล้วหรือไม่
  bool isProductInCart(String icCode) {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.items.any((item) => item.icCode == icCode);
    }
    return false;
  }

  /// ดึงจำนวนสินค้าในตะกร้า
  int getProductQuantityInCart(String icCode) {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        final item = currentState.items.firstWhere(
          (item) => item.icCode == icCode,
        );
        return item.quantity;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  void setCustomerId(String customerId) {
    _currentCustomerId = customerId;
    logger.d('🆔 [CUBIT] Customer ID set to: $customerId');
  }

  void resetState() {
    emit(CartInitial());
  }
}
