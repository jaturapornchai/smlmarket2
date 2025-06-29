# 📋 กฎการจัดการจำนวนสินค้าในตะกร้า (Cart Quantity Logic Rules)

**วันที่อัพเดท**: 24 มิถุนายน 2025  
**ไฟล์หลัก**: `lib/presentation/widgets/cart_item_widget.dart`

---

## 🎯 หลักการสำคัญ: "ยอดที่สั่งเพิ่มได้" (Available to Order)

### ⚠️ **ห้ามใช้คำว่า "คงเหลือ" (Stock Left) ในการแสดงผลให้ผู้ใช้**
- ผู้ใช้จะเห็นเฉพาะ **"ยอดที่สั่งเพิ่มได้"** เท่านั้น
- คำว่า "คงเหลือ" ใช้เฉพาะใน backend logic เท่านั้น

---

## 🧮 สูตรการคำนวณ

### 1. **ยอดสูงสุดที่สั่งได้ทั้งหมด (Maximum Allowed Quantity)**
```dart
final maxAllowedQuantity = qtyAvailable + currentCartQuantity;
```

### 2. **ตรวจสอบการเพิ่มจำนวน (+1 button)**
```dart
bool _canIncrease() {
  if (widget.qtyAvailable == null) return true;
  final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
  return widget.item.quantity < maxAllowedQuantity;
}
```

### 3. **ตรวจสอบการแก้ไขจำนวน (Manual Edit)**
```dart
if (widget.qtyAvailable != null) {
  final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
  if (newQuantity > maxAllowedQuantity) {
    // แสดง error
  }
}
```

---

## 📝 ข้อความที่ต้องแสดงให้ผู้ใช้

### 1. **แสดงยอดที่สั่งเพิ่มได้ (Header Display)**
```dart
Text('ยอดที่สั่งเพิ่มได้: ${NumberFormatter.formatQuantity(widget.qtyAvailable!)} ชิ้น')
```

### 2. **Helper Text ใน Dialog แก้ไขจำนวน**
```dart
helperText: widget.qtyAvailable != null
    ? 'ยอดที่สั่งเพิ่มได้อีก: ${NumberFormatter.formatQuantity(widget.qtyAvailable!)} ชิ้น'
    : null,
```

### 3. **Error Message เมื่อเกินจำนวน**
```dart
'จำนวนเกินยอดที่สั่งเพิ่มได้อีก (สูงสุด ${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น)'
```

### 4. **Stock Limit Dialog (เมื่อกด + แล้วเกิน)**
```dart
// หัวข้อ
title: Text('ไม่สามารถเพิ่มได้')

// เนื้อหา
Column(
  children: [
    Text('สินค้าคงเหลือที่สามารถสั่งเพิ่มได้อีก:'),
    Text('${NumberFormatter.formatQuantity(widget.qtyAvailable ?? 0)} ชิ้น'),
    Text('จำนวนสูงสุดที่สั่งได้ทั้งหมด (รวมในตะกร้า):'),
    Text('${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น'),
  ],
)
```

---

## 🚫 สิ่งที่ห้ามทำ

### 1. **ห้ามใช้คำเหล่านี้ในการแสดงผลให้ผู้ใช้:**
- ❌ "คงเหลือ" (Stock Left)
- ❌ "ยอดคงเหลือ" (Remaining Stock)
- ❌ "Stock Available"

### 2. **ห้ามใช้ตรรกะเก่า:**
```dart
// ❌ ผิด - ห้ามใช้
if (newQuantity > widget.qtyAvailable) {
  // logic นี้ผิด
}

// ✅ ถูก - ใช้แบบนี้
final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
if (newQuantity > maxAllowedQuantity) {
  // logic นี้ถูก
}
```

### 3. **ห้ามมี Confirmation Dialog**
- เมื่อแก้ไขจำนวนแล้วกด "บันทึก" ให้อัพเดททันที
- ห้ามมี pending state หรือ confirmation dialog

---

## ✅ การทำงานที่ถูกต้อง

### 1. **Immediate Updates**
- การเปลี่ยนแปลงจำนวนจะมีผลทันที
- ไม่มี confirmation dialog
- ไม่มี pending state

### 2. **Real-time Stock Updates**
- ระบบจะอัพเดท stock หลังจากแก้ไขจำนวนแล้ว
- การแสดงผล "ยอดที่สั่งเพิ่มได้" จะเปลี่ยนตาม stock ที่เหลือ

### 3. **Proper Button States**
- ปุ่ม "+" จะ disable เมื่อไม่สามารถเพิ่มได้
- ปุ่ม "-" จะ disable เมื่อจำนวนเป็น 1

---

## 📚 ตัวอย่างการใช้งาน

### สถานการณ์: สินค้า A มี stock 10 ชิ้น, ในตะกร้ามี 7 ชิ้น

```
✅ แสดงให้ผู้ใช้เห็น: "ยอดที่สั่งเพิ่มได้: 3 ชิ้น"
✅ จำนวนสูงสุดที่สั่งได้: 10 ชิ้น (3 + 7)
✅ กดปุ่ม + ได้อีก 3 ครั้ง (จาก 7 → 10)
✅ แก้ไขด้วยตนเองได้สูงสุด 10 ชิ้น
```

### สถานการณ์: สินค้า B มี stock 5 ชิ้น, ในตะกร้ามี 5 ชิ้น

```
✅ แสดงให้ผู้ใช้เห็น: "ยอดที่สั่งเพิ่มได้: 0 ชิ้น"
✅ จำนวนสูงสุดที่สั่งได้: 5 ชิ้น (0 + 5)
✅ ปุ่ม + จะ disable
✅ แก้ไขด้วยตนเองได้สูงสุด 5 ชิ้น (ไม่เพิ่ม)
```

---

## 🔧 Code Functions ที่สำคัญ

### 1. **_canIncrease()**
```dart
bool _canIncrease() {
  if (widget.qtyAvailable == null) return true;
  final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
  return widget.item.quantity < maxAllowedQuantity;
}
```

### 2. **_saveQuantity()**
```dart
void _saveQuantity() {
  final newQuantity = double.tryParse(_quantityController.text.trim());
  if (newQuantity == null || newQuantity <= 0) {
    _showErrorDialog('กรุณาใส่จำนวนที่ถูกต้อง');
    return;
  }
  
  if (widget.qtyAvailable != null) {
    final maxAllowedQuantity = widget.qtyAvailable! + widget.item.quantity;
    if (newQuantity > maxAllowedQuantity) {
      _showErrorDialog(
        'จำนวนเกินยอดที่สั่งเพิ่มได้อีก (สูงสุด ${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น)',
      );
      return;
    }
  }
  
  Navigator.pop(context);
  widget.onQuantityChanged(newQuantity);
}
```

### 3. **_showStockLimitDialog()**
```dart
void _showStockLimitDialog() {
  final maxAllowedQuantity = widget.qtyAvailable != null
      ? widget.qtyAvailable! + widget.item.quantity
      : 0.0;
      
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          const Text('ไม่สามารถเพิ่มได้'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('สินค้าคงเหลือที่สามารถสั่งเพิ่มได้อีก:'),
          Text('${NumberFormatter.formatQuantity(widget.qtyAvailable ?? 0)} ชิ้น'),
          const SizedBox(height: 8),
          Text('จำนวนสูงสุดที่สั่งได้ทั้งหมด (รวมในตะกร้า):'),
          Text('${NumberFormatter.formatQuantity(maxAllowedQuantity)} ชิ้น'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ตกลง'),
        ),
      ],
    ),
  );
}
```

---

## 🧪 Test Cases ที่ต้องผ่าน

### 1. **ทดสอบ + Button**
- [ ] กดปุ่ม + เมื่อยังเพิ่มได้ → จำนวนเพิ่มขึ้น
- [ ] กดปุ่ม + เมื่อเพิ่มไม่ได้ → แสดง Stock Limit Dialog
- [ ] ปุ่ม + disable เมื่อไม่สามารถเพิ่มได้

### 2. **ทดสอบ Manual Edit**
- [ ] แก้ไขจำนวนที่อยู่ในขอบเขตที่อนุญาต → อัพเดทสำเร็จ
- [ ] แก้ไขจำนวนเกินขอบเขต → แสดง Error Dialog
- [ ] แก้ไขจำนวนเป็น 0 หรือติดลบ → แสดง Error Dialog

### 3. **ทดสอบ UI Display**
- [ ] แสดง "ยอดที่สั่งเพิ่มได้" ถูกต้อง
- [ ] แสดงสีเขียวเมื่อเพิ่มได้ / สีแดงเมื่อไม่สามารถเพิ่มได้
- [ ] Helper text ใน dialog แสดงถูกต้อง

### 4. **ทดสอบ Edge Cases**
- [ ] stock = 0, cart = 0 → ไม่สามารถเพิ่มได้
- [ ] stock = 5, cart = 5 → ไม่สามารถเพิ่มได้
- [ ] stock = 10, cart = 3 → เพิ่มได้อีก 7 ชิ้น

---

## 📋 Checklist ก่อน Deploy

### Pre-deployment Checklist:
- [ ] ทุก error message ใช้คำว่า "ยอดที่สั่งเพิ่มได้"
- [ ] ไม่มี confirmation dialog
- [ ] Logic การคำนวณใช้ `qtyAvailable + currentCartQuantity`
- [ ] ปุ่ม + disable ถูกต้อง
- [ ] Helper text แสดงถูกต้อง
- [ ] Error handling ครบถ้วน
- [ ] Test ทุก edge case ผ่าน

---

## 🔍 Debug Information

### เมื่อมีปัญหา ให้เช็ค:

1. **ค่า qtyAvailable จาก API**
   ```dart
   print('🐛 qtyAvailable: ${widget.qtyAvailable}');
   print('🐛 currentCartQuantity: ${widget.item.quantity}');
   print('🐛 maxAllowedQuantity: ${widget.qtyAvailable! + widget.item.quantity}');
   ```

2. **สถานะ UI Components**
   ```dart
   print('🐛 _canIncrease(): ${_canIncrease()}');
   print('🐛 Button enabled: ${widget.qtyAvailable != null && _canIncrease()}');
   ```

3. **การคำนวณใน Functions**
   ```dart
   // ใน _saveQuantity()
   print('🐛 newQuantity: $newQuantity');
   print('🐛 maxAllowedQuantity: $maxAllowedQuantity');
   print('🐛 isValid: ${newQuantity <= maxAllowedQuantity}');
   ```

---

## 🎯 สรุป Rules หลัก

1. **ใช้คำว่า "ยอดที่สั่งเพิ่มได้"** ในทุกการแสดงผลให้ผู้ใช้
2. **คำนวณ maxAllowed = qtyAvailable + currentCart** เสมอ
3. **อัพเดททันที ไม่มี confirmation**
4. **แสดง error ที่ชัดเจนและถูกต้อง**
5. **ทดสอบทุก edge case ก่อน deploy**

---

**⚠️ หมายเหตุ: กฎเหล่านี้เป็นมาตรฐานสำหรับการจัดการตะกร้าสินค้า ห้ามเปลี่ยนแปลงโดยไม่ได้รับอนุญาต**
