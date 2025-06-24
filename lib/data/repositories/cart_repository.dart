import '../data_sources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

abstract class CartRepository {
  Future<CartModel> getOrCreateActiveCart({required int customerId});
  Future<CartItemModel> addProductToCart({
    required int customerId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  });
  Future<CartItemModel> addProductToCartDirectly({
    required int customerId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  });
  Future<bool> checkStockAvailability({
    required String icCode,
    required double requestedQuantity,
  });
  Future<int> getAvailableQuantity({required String icCode});

  // เพิ่ม method ใหม่สำหรับดึงข้อมูลยอดคงเหลือหลายสินค้า
  Future<Map<String, double>> getStockQuantities({required List<String> icCodes});

  // เพิ่มเมธอดใหม่สำหรับการจัดการตระกร้า
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
  Future<OrderModel> createOrder({required int customerId, int? cartId});
}

class CartRepositoryImpl implements CartRepository {
  final CartDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CartModel> getOrCreateActiveCart({required int customerId}) async {
    try {
      // ลองหาตระกร้าที่ active อยู่
      return await remoteDataSource.getActiveCart(customerId: customerId);
    } catch (e) {
      // ถ้าไม่มีตระกร้า active ให้สร้างใหม่
      return await remoteDataSource.createCart(customerId: customerId);
    }
  }

  @override
  Future<bool> checkStockAvailability({
    required String icCode,
    required double requestedQuantity,
  }) async {
    try {
      final availableQty = await remoteDataSource.checkAvailableQuantity(
        icCode: icCode,
      );

      return availableQty >= requestedQuantity;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getAvailableQuantity({required String icCode}) async {
    try {
      final qty = await remoteDataSource.checkAvailableQuantity(icCode: icCode);
      return qty.toInt();
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<CartItemModel> addProductToCart({
    required int customerId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  }) async {
    // 1. ตรวจสอบสต็อก
    final hasStock = await checkStockAvailability(
      icCode: icCode,
      requestedQuantity: quantity,
    );

    if (!hasStock) {
      throw Exception('สินค้าไม่เพียงพอ');
    }

    // 2. หาหรือสร้างตระกร้า
    final cart = await getOrCreateActiveCart(customerId: customerId);

    // 3. เพิ่มสินค้าเข้าตระกร้า
    return await remoteDataSource.addToCart(
      cartId: cart.id!,
      icCode: icCode,
      barcode: barcode,
      unitCode: unitCode,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  @override
  Future<List<CartItemModel>> getCartItems({required int customerId}) async {
    try {
      return await remoteDataSource.getCartItems(customerId: customerId);
    } catch (e) {
      // ถ้าไม่มีตระกร้าหรือรายการ ส่งกลับรายการว่าง
      return [];
    }
  }

  @override
  Future<void> updateCartItemQuantity({
    required int customerId,
    required String icCode,
    required double quantity,
  }) async {
    return await remoteDataSource.updateCartItemQuantity(
      customerId: customerId,
      icCode: icCode,
      quantity: quantity,
    );
  }

  @override
  Future<void> removeFromCart({
    required int customerId,
    required String icCode,
  }) async {
    return await remoteDataSource.removeFromCart(
      customerId: customerId,
      icCode: icCode,
    );
  }

  @override
  Future<void> clearCart({required int customerId}) async {
    return await remoteDataSource.clearCart(customerId: customerId);
  }

  @override
  Future<OrderModel> createOrder({required int customerId, int? cartId}) async {
    return await remoteDataSource.createOrder(customerId: customerId);
  }

  @override
  Future<CartItemModel> addProductToCartDirectly({
    required int customerId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required double quantity,
    required double unitPrice,
  }) async {
    // ไม่ตรวจสอบสต็อก เพราะทำไปแล้วใน UI layer
    // 1. หาหรือสร้างตระกร้า
    final cart = await getOrCreateActiveCart(customerId: customerId);

    // 2. เพิ่มสินค้าเข้าตระกร้าโดยตรง
    return await remoteDataSource.addToCart(
      cartId: cart.id!,
      icCode: icCode,
      barcode: barcode,
      unitCode: unitCode,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  @override
  Future<Map<String, double>> getStockQuantities({required List<String> icCodes}) async {
    try {
      return await remoteDataSource.getStockQuantities(icCodes: icCodes);
    } catch (e) {
      // ในกรณี error ให้ return ข้อมูลเป็น 0 ทั้งหมด
      final Map<String, double> fallbackMap = {};
      for (final icCode in icCodes) {
        fallbackMap[icCode] = 0.0;
      }
      return fallbackMap;
    }
  }
}
