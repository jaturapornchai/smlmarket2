import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

abstract class CartDataSource {
  Future<CartModel> getActiveCart({required int customerId});
  Future<CartModel> createCart({required int customerId});
  Future<CartItemModel> addToCart({
    required int cartId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  });
  Future<double> checkAvailableQuantity({required String icCode});
  Future<Map<String, double>> getStockQuantities({
    required List<String> icCodes,
  });
  Future<List<CartItemModel>> getCartItems({required int customerId});
  Future<void> updateCartItemQuantity({
    required int customerId,
    required String icCode,
    required double quantity,
  });
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  });
  Future<void> clearCart({required int customerId});
  Future<OrderModel> createOrder({required int customerId});
  Future<double> getAvailableQuantityRealtime({
    required String icCode,
    required int currentCustomerId,
  });
  Future<Map<String, double>> getAvailableQuantitiesForCart({
    required int customerId,
  });
}

class CartRemoteDataSource implements CartDataSource {
  final Dio dio;
  final Logger logger;

  CartRemoteDataSource({required this.dio, required this.logger});

  @override
  Future<CartModel> getActiveCart({required int customerId}) async {
    try {
      final query =
          """
        SELECT id, customer_id, status, total_amount, total_items, created_at, updated_at 
        FROM carts 
        WHERE customer_id = $customerId AND status = 'active'
        ORDER BY created_at DESC
        LIMIT 1
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Get active cart response: ${response.data}');
      }

      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        return CartModel.fromJson(response.data['data'][0]);
      } else {
        // ถ้าไม่มีตระกร้า สร้างใหม่
        return await createCart(customerId: customerId);
      }
    } catch (e) {
      logger.e('⛔ Error getting active cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error getting active cart: $e');
      }
      // ถ้า error ลองสร้างตระกร้าใหม่
      return await createCart(customerId: customerId);
    }
  }

  @override
  Future<CartModel> createCart({required int customerId}) async {
    try {
      final query =
          """
        INSERT INTO carts (customer_id, status, total_amount, total_items) 
        VALUES ($customerId, 'active', 0.00, 0)
        RETURNING id, customer_id, status, total_amount, total_items, created_at, updated_at
      """;

      final response = await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Create cart response: ${response.data}');
      }
      if (response.data['success'] == true) {
        // ข้อมูลที่ return มาจาก pgcommand จะอยู่ใน result
        // แต่เนื่องจากไม่มี RETURNING data ให้สร้าง cart object ชั่วคราว
        // แล้วไปดึงข้อมูลจริงจากฐานข้อมูลอีกครั้ง
        return await getActiveCart(customerId: customerId);
      } else {
        throw Exception('Failed to create cart');
      }
    } catch (e) {
      logger.e('⛔ Error creating cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error creating cart: $e');
      }
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
      // ลองทำ Refresh ยอดคงเหลือจากฐานข้อมูลหลักก่อน (optional fallback)
      await refreshInventoryBalance(icCode: icCode).catchError((e) {
        // ไม่ต้องทำอะไร - ใช้ real-time calculation แทน
        logger.d(
          '🔄 Using real-time calculation instead of refresh for $icCode',
        );
        return false;
      });

      // ตรวจสอบยอดพร้อมสั่งก่อนเพิ่มสินค้า
      final availableQty = await checkAvailableQuantity(icCode: icCode);

      if (quantity > availableQty) {
        throw Exception(
          'ไม่สามารถสั่งได้เกินยอดพร้อมสั่ง: ${availableQty.toStringAsFixed(0)} หน่วย',
        );
      }

      final totalPrice = quantity * unitPrice;

      // แทรกรายการใหม่หรืออัปเดตถ้ามีอยู่แล้ว
      final query =
          """
        INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) 
        VALUES ($cartId, '$icCode', ${barcode != null ? "'$barcode'" : 'NULL'}, ${unitCode != null ? "'$unitCode'" : 'NULL'}, $quantity, $unitPrice, $totalPrice)
        ON CONFLICT (cart_id, ic_code, unit_code, unit_price) 
        DO UPDATE SET 
          quantity = cart_items.quantity + $quantity,
          total_price = (cart_items.quantity + $quantity) * cart_items.unit_price,
          updated_at = CURRENT_TIMESTAMP
        RETURNING id, cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price, created_at, updated_at
      """;

      final response = await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Add to cart response: ${response.data}');
      }
      if (response.data['success'] == true) {
        // อัปเดตยอดรวมในตระกร้า
        await _updateCartTotals(cartId);

        // Log ยอดพร้อมสั่งใหม่หลังจากเพิ่มในตะกร้า
        final newAvailableQty = await checkAvailableQuantity(icCode: icCode);
        logger.d('📊 Updated available quantity for $icCode: $newAvailableQty');

        // ส่งกลับ CartItemModel ที่สร้างจากข้อมูลที่เรามี
        return CartItemModel(
          id: null, // จะได้จาก database ภายหลัง
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
      final query =
          """
        SELECT 
          COALESCE(
            (SELECT SUM(balance_qty) FROM ic_balance WHERE ic_code = '$icCode'), 0
          ) - COALESCE(
            (SELECT SUM(quantity) 
             FROM cart_items ci 
             INNER JOIN carts c ON ci.cart_id = c.id 
             WHERE ci.ic_code = '$icCode' AND c.status = 'active'), 0
          ) as available_qty
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d(
          '📦 [DATA_SOURCE] Check available quantity response: ${response.data}',
        );
      }
      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        // แปลง available_qty อย่างปลอดภัย ไม่ว่าจะเป็น String หรือ number
        final dynamic rawQty = response.data['data'][0]['available_qty'];
        final double availableQty;

        if (rawQty is String) {
          availableQty = double.tryParse(rawQty) ?? 0.0;
        } else if (rawQty is num) {
          availableQty = rawQty.toDouble();
        } else {
          availableQty = 0.0;
        }

        logger.d('📦 Available quantity for $icCode: $availableQty');
        return availableQty;
      }

      return 0.0;
    } catch (e) {
      logger.e('⛔ Error checking available quantity', error: e);
      return 0.0; // ในกรณี error ให้ return 0 เพื่อความปลอดภัย
    }
  }

  @override
  Future<Map<String, double>> getStockQuantities({
    required List<String> icCodes,
  }) async {
    try {
      if (icCodes.isEmpty) return {};

      // สร้าง WHERE clause สำหรับ ic_code ทั้งหมด
      final icCodeList = icCodes.map((code) => "'$code'").join(',');

      final query =
          """
        SELECT 
          ic_code,
          COALESCE(
            (SELECT SUM(balance_qty) FROM ic_balance WHERE ic_code = ic_list.ic_code), 0
          ) - COALESCE(
            (SELECT SUM(quantity) 
             FROM cart_items ci 
             INNER JOIN carts c ON ci.cart_id = c.id 
             WHERE ci.ic_code = ic_list.ic_code AND c.status = 'active'), 0
          ) as available_qty
        FROM (
          SELECT UNNEST(ARRAY[$icCodeList]) as ic_code
        ) ic_list
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      final Map<String, double> stockMap = {};

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> results = response.data['data'];
        for (final result in results) {
          final icCode = result['ic_code']?.toString();

          // แปลง available_qty อย่างปลอดภัย ไม่ว่าจะเป็น String หรือ number
          final dynamic rawQty = result['available_qty'];
          final double availableQty;

          if (rawQty is String) {
            availableQty = double.tryParse(rawQty) ?? 0.0;
          } else if (rawQty is num) {
            availableQty = rawQty.toDouble();
          } else {
            availableQty = 0.0;
          }

          if (icCode != null) {
            stockMap[icCode] = availableQty;
          }
        }
      }

      // สำหรับสินค้าที่ไม่พบ ให้ set เป็น 0
      for (final icCode in icCodes) {
        if (!stockMap.containsKey(icCode)) {
          stockMap[icCode] = 0.0;
        }
      }

      logger.d('📦 Available stock quantities loaded: $stockMap');
      return stockMap;
    } catch (e) {
      logger.e('⛔ Error getting stock quantities', error: e);
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
      final query =
          """
        SELECT ci.id, ci.cart_id, ci.ic_code, ci.barcode, ci.unit_code, 
               ci.quantity, ci.unit_price, ci.total_price, ci.created_at, ci.updated_at
        FROM cart_items ci
        INNER JOIN carts c ON ci.cart_id = c.id
        WHERE c.customer_id = $customerId AND c.status = 'active'
        ORDER BY ci.created_at DESC
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Get cart items response: ${response.data}');
      }

      if (response.data['success'] == true && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      logger.e('⛔ Error getting cart items', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error getting cart items: $e');
      }
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
      if (quantity <= 0) {
        await removeFromCart(customerId: customerId, icCode: icCode);
        return;
      }

      // ลองทำ Refresh ยอดคงเหลือจากฐานข้อมูลหลักก่อน (optional fallback)
      await refreshInventoryBalance(icCode: icCode).catchError((e) {
        // ไม่ต้องทำอะไร - ใช้ real-time calculation แทน
        logger.d(
          '🔄 Using real-time calculation instead of refresh for $icCode',
        );
        return false;
      });

      // ตรวจสอบยอดพร้อมสั่งแบบ real-time(ไม่รวมจำนวนของลูกค้าปัจจุบัน)
      final availableQty = await getAvailableQuantityRealtime(
        icCode: icCode,
        currentCustomerId: customerId,
      );

      if (quantity > availableQty) {
        throw Exception(
          'ไม่สามารถสั่งได้เกินยอดพร้อมสั่ง: ${availableQty.toStringAsFixed(0)} หน่วย',
        );
      }

      final query =
          """
        UPDATE cart_items 
        SET quantity = $quantity, 
            total_price = $quantity * unit_price,
            updated_at = CURRENT_TIMESTAMP
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      """;

      final response = await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Update quantity response: ${response.data}');
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(cart.id!);

      // Log ยอดพร้อมสั่งใหม่หลังจากอัปเดตในตะกร้า
      final newAvailableQty = await getAvailableQuantityRealtime(
        icCode: icCode,
        currentCustomerId: customerId,
      );
      logger.d('📊 Updated available quantity for $icCode: $newAvailableQty');
    } catch (e) {
      logger.e('⛔ Error updating cart item quantity', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error updating cart item quantity: $e');
      }
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  }) async {
    try {
      final query =
          """
        DELETE FROM cart_items 
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        ) AND ic_code = '$icCode'
      """;

      final response = await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d(
          '🛒 [DATA_SOURCE] Remove from cart response: ${response.data}',
        );
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(cart.id!);

      // Log ยอดพร้อมสั่งใหม่หลังจากลบจากตะกร้า
      final newAvailableQty = await getAvailableQuantityRealtime(
        icCode: icCode,
        currentCustomerId: customerId,
      );
      logger.d(
        '📊 Updated available quantity for $icCode after removal: $newAvailableQty',
      );
    } catch (e) {
      logger.e('⛔ Error removing from cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error removing from cart: $e');
      }
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> clearCart({required int customerId}) async {
    try {
      // ดึงรายการสินค้าก่อนลบเพื่อ refresh inventory
      final cartItems = await getCartItems(customerId: customerId);
      final icCodes = cartItems.map((item) => item.icCode).toList();

      final query =
          """
        DELETE FROM cart_items 
        WHERE cart_id IN (
          SELECT id FROM carts WHERE customer_id = $customerId AND status = 'active'
        )
      """;

      final response = await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Clear cart response: ${response.data}');
      }

      // อัปเดตยอดรวมในตระกร้า
      final cart = await getActiveCart(customerId: customerId);
      await _updateCartTotals(
        cart.id!,
      ); // Refresh ยอดคงเหลือของสินค้าทั้งหมดที่เคยอยู่ในตะกร้า
      if (icCodes.isNotEmpty) {
        try {
          await refreshMultipleInventoryBalances(icCodes: icCodes);
          logger.d(
            '📊 Refreshed inventory balances for ${icCodes.length} items after cart clear',
          );
        } catch (e) {
          logger.w(
            '⚠️ Could not refresh inventory balances after cart clear, continuing...',
          );
        }
      }
    } catch (e) {
      logger.e('⛔ Error clearing cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error clearing cart: $e');
      }
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<OrderModel> createOrder({required int customerId}) async {
    try {
      final cart = await getActiveCart(customerId: customerId);
      final cartItems = await getCartItems(customerId: customerId);

      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      } // Refresh ยอดคงเหลือของสินค้าทั้งหมดก่อนสร้าง order
      final icCodes = cartItems.map((item) => item.icCode).toList();
      try {
        await refreshMultipleInventoryBalances(icCodes: icCodes);
        logger.d('🔄 Refreshed inventory balances before creating order');
      } catch (e) {
        logger.w(
          '⚠️ Could not refresh inventory balances before creating order, continuing...',
        );
      }

      // ตรวจสอบยอดพร้อมสั่งสำหรับสินค้าทั้งหมดก่อนสร้าง order
      for (var item in cartItems) {
        final availableQty = await getAvailableQuantityRealtime(
          icCode: item.icCode,
          currentCustomerId: customerId,
        );

        if (item.quantity > availableQty) {
          throw Exception(
            'ไม่สามารถสร้างออเดอร์ได้ สินค้า ${item.icCode} มียอดพร้อมสั่งไม่เพียงพอ (ต้องการ: ${item.quantity}, พร้อมสั่ง: $availableQty)',
          );
        }
      }

      // สร้างหมายเลขออเดอร์
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // สร้างออเดอร์
      final orderQuery =
          """
        INSERT INTO orders (cart_id, customer_id, order_number, total_amount, status, payment_status) 
        VALUES (${cart.id}, $customerId, '$orderNumber', ${cart.totalAmount}, 'pending', 'pending')
        RETURNING id, cart_id, customer_id, order_number, status, total_amount, shipping_address, 
                  payment_method, payment_status, notes, ordered_at
      """;

      final orderResponse = await dio.post(
        '/pgcommand',
        data: {'query': orderQuery},
      );

      if (orderResponse.data['success'] != true ||
          orderResponse.data['data'] == null ||
          orderResponse.data['data'].isEmpty) {
        throw Exception('Failed to create order');
      }

      final order = OrderModel.fromJson(orderResponse.data['data'][0]);

      // สร้างรายการสินค้าในออเดอร์
      for (var item in cartItems) {
        final itemQuery =
            """
          INSERT INTO order_items (order_id, ic_code, product_name, barcode, unit_code, quantity, unit_price, total_price)
          SELECT ${order.id}, '${item.icCode}', 
                 COALESCE(i.name, 'Unknown Product'), 
                 '${item.barcode ?? ''}', '${item.unitCode ?? ''}', 
                 ${item.quantity}, ${item.unitPrice}, ${item.totalPrice}
          FROM ic_inventory i 
          WHERE i.ic_code = '${item.icCode}'
        """;

        await dio.post('/pgcommand', data: {'command': itemQuery});
      }

      // อัปเดตสถานะตระกร้าเป็น completed
      final updateCartQuery =
          """
        UPDATE carts 
        SET status = 'completed', updated_at = CURRENT_TIMESTAMP
        WHERE id = ${cart.id}
      """;

      await dio.post('/pgcommand', data: {'command': updateCartQuery});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Order created: ${order.orderNumber}');
      }

      return order;
    } catch (e) {
      logger.e('⛔ Error creating order', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error creating order: $e');
      }
      throw Exception('Failed to create order: $e');
    }
  }

  /// อัปเดตยอดรวมและจำนวนรายการในตระกร้า
  Future<void> _updateCartTotals(int cartId) async {
    try {
      final query =
          """
        UPDATE carts 
        SET total_amount = (
          SELECT COALESCE(SUM(total_price), 0) 
          FROM cart_items 
          WHERE cart_id = $cartId
        ),
        total_items = (
          SELECT COALESCE(SUM(quantity), 0) 
          FROM cart_items 
          WHERE cart_id = $cartId
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = $cartId
      """;

      await dio.post('/pgcommand', data: {'command': query});

      if (kDebugMode) {
        logger.d('🛒 [DATA_SOURCE] Cart totals updated for cart: $cartId');
      }
    } catch (e) {
      logger.e('⛔ Error updating cart totals', error: e);
    }
  }

  @override
  Future<double> getAvailableQuantityRealtime({
    required String icCode,
    required int currentCustomerId,
  }) async {
    try {
      final query =
          """
        SELECT 
          COALESCE(
            (SELECT SUM(balance_qty) FROM ic_balance WHERE ic_code = '$icCode'), 0
          ) - COALESCE(
            (SELECT SUM(quantity) 
             FROM cart_items ci 
             INNER JOIN carts c ON ci.cart_id = c.id 
             WHERE ci.ic_code = '$icCode' AND c.status = 'active' AND c.customer_id != $currentCustomerId), 0
          ) as available_qty
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      if (kDebugMode) {
        logger.d(
          '📦 [DATA_SOURCE] Real-time available quantity response: ${response.data}',
        );
      }
      if (response.data['success'] == true &&
          response.data['data'] != null &&
          response.data['data'].isNotEmpty) {
        // แปลง available_qty อย่างปลอดภัย ไม่ว่าจะเป็น String หรือ number
        final dynamic rawQty = response.data['data'][0]['available_qty'];
        final double availableQty;

        if (rawQty is String) {
          availableQty = double.tryParse(rawQty) ?? 0.0;
        } else if (rawQty is num) {
          availableQty = rawQty.toDouble();
        } else {
          availableQty = 0.0;
        }

        logger.d(
          '📦 Real-time available quantity for $icCode (excluding customer $currentCustomerId): $availableQty',
        );
        return availableQty;
      }

      return 0.0;
    } catch (e) {
      logger.e('⛔ Error getting real-time available quantity', error: e);
      return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getAvailableQuantitiesForCart({
    required int customerId,
  }) async {
    try {
      final query =
          """
        SELECT 
          ci.ic_code,
          COALESCE(
            (SELECT SUM(balance_qty) FROM ic_balance WHERE ic_code = ci.ic_code), 0
          ) - COALESCE(
            (SELECT SUM(quantity) 
             FROM cart_items ci2 
             INNER JOIN carts c2 ON ci2.cart_id = c2.id 
             WHERE ci2.ic_code = ci.ic_code AND c2.status = 'active' AND c2.customer_id != $customerId), 0
          ) as available_qty
        FROM cart_items ci
        INNER JOIN carts c ON ci.cart_id = c.id
        WHERE c.customer_id = $customerId AND c.status = 'active'
        GROUP BY ci.ic_code
      """;

      final response = await dio.post('/pgselect', data: {'query': query});

      final Map<String, double> availableMap = {};

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> results = response.data['data'];
        for (final result in results) {
          final String? icCode = result['ic_code']?.toString();

          // แปลง available_qty อย่างปลอดภัย ไม่ว่าจะเป็น String หรือ number
          final dynamic rawQty = result['available_qty'];
          final double availableQty;

          if (rawQty is String) {
            availableQty = double.tryParse(rawQty) ?? 0.0;
          } else if (rawQty is num) {
            availableQty = rawQty.toDouble();
          } else {
            availableQty = 0.0;
          }

          if (icCode != null) {
            availableMap[icCode] = availableQty;
          }
        }
      }

      if (kDebugMode) {
        logger.d(
          '🛒 [DATA_SOURCE] Available quantities for cart: $availableMap',
        );
      }

      return availableMap;
    } catch (e) {
      logger.e('⛔ Error getting available quantities for cart', error: e);
      if (kDebugMode) {
        debugPrint('💥 Error getting available quantities for cart: $e');
      }
      return <String, double>{};
    }
  }

  /// Refresh ยอดคงเหลือจากฐานข้อมูลหลัก (ic_balance)
  /// เรียกใช้เพื่อ sync ข้อมูลคงเหลือล่าสุดจาก inventory system
  Future<bool> refreshInventoryBalance({required String icCode}) async {
    try {
      // Query เพื่อ refresh ยอดคงเหลือจากระบบหลัก
      final refreshQuery =
          """
        -- Refresh balance from main inventory system
        -- This would typically sync from ic_inventory to ic_balance
        UPDATE ic_balance 
        SET balance_qty = (
          SELECT COALESCE(on_hand_qty, 0) 
          FROM ic_inventory 
          WHERE ic_code = '$icCode'
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE ic_code = '$icCode';
        
        -- Insert if not exists
        INSERT INTO ic_balance (ic_code, balance_qty, updated_at)
        SELECT '$icCode', COALESCE(on_hand_qty, 0), CURRENT_TIMESTAMP
        FROM ic_inventory 
        WHERE ic_code = '$icCode'
        AND NOT EXISTS (SELECT 1 FROM ic_balance WHERE ic_code = '$icCode');
      """;

      final response = await dio.post(
        '/pgcommand',
        data: {'query': refreshQuery},
      );

      if (kDebugMode) {
        logger.d(
          '🔄 [DATA_SOURCE] Refresh inventory balance for $icCode: ${response.data}',
        );
      }
      if (response.data['success'] == true) {
        logger.d('✅ Inventory balance refreshed for $icCode');
        return true;
      } else {
        // Silent fallback - ไม่แสดงข้อความเตือน
        logger.d('🔄 Refresh failed for $icCode, using real-time calculation');
        return false;
      }
    } catch (e) {
      // Silent fallback - ไม่แสดงข้อความเตือน เพราะเป็น scenario ที่คาดหวังได้
      logger.d('🔄 Using real-time calculation for $icCode (fallback)');
      return false;
    }
  }

  /// Refresh ยอดคงเหลือสำหรับหลายสินค้าพร้อมกัน
  Future<bool> refreshMultipleInventoryBalances({
    required List<String> icCodes,
  }) async {
    try {
      if (icCodes.isEmpty) return true;

      final icCodeList = icCodes.map((code) => "'$code'").join(',');

      final refreshQuery =
          """
        -- Refresh balance from main inventory system for multiple items
        UPDATE ic_balance 
        SET balance_qty = (
          SELECT COALESCE(on_hand_qty, 0) 
          FROM ic_inventory 
          WHERE ic_inventory.ic_code = ic_balance.ic_code
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE ic_code IN ($icCodeList);
        
        -- Insert missing items
        INSERT INTO ic_balance (ic_code, balance_qty, updated_at)
        SELECT ic_code, COALESCE(on_hand_qty, 0), CURRENT_TIMESTAMP
        FROM ic_inventory 
        WHERE ic_code IN ($icCodeList)
        AND NOT EXISTS (SELECT 1 FROM ic_balance WHERE ic_balance.ic_code = ic_inventory.ic_code);
      """;

      final response = await dio.post(
        '/pgcommand',
        data: {'query': refreshQuery},
      );

      if (kDebugMode) {
        logger.d(
          '🔄 [DATA_SOURCE] Refresh multiple inventory balances: ${response.data}',
        );
      }

      if (response.data['success'] == true) {
        logger.d('✅ Inventory balances refreshed for ${icCodes.length} items');
        return true;
      } else {
        logger.w('⚠️ Failed to refresh inventory balances');
        return false;
      }
    } catch (e) {
      logger.e('⛔ Error refreshing multiple inventory balances', error: e);
      return false;
    }
  }
}
