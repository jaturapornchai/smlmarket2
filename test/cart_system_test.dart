import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../lib/data/repositories/cart_repository.dart';
import '../lib/data/models/product_model.dart';
import '../lib/data/models/cart_item_model.dart';
import '../lib/presentation/cubit/cart_cubit.dart';
import '../lib/presentation/cubit/cart_state.dart';

// Mock classes
class MockCartRepository extends Mock implements CartRepository {}

void main() {
  group('CartCubit Tests', () {
    late CartCubit cartCubit;
    late MockCartRepository mockRepository;
    late Logger logger;

    setUp(() {
      mockRepository = MockCartRepository();
      logger = Logger();
      cartCubit = CartCubit(repository: mockRepository, logger: logger);
    });

    tearDown(() {
      cartCubit.close();
    });

    test('should check stock successfully when stock is available', () async {
      // Arrange
      const productId = 1;
      const requestedQuantity = 2;
      const availableQuantity = 10;

      when(mockRepository.checkStockAvailability(
        productId: productId,
        requestedQuantity: requestedQuantity,
      )).thenAnswer((_) async => true);

      when(mockRepository.getAvailableQuantity(
        productId: productId,
      )).thenAnswer((_) async => availableQuantity);

      // Act
      await cartCubit.checkStock(
        productId: productId,
        requestedQuantity: requestedQuantity,
      );

      // Assert
      expect(cartCubit.state, isA<StockCheckSuccess>());
      final state = cartCubit.state as StockCheckSuccess;
      expect(state.hasStock, true);
      expect(state.availableQuantity, availableQuantity);
      expect(state.productId, productId);

      print('✅ Stock check test passed: Available $availableQuantity, Requested $requestedQuantity');
    });

    test('should handle insufficient stock', () async {
      // Arrange
      const productId = 1;
      const requestedQuantity = 15;
      const availableQuantity = 5;

      when(mockRepository.checkStockAvailability(
        productId: productId,
        requestedQuantity: requestedQuantity,
      )).thenAnswer((_) async => false);

      when(mockRepository.getAvailableQuantity(
        productId: productId,
      )).thenAnswer((_) async => availableQuantity);

      // Act
      await cartCubit.checkStock(
        productId: productId,
        requestedQuantity: requestedQuantity,
      );

      // Assert
      expect(cartCubit.state, isA<StockCheckSuccess>());
      final state = cartCubit.state as StockCheckSuccess;
      expect(state.hasStock, false);
      expect(state.availableQuantity, availableQuantity);

      print('✅ Insufficient stock test passed: Available $availableQuantity, Requested $requestedQuantity');
    });

    test('should add product to cart successfully', () async {
      // Arrange
      final product = ProductModel(
        id: '1',
        name: 'Test Product',
        price: 199.99,
        salePrice: 179.99,
        finalPrice: 179.99,
        unitStandardCode: 'PCS',
        barcodes: '1234567890123',
        availableQty: 10.0,
      );

      final cartItem = CartItemModel(
        id: 1,
        cartId: 1,
        productId: 1,
        barcode: '1234567890123',
        unitCode: 'PCS',
        quantity: 2,
        unitPrice: 179.99,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.addProductToCart(
        userId: anyNamed('userId'),
        productId: anyNamed('productId'),
        barcode: anyNamed('barcode'),
        unitCode: anyNamed('unitCode'),
        quantity: anyNamed('quantity'),
        unitPrice: anyNamed('unitPrice'),
      )).thenAnswer((_) async => cartItem);

      // Act
      await cartCubit.addToCart(product: product, quantity: 2);

      // Assert
      expect(cartCubit.state, isA<CartSuccess>());
      final state = cartCubit.state as CartSuccess;
      expect(state.cartItem.productId, 1);
      expect(state.cartItem.quantity, 2);

      print('✅ Add to cart test passed: ${state.message}');
    });

    test('should handle add to cart error when stock insufficient', () async {
      // Arrange
      final product = ProductModel(
        id: '1',
        name: 'Test Product',
        price: 199.99,
        availableQty: 1.0,
      );

      when(mockRepository.addProductToCart(
        userId: anyNamed('userId'),
        productId: anyNamed('productId'),
        barcode: anyNamed('barcode'),
        unitCode: anyNamed('unitCode'),
        quantity: anyNamed('quantity'),
        unitPrice: anyNamed('unitPrice'),
      )).thenThrow(Exception('สินค้าไม่เพียงพอ'));

      // Act
      await cartCubit.addToCart(product: product, quantity: 5);

      // Assert
      expect(cartCubit.state, isA<CartError>());
      final state = cartCubit.state as CartError;
      expect(state.message, contains('สินค้าไม่เพียงพอ'));

      print('✅ Stock insufficient error test passed: ${state.message}');
    });

    test('should handle invalid product ID', () async {
      // Arrange
      final product = ProductModel(
        id: null, // Invalid ID
        name: 'Test Product',
        price: 199.99,
      );

      // Act
      await cartCubit.addToCart(product: product, quantity: 1);

      // Assert
      expect(cartCubit.state, isA<CartError>());
      final state = cartCubit.state as CartError;
      expect(state.message, 'ข้อมูลสินค้าไม่ถูกต้อง');

      print('✅ Invalid product ID test passed: ${state.message}');
    });
  });

  // Manual test function to simulate real usage
  print('\n🔄 Running Cart System Simulation...');
  
  runCartSimulation();
}

void runCartSimulation() {
  print('\n📊 === Cart System Test Simulation ===');
  
  // จำลองสินค้า
  final product = ProductModel(
    id: '1',
    name: 'iPhone 15 Pro',
    price: 45000.0,
    salePrice: 42000.0,
    finalPrice: 42000.0,
    unitStandardCode: 'PCS',
    barcodes: '1234567890123',
    availableQty: 5.0,
  );

  print('📱 Product: ${product.name}');
  print('💰 Price: ฿${product.finalPrice}');
  print('📦 Available: ${product.availableQty} ชิ้น');
  
  // จำลองการตรวจสอบสต็อก
  print('\n🔍 Checking stock for quantity 2...');
  final availableQty = product.availableQty!.toInt();
  final requestedQty = 2;
  
  if (availableQty >= requestedQty) {
    print('✅ Stock available: $availableQty >= $requestedQty');
    
    // จำลองการเพิ่มเข้าตะกร้า
    print('\n🛒 Adding to cart...');
    final cartItem = CartItemModel(
      id: 1,
      cartId: 1,
      productId: int.parse(product.id!),
      barcode: product.barcodes?.split(',').first.trim(),
      unitCode: product.unitStandardCode,
      quantity: requestedQty,
      unitPrice: product.finalPrice!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('✅ Successfully added to cart:');
    print('   - Product ID: ${cartItem.productId}');
    print('   - Quantity: ${cartItem.quantity}');
    print('   - Unit Price: ฿${cartItem.unitPrice}');
    print('   - Total: ฿${cartItem.quantity * cartItem.unitPrice!}');
    print('   - Barcode: ${cartItem.barcode}');
    print('   - Unit Code: ${cartItem.unitCode}');
  } else {
    print('❌ Insufficient stock: $availableQty < $requestedQty');
  }
  
  // จำลองการตรวจสอบสต็อกเมื่อไม่เพียงพอ
  print('\n🔍 Checking stock for quantity 10...');
  final requestedQty2 = 10;
  
  if (availableQty >= requestedQty2) {
    print('✅ Stock available');
  } else {
    print('❌ Insufficient stock: มีอยู่ $availableQty ชิ้น แต่ต้องการ $requestedQty2 ชิ้น');
  }
  
  print('\n🎉 Cart System Simulation Complete!');
}
