# 🗃️ Database Setup for SML Market

This directory contains SQL scripts for setting up the SML Market database with cart and order management system.

## 📁 Files

### Main Scripts
- `recreate_cart_system.sql` - **ใหม่!** สร้างระบบตะกร้าและออเดอร์ใหม่ทั้งหมด
- `test_data_cart_system.sql` - **ใหม่!** ข้อมูลทดสอบสำหรับระบบตะกร้า
- `setup_cart_system.bat` - **ใหม่!** Script รันอัตโนมัติบน Windows

### Legacy Files
- `cart_system_postgresql.sql` - Schema เดิม (สำหรับอ้างอิง)
- `test_data.sql` - ข้อมูลทดสอบเดิม
- `setup_test_data.sh` - Script เดิมสำหรับ Linux/Mac

## 🚀 Quick Setup (แนะนำ)

### สำหรับ Windows:
```cmd
cd database
setup_cart_system.bat
```

### สำหรับ Linux/Mac:
```bash
cd database
psql -h localhost -d smlmarket -U postgres -f recreate_cart_system.sql
psql -h localhost -d smlmarket -U postgres -f test_data_cart_system.sql
```

## 📊 Database Schema ใหม่

### 🛒 ตาราง carts (ตะกร้าหลัก)
- `id` - รหัสตะกร้า (Primary Key)
- `customer_id` - รหัสลูกค้า
- `status` - สถานะ (active, completed, cancelled)
- `total_amount` - ยอดรวม (อัปเดตอัตโนมัติ)
- `total_items` - จำนวนรายการ (อัปเดตอัตโนมัติ)
- `created_at`, `updated_at` - วันที่

### 🛍️ ตาราง cart_items (สินค้าในตะกร้า)
- `id` - รหัสรายการ (Primary Key)
- `cart_id` - รหัสตะกร้า (Foreign Key)
- `ic_code` - รหัสสินค้าจาก ic_inventory
- `barcode`, `unit_code` - ข้อมูลสินค้า
- `quantity`, `unit_price`, `total_price` - ข้อมูลราคา
- Unique constraint: ไม่ให้มีสินค้าซ้ำในตะกร้า

### 📦 ตาราง orders (คำสั่งซื้อ)
- `id` - รหัสออเดอร์ (Primary Key)
- `cart_id` - รหัสตะกร้าที่สร้างออเดอร์
- `customer_id` - รหัสลูกค้า
- `order_number` - หมายเลขออเดอร์ (Unique)
- `status` - สถานะออเดอร์
- `payment_status` - สถานะการชำระเงิน
- ข้อมูลจัดส่งและการชำระเงิน

### 📋 ตาราง order_items (สินค้าในออเดอร์)
- `id` - รหัสรายการ (Primary Key)
- `order_id` - รหัสออเดอร์ (Foreign Key)
- ข้อมูลสินค้าและราคา (copy จาก cart_items)

## 🔧 Features ใหม่

### Auto-Update Triggers
- อัปเดต `updated_at` อัตโนมัติเมื่อมีการแก้ไข
- อัปเดต `total_amount` และ `total_items` ในตะกร้าอัตโนมัติ

### Functions
- `update_cart_totals(cart_id)` - อัปเดตยอดรวมในตะกร้า
- Trigger functions สำหรับอัปเดตอัตโนมัติ

### Indexes
- เพิ่ม indexes สำหรับประสิทธิภาพ
- Index บน customer_id, status, cart_id

### Data Validation
- CHECK constraints สำหรับข้อมูลที่ถูกต้อง
- Foreign Key constraints สำหรับความสมบูรณ์ของข้อมูล

## 🧪 Test Data

หลังจากรัน script แล้วจะมีข้อมูลทดสอบ:
- ลูกค้า ID 1: ตะกร้า active มี 3 รายการ (รวม ฿11,780)
- ลูกค้า ID 2: ตะกร้า active ว่าง
- ออเดอร์ตัวอย่าง 1 รายการ (delivered)

## ⚡ การใช้งานกับ Flutter App

ระบบนี้ถูกออกแบบให้ทำงานกับ:
- `CartRemoteDataSource` ใน Flutter app
- API endpoints: `/pgselect`, `/pgcommand`
- SQL queries ที่ระบุใน app

## 🔍 การตรวจสอบ

```sql
-- ดูตะกร้าทั้งหมด
SELECT * FROM carts ORDER BY id;

-- ดูสินค้าในตะกร้า
SELECT c.customer_id, ci.* 
FROM cart_items ci 
JOIN carts c ON ci.cart_id = c.id 
ORDER BY ci.cart_id;

-- ดูออเดอร์
SELECT * FROM orders ORDER BY id;
```

## ⚠️ หมายเหตุ

- Script จะลบตารางเก่าและสร้างใหม่ทั้งหมด
- ข้อมูลเก่าจะหายไป - ใช้เฉพาะใน Development
- Production ควรใช้ Migration scripts แทน
