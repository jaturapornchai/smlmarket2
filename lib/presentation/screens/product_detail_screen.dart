import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String _getRandomImageUrl(String productId) {
    final List<String> imageUrls = [
      'https://picsum.photos/id/1/400/400',
      'https://picsum.photos/id/2/400/400',
      'https://picsum.photos/id/3/400/400',
      'https://picsum.photos/id/4/400/400',
      'https://picsum.photos/id/5/400/400',
      'https://dummyimage.com/400x400/4A90E2/FFFFFF&text=Product+1',
      'https://dummyimage.com/400x400/E74C3C/FFFFFF&text=Product+2',
      'https://dummyimage.com/400x400/2ECC71/FFFFFF&text=Product+3',
      'https://dummyimage.com/400x400/F39C12/FFFFFF&text=Product+4',
      'https://dummyimage.com/400x400/9B59B6/FFFFFF&text=Product+5',
      'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Item+1',
      'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Item+2',
      'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Item+3',
      'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=Item+4',
      'https://via.placeholder.com/400x400/FCEA2B/FFFFFF?text=Item+5',
      'https://picsum.photos/id/10/400/400',
      'https://picsum.photos/id/11/400/400',
      'https://picsum.photos/id/12/400/400',
      'https://picsum.photos/id/13/400/400',
      'https://picsum.photos/id/14/400/400',
    ];
    final int index = productId.hashCode.abs() % imageUrls.length;
    return imageUrls[index];
  }
  void _increaseQuantity() {
    if (quantity < (widget.product.availableQty.toInt())) {
      setState(() {
        quantity++;
        _quantityController.text = quantity.toString();
      });
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _quantityController.text = quantity.toString();
      });
    }
  }
  void _updateQuantityFromInput() {
    final newQuantity = int.tryParse(_quantityController.text) ?? 1;
    final maxQty = widget.product.availableQty.toInt();
    
    setState(() {
      quantity = newQuantity.clamp(1, maxQty);
      _quantityController.text = quantity.toString();
    });
  }

  void _setQuickQuantity(int newQuantity) {
    final maxQty = widget.product.availableQty.toInt();
    setState(() {
      quantity = newQuantity.clamp(1, maxQty);
      _quantityController.text = quantity.toString();
    });
  }

  void _addToCart() {
    // สำหรับตอนนี้แค่แสดง SnackBar และกลับไปหน้าเดิม
    // ในอนาคตสามารถเพิ่มฟีเจอร์ cart จริงๆ ได้

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'เพิ่ม ${widget.product.name} จำนวน $quantity ลงในตะกร้าแล้ว',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // กลับไปหน้าเดิม
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name ?? 'รายละเอียดสินค้า',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: 16),
                    _buildProductBasicInfo(),
                    const SizedBox(height: 16),
                    _buildPriceSection(),
                    const SizedBox(height: 16),
                    if (widget.product.premiumWord != null &&
                        widget.product.premiumWord!.isNotEmpty)
                      _buildPremiumSection(),
                    if (widget.product.premiumWord != null &&
                        widget.product.premiumWord!.isNotEmpty)
                      const SizedBox(height: 16),
                    _buildStockAndSalesInfo(),
                    const SizedBox(height: 16),
                    _buildDiscountInfo(),
                    const SizedBox(height: 16),
                    _buildQuantitySelector(),
                    const SizedBox(height: 100), // พื้นที่สำหรับปุ่ม
                  ],
                ),
              ),
            ),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            (widget.product.imgUrl != null && widget.product.imgUrl!.isNotEmpty)
                ? widget.product.imgUrl!
                : _getRandomImageUrl(
                    widget.product.id ?? widget.product.code ?? '0',
                  ),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[100],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[100],
                child: Icon(Icons.inventory, size: 80, color: Colors.grey[400]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductBasicInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name ?? 'ไม่ระบุชื่อสินค้า',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.product.code != null && widget.product.code!.isNotEmpty)
              Text(
                'รหัสสินค้า: ${widget.product.code}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (widget.product.id != null && widget.product.id!.isNotEmpty)
              Text(
                'ID: ${widget.product.id}',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ราคา',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '฿${widget.product.displayPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.product.hasPriceDiscrepancy
                        ? Colors.red[700]
                        : Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.product.hasPriceDiscrepancy)
                  Text(
                    '฿${widget.product.salePrice!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.orange[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.orange[700], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.product.premiumWord!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAndSalesInfo() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, color: Colors.green[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'สต็อก',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.availableQty.toInt()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (widget.product.hasSoldQty)
          Expanded(
            child: Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[50]!, Colors.amber[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.amber[600],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ขายแล้ว',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product.soldQty!.toInt()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDiscountInfo() {
    List<Widget> discountWidgets = [];

    if (widget.product.hasDiscountPrice) {
      discountWidgets.add(
        _buildDiscountCard(
          'ส่วนลดราคา',
          '฿${widget.product.discountPrice!.toStringAsFixed(0)}',
          Colors.red,
          Icons.money_off,
        ),
      );
    }

    if (widget.product.hasDiscountPercent) {
      discountWidgets.add(
        _buildDiscountCard(
          'ส่วนลดเปอร์เซ็นต์',
          '${widget.product.discountPercent!.toStringAsFixed(0)}%',
          Colors.orange,
          Icons.percent,
        ),
      );
    }

    if (widget.product.hasDiscountWord) {
      discountWidgets.add(
        _buildDiscountCard(
          'โปรโมชั่น',
          widget.product.discountWord!,
          Colors.purple,
          Icons.local_offer,
        ),
      );
    }

    if (widget.product.hasMultiPackingName) {
      discountWidgets.add(
        _buildDiscountCard(
          'แพ็คเกจ',
          widget.product.multiPackingName!,
          Colors.blue,
          Icons.inventory_2,
        ),
      );
    }

    if (discountWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ข้อมูลส่วนลด & โปรโมชั่น',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: discountWidgets),
      ],
    );
  }

  Widget _buildDiscountCard(
    String title,
    String value,
    MaterialColor color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color[100],
        border: Border.all(color: color[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: color[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: color[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildQuantitySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แก้ไขจำนวน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            
            // ปุ่มแก้ไขจำนวนแบบใหญ่และชัดเจน
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  // ปุ่มลด
                  Material(
                    color: quantity > 1 ? Colors.red[600] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _decreaseQuantity,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.remove,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // ช่องกรอกจำนวน
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[300]!),
                      ),
                      child: TextField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '1',
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _updateQuantityFromInput();
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // ปุ่มเพิ่ม
                  Material(
                    color: quantity < widget.product.availableQty.toInt()
                        ? Colors.green[600]
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _increaseQuantity,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],              ),
            ),
            
            const SizedBox(height: 12),
            
            // ปุ่มแก้ไขจำนวนแบบด่วน
            Text(
              'แก้ไขจำนวนแบบด่วน',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickQuantityButton(1, 'x1'),
                _buildQuickQuantityButton(2, 'x2'),
                _buildQuickQuantityButton(5, 'x5'),
                _buildQuickQuantityButton(10, 'x10'),
                if (widget.product.availableQty >= 20)
                  _buildQuickQuantityButton(20, 'x20'),
                if (widget.product.availableQty >= 50)
                  _buildQuickQuantityButton(50, 'x50'),
                _buildQuickQuantityButton(widget.product.availableQty.toInt(), 'MAX'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // ข้อมูลเพิ่มเติม
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quantity < widget.product.availableQty.toInt()
                              ? 'สามารถเพิ่มได้อีก ${(widget.product.availableQty.toInt() - quantity)} ชิ้น'
                              : 'ถึงจำนวนสูงสุดแล้ว',
                          style: TextStyle(
                            fontSize: 12,
                            color: quantity < widget.product.availableQty.toInt()
                                ? Colors.blue[600]
                                : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'สต็อกทั้งหมด: ${widget.product.availableQty.toInt()} ชิ้น',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final bool canAddToCart = widget.product.availableQty > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canAddToCart ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddToCart
                    ? Colors.green[600]
                    : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canAddToCart ? 3 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    canAddToCart
                        ? 'เพิ่มลงตะกร้า (${quantity} ชิ้น)'
                        : 'สินค้าหมด',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),    );
  }

  Widget _buildQuickQuantityButton(int quantity, String label) {
    final isSelected = this.quantity == quantity;
    final isAvailable = quantity <= widget.product.availableQty.toInt();
    
    return Material(
      color: isSelected 
          ? Colors.blue[600] 
          : isAvailable 
              ? Colors.white 
              : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isAvailable ? () => _setQuickQuantity(quantity) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? Colors.blue[600]! 
                  : isAvailable 
                      ? Colors.blue[300]! 
                      : Colors.grey[400]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected 
                  ? Colors.white 
                  : isAvailable 
                      ? Colors.blue[600] 
                      : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
