import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../services/postgresql_service.dart';
import 'cart_remote_data_source.dart';

class CartPostgreSQLDataSource implements CartDataSource {
  final Logger logger;

  CartPostgreSQLDataSource({required this.logger});

  @override
  Future<CartModel> getActiveCart({required int customerId}) async {
    try {
      final results = await PostgreSQLService.getActiveCart(
        customerId.toString(),
      );

      if (results.isNotEmpty) {
        final cartData = results.first;
        return CartModel.fromJson(cartData);
      } else {
        throw Exception('No active cart found');
      }
    } catch (e) {
      logger.e('Error getting active cart: $e');
      throw Exception('Failed to get active cart: $e');
    }
  }

  @override
  Future<CartModel> createCart({required int customerId}) async {
    try {
      final createResult = await PostgreSQLService.createCart(
        customerId: customerId,
        customerCode: 'CUST$customerId',
        customerName: 'Customer $customerId',
      );

      if (createResult['success'] == true) {
        // Cart สร้างสำเร็จแล้ว ส่งกลับ CartModel
        return CartModel(
          id: null, // จะได้จาก RETURNING แต่อาจจะไม่มี
          customerId: customerId,
          status: CartStatus.active,
          totalAmount: 0.0,
          totalItems: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to create cart');
    } catch (e) {
      logger.e('Error creating cart: $e');
      throw Exception('Failed to create cart: $e');
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required int cartId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  }) async {
    try {
      // ตรวจสอบยอดพร้อมสั่งก่อนเพิ่มสินค้า
      final availableQty = await checkAvailableQuantity(icCode: icCode);

      if (quantity > availableQty) {
        throw Exception(
          'ไม่สามารถสั่งได้เกินยอดพร้อมสั่ง: ${availableQty.toStringAsFixed(0)} หน่วย',
        );
      }

      // เพิ่มสินค้าเข้าตระกร้า
      final result = await PostgreSQLService.addToCart(
        cartId: cartId,
        icCode: icCode,
        barcode: barcode,
        unitCode: unitCode,
        quantity: quantity,
        unitPrice: unitPrice,
      );

      if (result['success'] == true) {
        // อัปเดตยอดรวมในตระกร้า
        await PostgreSQLService.updateCartTotals(cartId);

        // Log ยอดพร้อมสั่งใหม่หลังจากเพิ่มในตะกร้า
        final newAvailableQty = await checkAvailableQuantity(icCode: icCode);
        logger.d('📊 Updated available quantity for $icCode: $newAvailableQty');

        // ส่งกลับ CartItemModel
        final totalPrice = quantity * unitPrice;
        return CartItemModel(
          id: null,
          cartId: cartId,
          icCode: icCode,
          barcode: barcode,
          unitCode: unitCode,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      logger.e('⛔ Error adding to cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error adding to cart: $e');
      }
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<double> checkAvailableQuantity({required String icCode}) async {
    try {
      return await PostgreSQLService.checkAvailableQuantity(icCode);
    } catch (e) {
      logger.e('Error checking available quantity: $e');
      return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getStockQuantities({
    required List<String> icCodes,
  }) async {
    try {
      final Map<String, double> stockMap = {};

      // ดึงข้อมูลสต็อกแต่ละรายการ
      for (final icCode in icCodes) {
        try {
          final qty = await checkAvailableQuantity(icCode: icCode);
          stockMap[icCode] = qty;
        } catch (e) {
          logger.w('Failed to get stock for $icCode: $e');
          stockMap[icCode] = 0.0;
        }
      }

      return stockMap;
    } catch (e) {
      logger.e('Error getting stock quantities: $e');
      // ในกรณี error ให้ return ข้อมูลเป็น 0 ทั้งหมด
      final Map<String, double> fallbackMap = {};
      for (final icCode in icCodes) {
        fallbackMap[icCode] = 0.0;
      }
      return fallbackMap;
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems({required int customerId}) async {
    try {
      final results = await PostgreSQLService.getCartItems(customerId);
      return results.map((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Error getting cart items: $e');
      return [];
    }
  }

  @override
  Future<void> updateCartItemQuantity({
    required int customerId,
    required String icCode,
    required double quantity,
  }) async {
    try {
      final command =
          '''
        UPDATE cart_items SET 
          quantity = $quantity,
          total_price = quantity * unit_price,
          updated_at = CURRENT_TIMESTAMP
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      ''';

      await PostgreSQLService.executeCommand(command);
    } catch (e) {
      logger.e('Error updating cart item quantity: $e');
      throw Exception('Failed to update cart item quantity: $e');
    }
  }

  @override
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  }) async {
    try {
      final command =
          '''
        DELETE FROM cart_items
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      ''';

      await PostgreSQLService.executeCommand(command);
    } catch (e) {
      logger.e('Error removing from cart: $e');
      throw Exception('Failed to remove from cart: $e');
    }
  }

  @override
  Future<void> clearCart({required int customerId}) async {
    try {
      final command =
          '''
        DELETE FROM cart_items
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        )
      ''';

      await PostgreSQLService.executeCommand(command);
    } catch (e) {
      logger.e('Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<OrderModel> createOrder({required int customerId}) async {
    // TODO: Implement order creation using PostgreSQL
    throw UnimplementedError(
      'Order creation not yet implemented for PostgreSQL',
    );
  }

  @override
  Future<double> getAvailableQuantityRealtime({
    required String icCode,
    required int currentCustomerId,
  }) async {
    return await checkAvailableQuantity(icCode: icCode);
  }

  @override
  Future<Map<String, double>> getAvailableQuantitiesForCart({
    required int customerId,
  }) async {
    try {
      final cartItems = await getCartItems(customerId: customerId);
      final icCodes = cartItems.map((item) => item.icCode).toSet().toList();
      return await getStockQuantities(icCodes: icCodes);
    } catch (e) {
      logger.e('Error getting available quantities for cart: $e');
      return {};
    }
  }
}
