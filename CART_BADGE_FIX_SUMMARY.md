# 🛒 การแก้ไขปัญหาตะกร้าสินค้า

## ปัญหาที่แก้ไข

### 1. ❌ ปัญหา: ตัวเลข badge ทับไอคอนตระกร้า
**แก้ไข:** ปรับตำแหน่งและขนาดของ badge

#### เปลี่ยนจาก:
```dart
Positioned(
  right: 0,
  top: 0,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(10),
    ),
    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
```

#### เป็น:
```dart
Positioned(
  right: -2,        // เลื่อนออกไปข้างขวา
  top: -2,          // เลื่อนขึ้นด้านบน
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white, width: 1), // เพิ่มขอบสีขาว
    ),
    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
```

### 2. ❌ ปัญหา: ตัวเลขในตระกร้าไม่อัพเดตเมื่อกลับมาหน้าค้นหา
**แก้ไข:** เพิ่มการรีเฟรชข้อมูลตระกร้าเมื่อกลับมา

#### เปลี่ยนจาก:
```dart
void _onCartTap() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const CartScreen()),
  );
}
```

#### เป็น:
```dart
void _onCartTap() async {
  // นำทางไปยังตระกร้าและรอผลลัพธ์
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const CartScreen()),
  );
  // เมื่อกลับมาแล้ว ให้รีเฟรชข้อมูลตระกร้า
  if (mounted) {
    context.read<CartCubit>().loadCart(customerId: '1');
  }
}
```

### 3. ✅ เพิ่มการโหลดข้อมูลตระกร้าเมื่อเริ่มต้น
**เพิ่ม:** การโหลดข้อมูลตระกร้าใน `initState`

```dart
@override
void initState() {
  super.initState();
  // โหลดข้อมูลตระกร้าเมื่อเริ่มต้น
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<CartCubit>().loadCart(customerId: '1');
  });
}
```

## ผลลัพธ์

### ✅ Badge ตระกร้าใหม่:
- ตำแหน่งที่เหมาะสม (ไม่ทับไอคอน)
- มีขอบสีขาวเพื่อความชัดเจน
- ขนาดที่เหมาะสม

### ✅ การอัพเดตข้อมูล:
- ตัวเลขในตระกร้าอัพเดตทันทีเมื่อกลับมา
- ข้อมูลตระกร้าโหลดเมื่อเริ่มแอป
- ใช้ `await` เพื่อรอการนำทางเสร็จสิ้น

## การทดสอบ

1. เปิดแอป → ดูตัวเลขตระกร้า (ควรเป็น 10)
2. กดปุ่มตระกร้า → เข้าหน้าตระกร้า
3. เพิ่ม/ลบสินค้าในตระกร้า
4. กลับมาหน้าค้นหา → ตัวเลขควรอัพเดตตามข้อมูลใหม่

---

**หมายเหตุ:** การเปลี่ยนแปลงนี้ทำให้ UX ดีขึ้นและข้อมูลแสดงผลถูกต้องตลอดเวลา 🎉
