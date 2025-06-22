# 📋 คู่มือ Models ระบบตระกร้าสินค้า

## 🛒 CartModel (โมเดลตระกร้าสินค้า)
**วัตถุประสงค์:** เก็บข้อมูลตระกร้าหลักของผู้ใช้แต่ละคน

### Fields (ฟิลด์):
- **id** - รหัสตระกร้า (Primary Key)
- **userId** - รหัสผู้ใช้ (Foreign Key)
- **status** - สถานะตระกร้า (active/completed/cancelled)
- **totalAmount** - จำนวนเงินรวม
- **totalItems** - จำนวนสินค้าทั้งหมด
- **createdAt** - วันที่สร้าง
- **updatedAt** - วันที่แก้ไขล่าสุด

### CartStatus (สถานะตระกร้า):
- **active** - กำลังใช้งาน (กำลังเลือกซื้อ)
- **completed** - สั่งซื้อแล้ว
- **cancelled** - ยกเลิก

### Methods (เมธอด):
- **toOrder()** - แปลงตระกร้าเป็นคำสั่งซื้อ
- **updateTotals()** - อัพเดทยอดรวมตามสินค้าในตระกร้า

---

## 🛍️ CartItemModel (โมเดลสินค้าในตระกร้า)
**วัตถุประสงค์:** เก็บข้อมูลสินค้าแต่ละชิ้นในตระกร้า

### Fields (ฟิลด์):
- **id** - รหัสรายการสินค้าในตระกร้า (Primary Key)
- **cartId** - รหัสตระกร้า (Foreign Key)
- **productId** - รหัสสินค้า (Foreign Key)
- **barcode** - บาร์โค้ดสินค้า
- **unitCode** - รหัสหน่วยสินค้า
- **quantity** - จำนวนสินค้า
- **unitPrice** - ราคาต่อหน่วย
- **totalPrice** - ราคารวม (quantity × unitPrice)
- **addedAt** - วันที่เพิ่มเข้าตระกร้า
- **updatedAt** - วันที่แก้ไขล่าสุด

### Methods (เมธอด):
- **calculatedTotalPrice** - คำนวณราคารวม
- **updateQuantity()** - อัพเดทจำนวนสินค้า
- **toOrderItem()** - แปลงเป็น OrderItem

---

## 📦 OrderModel (โมเดลคำสั่งซื้อ)
**วัตถุประสงค์:** เก็บข้อมูลคำสั่งซื้อหลัก

### Fields (ฟิลด์):
- **id** - รหัสคำสั่งซื้อ (Primary Key)
- **cartId** - รหัสตระกร้า (Foreign Key)
- **userId** - รหัสผู้ใช้ (Foreign Key)
- **orderNumber** - หมายเลขคำสั่งซื้อ (Unique)
- **status** - สถานะคำสั่งซื้อ
- **totalAmount** - จำนวนเงินรวม
- **shippingAddress** - ที่อยู่จัดส่ง
- **paymentMethod** - วิธีการชำระเงิน
- **paymentStatus** - สถานะการชำระเงิน
- **notes** - หมายเหตุ
- **orderedAt** - วันที่สั่งซื้อ

### OrderStatus (สถานะคำสั่งซื้อ):
- **pending** - รอดำเนินการ
- **confirmed** - ยืนยันแล้ว
- **processing** - กำลังเตรียมของ
- **shipped** - จัดส่งแล้ว
- **delivered** - ส่งถึงแล้ว
- **cancelled** - ยกเลิก

### PaymentStatus (สถานะการชำระเงิน):
- **pending** - รอชำระ
- **paid** - ชำระแล้ว
- **failed** - ชำระไม่สำเร็จ
- **refunded** - คืนเงินแล้ว

---

## 📋 OrderItemModel (โมเดลสินค้าในคำสั่งซื้อ)
**วัตถุประสงค์:** เก็บข้อมูลสินค้าแต่ละชิ้นในคำสั่งซื้อ (Snapshot)

### Fields (ฟิลด์):
- **id** - รหัสรายการสินค้าในคำสั่งซื้อ (Primary Key)
- **orderId** - รหัสคำสั่งซื้อ (Foreign Key)
- **productId** - รหัสสินค้า (Foreign Key)
- **productName** - ชื่อสินค้า (snapshot ณ เวลาสั่งซื้อ)
- **barcode** - บาร์โค้ดสินค้า (snapshot ณ เวลาสั่งซื้อ)
- **unitCode** - รหัสหน่วยสินค้า (snapshot ณ เวลาสั่งซื้อ)
- **quantity** - จำนวนสินค้า
- **unitPrice** - ราคาต่อหน่วย (snapshot ณ เวลาสั่งซื้อ)
- **totalPrice** - ราคารวม

### Methods (เมธอด):
- **calculatedTotalPrice** - คำนวณราคารวม

---

## 🔗 ความสัมพันธ์ระหว่าง Models

```
CartModel (1) ──── (N) CartItemModel
CartModel (1) ──── (1) OrderModel
OrderModel (1) ──── (N) OrderItemModel

การเชื่อมโยง:
- CartItemModel.toOrderItem() → OrderItemModel
- CartModel.toOrder() → OrderModel
```

## 🔄 กระบวนการแปลงตระกร้าเป็นคำสั่งซื้อ

1. **CartModel** สร้าง **OrderModel** ด้วย `toOrder()`
2. **CartItemModel** แต่ละตัวแปลงเป็น **OrderItemModel** ด้วย `toOrderItem()`
3. **CartModel** เปลี่ยน status เป็น `completed`
4. บันทึกข้อมูลลงฐานข้อมูล

## 📝 หมายเหตุ
- ใช้ **Equatable** สำหรับการเปรียบเทียบ objects
- มี **fromJson/toJson** สำหรับ API communication
- มี **copyWith** สำหรับการแก้ไขข้อมูล
- **Snapshot fields** ใน OrderItemModel เก็บข้อมูล ณ เวลาสั่งซื้อ
- **barcode** และ **unitCode** เก็บทั้งใน Cart และ Order เพื่อความสมบูรณ์
- มี **helper methods** สำหรับแปลงข้อมูลระหว่าง Cart ↔ Order
