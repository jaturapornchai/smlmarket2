import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  final Logger logger;

  CartCubit({required this.repository, required this.logger}) : super(CartInitial());

  Future<void> addToCart({
    required ProductModel product,
    required int quantity,
    int userId = 1, // ตัวอย่าง userId
  }) async {
    try {
      emit(CartLoading());

      // ตรวจสอบข้อมูลสินค้า
      if (product.id == null) {
        emit(const CartError(message: 'ข้อมูลสินค้าไม่ถูกต้อง'));
        return;
      }

      final productId = int.tryParse(product.id!) ?? 0;
      if (productId == 0) {
        emit(const CartError(message: 'รหัสสินค้าไม่ถูกต้อง'));
        return;
      }

      // ตรวจสอบราคา
      final unitPrice = product.finalPrice ?? product.salePrice ?? product.price ?? 0.0;
      if (unitPrice <= 0) {
        emit(const CartError(message: 'ราคาสินค้าไม่ถูกต้อง'));
        return;
      }

      logger.d('Adding to cart: Product ID: $productId, Quantity: $quantity, Price: $unitPrice');

      // เพิ่มสินค้าเข้าตระกร้า
      final cartItem = await repository.addProductToCart(
        userId: userId,
        productId: productId,
        barcode: product.barcodes?.isNotEmpty == true ? product.barcodes!.split(',').first.trim() : null,
        unitCode: product.unitStandardCode,
        quantity: quantity,
        unitPrice: unitPrice,
      );

      emit(CartSuccess(
        cartItem: cartItem,
        message: 'เพิ่มสินค้าเข้าตระกร้าเรียบร้อย',
      ));

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
    required int productId,
    required int requestedQuantity,
  }) async {
    try {
      emit(CartLoading());

      final hasStock = await repository.checkStockAvailability(
        productId: productId,
        requestedQuantity: requestedQuantity,
      );

      // ดึงข้อมูลจำนวนที่มีอยู่
      final availableQty = await repository.remoteDataSource.checkAvailableQuantity(
        productId: productId,
      );

      emit(StockCheckSuccess(
        hasStock: hasStock,
        availableQuantity: availableQty,
        productId: productId,
      ));

      logger.d('Stock check: Product $productId, Available: $availableQty, Requested: $requestedQuantity, HasStock: $hasStock');
    } catch (e) {
      logger.e('Error checking stock: $e');
      emit(const CartError(message: 'ไม่สามารถตรวจสอบสต็อกได้'));
    }
  }

  void resetState() {
    emit(CartInitial());
  }
}
