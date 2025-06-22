import '../data_sources/cart_remote_data_source.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

abstract class CartRepository {
  Future<CartModel> getOrCreateActiveCart({required int userId});
  Future<CartItemModel> addProductToCart({
    required int userId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required int quantity,
    required double unitPrice,
  });
  Future<bool> checkStockAvailability({
    required String icCode,
    required int requestedQuantity,
  });
  Future<int> getAvailableQuantity({required String icCode});
}

class CartRepositoryImpl implements CartRepository {
  final CartDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CartModel> getOrCreateActiveCart({required int userId}) async {
    try {
      // ลองหาตระกร้าที่ active อยู่
      return await remoteDataSource.getActiveCart(userId: userId);
    } catch (e) {
      // ถ้าไม่มีตระกร้า active ให้สร้างใหม่
      return await remoteDataSource.createCart(userId: userId);
    }
  }

  @override
  Future<bool> checkStockAvailability({
    required String icCode,
    required int requestedQuantity,
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
      final qty = await remoteDataSource.checkAvailableQuantity(
        icCode: icCode,
      );
      return qty.toInt();
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<CartItemModel> addProductToCart({
    required int userId,
    required String icCode,
    required String? barcode,
    required String? unitCode,
    required int quantity,
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
    final cart = await getOrCreateActiveCart(userId: userId);

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
}
