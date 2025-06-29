import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../utils/service_locator.dart' as di;
import '../../presentation/cubit/cart_cubit.dart';

class TestAddToCartWidget extends StatefulWidget {
  const TestAddToCartWidget({Key? key}) : super(key: key);

  @override
  State<TestAddToCartWidget> createState() => _TestAddToCartWidgetState();
}

class _TestAddToCartWidgetState extends State<TestAddToCartWidget> {
  final CartCubit _cartCubit = di.sl<CartCubit>();
  String _result = '';
  bool _isLoading = false;

  void _testAddToCart() async {
    setState(() {
      _isLoading = true;
      _result = 'กำลังทดสอบเพิ่มสินค้าลงตระกร้า...';
    });

    try {
      // สร้างสินค้าทดสอบ
      final testProduct = ProductModel(
        id: 'TEST001',
        code: 'TEST001',
        name: 'สินค้าทดสอบ',
        unitStandardCode: 'PCS',
        itemType: 1,
        rowOrderRef: 1,
        price: 100.0,
        salePrice: 90.0,
        finalPrice: 85.0,
        qtyAvailable: 50.0,
        imgUrl: null,
      );

      await _cartCubit.addToCart(
        product: testProduct,
        quantity: 1.0,
        userId: 1,
      );

      setState(() {
        _result = '✅ เพิ่มสินค้าลงตระกร้าสำเร็จ!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Add to Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAddToCart,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('ทดสอบเพิ่มสินค้าลงตระกร้า'),
            ),
            const SizedBox(height: 16),
            Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
