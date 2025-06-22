# 🗄️ Database Scripts สำหรับระบบตระกร้า

## 📁 ไฟล์ในโฟลเดอร์นี้

### `cart_system_postgresql.sql`
**PostgreSQL Script สำหรับสร้างระบบตระกร้า**

## 🚀 วิธีการใช้งาน

### 1. **เปิด pgAdmin หรือ PostgreSQL Query Tool**

### 2. **Run Script**
```sql
-- Copy และ Paste โค้ดทั้งหมดจากไฟล์ cart_system_postgresql.sql
-- จากนั้น Execute
```

### 3. **ตรวจสอบผลลัพธ์**
Script จะแสดงข้อความ:
```
Cart system tables created successfully!
```

## 📊 โครงสร้างที่สร้าง

### 🗃️ **Tables (ตาราง):**
1. **`carts`** - ตระกร้าหลัก
2. **`cart_items`** - สินค้าในตระกร้า
3. **`orders`** - คำสั่งซื้อ
4. **`order_items`** - รายการสินค้าในคำสั่งซื้อ

### 📈 **Indexes (ดัชนี):**
- Primary Keys และ Foreign Keys
- Indexes สำหรับการค้นหาที่เร็ว
- Unique constraints

### ⚡ **Triggers (ทริกเกอร์):**
- Auto-update `updated_at` fields
- Data validation

### 🔧 **Functions (ฟังก์ชัน):**
- `update_cart_totals()` - อัพเดทยอดรวมตระกร้า
- `generate_order_number()` - สร้างหมายเลขคำสั่งซื้อ

### 📋 **Views (วิว):**
- `v_cart_details` - ดูตระกร้าพร้อมสินค้า
- `v_order_details` - ดูคำสั่งซื้อพร้อมรายการ

## ⚠️ คำเตือน

**Script นี้จะ DROP (ลบ) ตารางเก่าทั้งหมด!**
- `order_items`
- `cart_items` 
- `orders`
- `carts`

กรุณา **Backup ข้อมูลสำคัญ** ก่อนรัน Script

## 🔗 ความสัมพันธ์

```
carts (1) ──── (N) cart_items
carts (1) ──── (1) orders  
orders (1) ──── (N) order_items
```

## 📝 ตัวอย่างการใช้งาน

### เพิ่มสินค้าเข้าตระกร้า:
```sql
INSERT INTO cart_items (cart_id, product_id, barcode, unit_code, quantity, unit_price, total_price)
VALUES (1, 123, '1234567890', 'PCS', 2, 50.00, 100.00);

-- อัพเดทยอดรวมตระกร้า
SELECT update_cart_totals(1);
```

### สร้างคำสั่งซื้อ:
```sql
INSERT INTO orders (cart_id, user_id, order_number, total_amount)
VALUES (1, 1001, generate_order_number(), 100.00);
```

### ดูข้อมูลตระกร้า:
```sql
SELECT * FROM v_cart_details WHERE user_id = 1001;
```

### ดูข้อมูลคำสั่งซื้อ:
```sql
SELECT * FROM v_order_details WHERE user_id = 1001;
```
