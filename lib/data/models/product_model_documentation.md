# Product Model Documentation

## Overview
Updated ProductModel to support new fields from `/search` API endpoint.

## Field Mapping

### ✅ Existing Fields
| Field | Type | Description | API Field |
|-------|------|-------------|-----------|
| code | string | รหัสสินค้า | `code` |
| name | string | ชื่อสินค้า | `name` |
| unitStandardCode | string | หน่วยมาตรฐาน | `unit_standard_code` |
| itemType | integer | ประเภทสินค้า | `item_type` |
| rowOrderRef | integer | อ้างอิงลำดับแถว | `row_order_ref` |
| searchPriority | integer | คะแนนความเกี่ยวข้อง (1-5) | `search_priority` |
| price | DECIMAL | ราคาเดิม (backward compatibility) | `price` |

### 🆕 NEW Fields
| Field | Type | Description | API Field |
|-------|------|-------------|-----------|
| salePrice | DECIMAL | ราคาขาย | `sale_price` |
| premiumWord | string | พิเศษ (ส่วนลด) | `premium_word` |
| discountPrice | DECIMAL | ส่วนลด | `discount_price` |
| discountPercent | DECIMAL | ส่วนลด % | `discount_percent` |
| finalPrice | DECIMAL | ราคาสุดท้าย | `final_price` |
| soldQty | DECIMAL | ขายไปแล้วกี่ชิ้น | `sold_qty` |
| multiPacking | int | 0=หน่วยนับเดียว,1=หลายหน่วยนับ | `multi_packing` |
| multiPackingName | string | หลายตัวคั่นด้วย comma | `multi_packing_name` |
| barcodes | string | barcode หลายตัวคั่นด้วย comma | `barcodes` |

## Helper Methods

### `displayPrice`
Returns the best price to display to user:
- Priority: `finalPrice` > `salePrice` > `price` > 0.0

### `hasDiscount`
Returns true if product has any discount (price or percentage)

### `barcodeList`
Converts comma-separated barcodes string to List<String>

### `packingOptions`
Converts comma-separated packing names to List<String>

### `hasMultiplePacking`
Returns true if product supports multiple packing options

## UI Updates

### ProductCard Enhancements
1. **Price Display**: Shows crossed-out original price and discounted price
2. **Premium Indicator**: Orange badge for premium/special items
3. **Sold Quantity**: Green text showing items sold
4. **Multi-packing**: Blue badge for products with multiple units
5. **Discount Highlighting**: Red color for discounted prices

### Price Logic
- If `hasDiscount` = true: Show crossed-out `salePrice` and highlighted `finalPrice`
- If `hasDiscount` = false: Show normal `displayPrice`
- Colors: Blue for normal price, Red for discounted price

## Example Usage

```dart
// Check if product has discount
if (product.hasDiscount) {
  // Show discounted price UI
}

// Get display price
final price = product.displayPrice;

// Get barcode list
final barcodes = product.barcodeList;

// Check multiple packing
if (product.hasMultiplePacking) {
  final options = product.packingOptions;
}
```

## Migration Notes
- `price` field is kept for backward compatibility
- Use `displayPrice` getter for UI display
- All new fields are nullable to handle missing data gracefully
- Helper methods provide convenient access to processed data
