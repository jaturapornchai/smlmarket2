# Database Management Scripts

สคริปต์สำหรับจัดการฐานข้อมูล SML Market B2B System

## 📋 รายการไฟล์

### 1. การลบตารางทั้งหมด (DROP TABLES - ยกเว้น Master Data)

#### `clear_all_transactional_data.sql`
- **วัตถุประสงค์**: DROP TABLE ระบบการทำงานทั้งหมด แต่คงตาราง Master ไว้
- **ตารางที่จะถูก DROP**:
  - ระบบตระกร้าสินค้า (carts, cart_items)
  - ระบบใบขอยืนยันราคา (quotations, quotation_items)
  - ระบบการเจรจาต่อรอง (quotation_negotiations, quotation_negotiation_items)
  - ระบบคำสั่งซื้อ (orders, order_items, order_payments)
  - ระบบอื่น ๆ ที่เกี่ยวข้อง
- **ตารางที่จะคงอยู่**:
  - ลูกค้า (customers)
  - สินค้า (products)
  - หมวดหมู่สินค้า (product_categories)
  - หน่วยนับ (units)
  - ผู้ใช้ (users)
  - ตาราง Master อื่น ๆ

#### `clear_all_data.bat`
- **วัตถุประสงค์**: รันไฟล์ `clear_all_transactional_data.sql` ผ่าน Command Line
- **ข้อกำหนด**: ต้องแก้ไขข้อมูลการเชื่อมต่อฐานข้อมูลในไฟล์
- **การใช้งาน**: Double-click หรือรันจาก Command Prompt
- **การยืนยัน**: พิมพ์ 'DROP' เพื่อยืนยันการลบตาราง

### 2. การสร้างโครงสร้างตารางใหม่ทั้งหมด

#### `rebuild_all_system_tables.sql`
- **วัตถุประสงค์**: สร้างตารางทั้งหมดสำหรับระบบใหม่หลังจาก DROP
- **ตารางที่จะสร้าง**:
  - Cart System: carts, cart_items (พร้อม indexes และ constraints)
  - Quotation System: quotations, quotation_items
  - Negotiation System: quotation_negotiations, quotation_negotiation_items
  - Order System: orders, order_items, order_payments
  - Triggers สำหรับ updated_at fields
  - Foreign key relationships ทั้งหมด

#### `rebuild_system.bat`
- **วัตถุประสงค์**: รันไฟล์ `rebuild_all_system_tables.sql` ผ่าน Command Line
- **ข้อกำหนด**: ต้องแก้ไขข้อมูลการเชื่อมต่อฐานข้อมูลในไฟล์
- **การใช้งาน**: Double-click หรือรันจาก Command Prompt
- **การยืนยัน**: พิมพ์ 'BUILD' เพื่อยืนยันการสร้างตาราง

### 3. Complete Reset พร้อมข้อมูลทดสอบ

#### `quick_reset_with_test_data.sql`
- **วัตถุประสงค์**: DROP + CREATE + INSERT ข้อมูลทดสอบในขั้นตอนเดียว
- **การทำงาน**:
  1. DROP ตารางทั้งหมด (ยกเว้น Master)
  2. CREATE ตารางใหม่พร้อม indexes และ triggers
  3. INSERT ข้อมูลทดสอบพื้นฐาน
- **ข้อมูลทดสอบที่จะเพิ่ม**:
  - ตระกร้าสินค้า 1 ใบ สำหรับลูกค้า ID 1 (มี 3 รายการสินค้า)
  - ใบขอยืนยันราคา 1 ใบ (มี 2 รายการสินค้า)

#### `quick_reset.bat`
- **วัตถุประสงค์**: รันไฟล์ `quick_reset_with_test_data.sql` ผ่าน Command Line
- **ข้อกำหนด**: ต้องแก้ไขข้อมูลการเชื่อมต่อฐานข้อมูลในไฟล์
- **การใช้งาน**: Double-click หรือรันจาก Command Prompt
- **การยืนยัน**: พิมพ์ 'YES' เพื่อยืนยันการรีเซ็ต

## 🔧 การตั้งค่าก่อนใช้งาน

### 1. แก้ไขข้อมูลการเชื่อมต่อฐานข้อมูล

ในไฟล์ `.bat` ทั้งสอง แก้ไขค่าต่อไปนี้:

```batch
set DB_HOST=localhost
set DB_PORT=5432  
set DB_NAME=smlmarket
set DB_USER=postgres
set DB_PASSWORD=your_password_here
```

### 2. ตรวจสอบ PostgreSQL

- ตรวจสอบว่า PostgreSQL ทำงานอยู่
- ตรวจสอบว่าคำสั่ง `psql` สามารถใช้งานได้จาก Command Line
- ตรวจสอบสิทธิ์การเข้าถึงฐานข้อมูล

## 🚀 วิธีการใช้งาน

### Scenario 1: ลบตารางทั้งหมดเพื่อสร้างใหม่ (แนะนำ)

```cmd
# ขั้นตอนที่ 1: ลบตารางทั้งหมด
clear_all_data.bat
# พิมพ์ 'DROP' เพื่อยืนยัน

# ขั้นตอนที่ 2: สร้างตารางใหม่
rebuild_system.bat  
# พิมพ์ 'BUILD' เพื่อยืนยัน

# ขั้นตอนที่ 3: เพิ่มข้อมูลทดสอบ (ถ้าต้องการ)
quick_reset.bat
# พิมพ์ 'YES' เพื่อยืนยัน
```

### Scenario 2: Complete Reset ในขั้นตอนเดียว

```cmd
# ทำทุกอย่างในครั้งเดียว (DROP + CREATE + INSERT)
quick_reset.bat
# พิมพ์ 'YES' เพื่อยืนยัน
```

### Scenario 3: ใช้ psql โดยตรง

```cmd
# ลบตาราง
psql -h localhost -p 5432 -U postgres -d smlmarket -f clear_all_transactional_data.sql

# สร้างตารางใหม่
psql -h localhost -p 5432 -U postgres -d smlmarket -f rebuild_all_system_tables.sql

# Complete reset
psql -h localhost -p 5432 -U postgres -d smlmarket -f quick_reset_with_test_data.sql
```

### Scenario 4: ใช้ Database Management Tool

- เปิดไฟล์ `.sql` ใน pgAdmin, DBeaver, หรือ tool อื่น ๆ
- รันสคริปต์โดยตรงตามลำดับที่ต้องการ

## ⚠️ คำเตือนและข้อควรระวัง

### 🔴 คำเตือนสำคัญ
- **สคริปต์เหล่านี้จะ DROP TABLE อย่างถาวร**
- **ข้อมูลและโครงสร้างตารางจะถูกลบทั้งหมด**
- **ไม่สามารถย้อนกลับได้หากไม่มี Backup**
- **ใช้เฉพาะในระบบ Development/Testing เท่านั้น**
- **อย่าใช้ใน Production โดยเด็ดขาด**

### 📋 ข้อควรระวัง
1. **สำรองข้อมูลก่อนรัน**: ทำ Database Backup ก่อนรันสคริปต์
2. **ตรวจสอบสิทธิ์**: ใช้ User ที่มีสิทธิ์ CREATE/DROP TABLE
3. **ตรวจสอบการเชื่อมต่อ**: ทดสอบการเชื่อมต่อฐานข้อมูลก่อน
4. **ตรวจสอบ Master Data**: ให้แน่ใจว่ามีข้อมูล customers, products อยู่
5. **รันในสภาพแวดล้อมที่ปลอดภัย**: อย่าใช้ใน Production

## 📊 ตัวอย่างผลลัพธ์

### หลังจากรัน Clear All Tables:
```
Tables remaining:
- customers: 5 records
- products: 150 records  
- product_categories: 10 records
- units: 5 records
- users: 3 records

Tables dropped:
- carts, cart_items
- quotations, quotation_items
- quotation_negotiations, quotation_negotiation_items
- orders, order_items, order_payments
```

### หลังจากรัน Rebuild System:
```
Tables created:
✓ carts (with indexes and triggers)
✓ cart_items (with foreign keys)
✓ quotations (with constraints)
✓ quotation_items
✓ quotation_negotiations
✓ quotation_negotiation_items
✓ orders, order_items, order_payments
✓ All indexes and triggers
```

### หลังจากรัน Complete Reset:
```
Final state:
- customers: 5 records
- products: 150 records
- carts: 1 record (with 3 items)
- quotations: 1 record (with 2 items)
- orders: 0 records
- All table structures rebuilt
```

## 🛠️ การแก้ไขปัญหา

### ปัญหาที่พบบ่อย:

1. **"psql command not found"**
   - เพิ่ม PostgreSQL bin directory ลงใน System PATH
   - หรือใช้ full path: `"C:\Program Files\PostgreSQL\15\bin\psql.exe"`

2. **"password authentication failed"**
   - ตรวจสอบ username/password
   - ตรวจสอบ pg_hba.conf settings

3. **"database does not exist"**
   - ตรวจสอบชื่อฐานข้อมูล
   - ตรวจสอบว่าฐานข้อมูลถูกสร้างแล้ว

4. **"permission denied"**
   - ตรวจสอบสิทธิ์ User ในฐานข้อมูล
   - ใช้ User ที่มีสิทธิ์ DELETE/INSERT

## 📝 บันทึกการเปลี่ยนแปลง

### Version 1.0 (25 มิถุนายน 2025)
- สร้างสคริปต์ลบข้อมูลทั้งหมดยกเว้น Master Data
- สร้างสคริปต์ Quick Reset พร้อมข้อมูลทดสอบ
- สร้างไฟล์ .bat สำหรับรันสคริปต์ผ่าน Command Line
- เพิ่มการรีเซ็ต Auto Increment IDs
- เพิ่มการตรวจสอบและแสดงผลลัพธ์

## 🔗 ไฟล์ที่เกี่ยวข้อง

- `setup_cart_system.bat` - สำหรับสร้างระบบตระกร้าใหม่
- `test_data_cart_system.sql` - ข้อมูลทดสอบสำหรับระบบตระกร้า
- `recreate_cart_system.sql` - สร้างตารางระบบตระกร้าใหม่
- `order_system.sql` - สร้างระบบคำสั่งซื้อ
- `quotation_system.sql` - สร้างระบบใบขอยืนยันราคา
- `user_customer_system.sql` - สร้างระบบผู้ใช้และลูกค้า
