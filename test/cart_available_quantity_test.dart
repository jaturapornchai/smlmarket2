import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:smlmarket/data/data_sources/cart_remote_data_source.dart';

// Mock classes
class MockDio extends Mock implements Dio {}
class MockLogger extends Mock implements Logger {}

void main() {
  group('Cart Available Quantity Tests', () {
    late CartRemoteDataSource cartDataSource;
    late MockDio mockDio;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      cartDataSource = CartRemoteDataSource(dio: mockDio, logger: mockLogger);
    });

    test('checkAvailableQuantity should return correct available quantity', () async {
      // Arrange
      const icCode = 'IC001';
      final mockResponse = Response(
        data: {
          'success': true,
          'data': [
            {'available_qty': 10.0}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await cartDataSource.checkAvailableQuantity(icCode: icCode);

      // Assert
      expect(result, equals(10.0));
      verify(mockDio.post('/pgselect', data: anyNamed('data'))).called(1);
    });

    test('getAvailableQuantityRealtime should exclude current customer cart', () async {
      // Arrange
      const icCode = 'IC001';
      const customerId = 1;
      final mockResponse = Response(
        data: {
          'success': true,
          'data': [
            {'available_qty': 15.0}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await cartDataSource.getAvailableQuantityRealtime(
        icCode: icCode, 
        currentCustomerId: customerId
      );

      // Assert
      expect(result, equals(15.0));
      verify(mockDio.post('/pgselect', data: anyNamed('data'))).called(1);
    });

    test('addToCart should validate available quantity before adding', () async {
      // Arrange - setup checkAvailableQuantity to return 5
      final availabilityResponse = Response(
        data: {
          'success': true,
          'data': [
            {'available_qty': 5.0}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => availabilityResponse);

      // Act & Assert - should throw exception when trying to add 10 items with only 5 available
      expect(
        () async => await cartDataSource.addToCart(
          cartId: 1,
          icCode: 'IC001',
          barcode: null,
          unitCode: null,
          quantity: 10.0,
          unitPrice: 100.0,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('ไม่สามารถสั่งได้เกินยอดพร้อมสั่ง'),
        )),
      );
    });

    test('getAvailableQuantitiesForCart should return quantities for all cart items', () async {
      // Arrange
      const customerId = 1;
      final mockResponse = Response(
        data: {
          'success': true,
          'data': [
            {'ic_code': 'IC001', 'available_qty': 10.0},
            {'ic_code': 'IC002', 'available_qty': 25.0},
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await cartDataSource.getAvailableQuantitiesForCart(
        customerId: customerId
      );

      // Assert
      expect(result, equals({
        'IC001': 10.0,
        'IC002': 25.0,
      }));
      verify(mockDio.post('/pgselect', data: anyNamed('data'))).called(1);
    });

    test('updateCartItemQuantity should validate against real-time availability', () async {
      // Arrange - setup real-time availability to return 8
      final availabilityResponse = Response(
        data: {
          'success': true,
          'data': [
            {'available_qty': 8.0}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => availabilityResponse);

      // Act & Assert - should throw exception when trying to update to 15 items with only 8 available
      expect(
        () async => await cartDataSource.updateCartItemQuantity(
          customerId: 1,
          icCode: 'IC001',
          quantity: 15.0,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('ไม่สามารถสั่งได้เกินยอดพร้อมสั่ง'),
        )),
      );
    });

    test('checkAvailableQuantity should return 0 on database error', () async {
      // Arrange
      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenThrow(Exception('Database connection failed'));

      // Act
      final result = await cartDataSource.checkAvailableQuantity(icCode: 'IC001');

      // Assert
      expect(result, equals(0.0));
    });

    test('checkAvailableQuantity should handle empty response gracefully', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'success': true,
          'data': []
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/pgselect'),
      );

      when(mockDio.post('/pgselect', data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await cartDataSource.checkAvailableQuantity(icCode: 'IC001');

      // Assert
      expect(result, equals(0.0));
    });
  });
}
