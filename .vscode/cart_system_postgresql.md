🗄️ โครงสร้างฐานข้อมูลระบบตระกร้า

🛒 ตาราง carts (ตระกร้าหลัก)

id (SERIAL, PRIMARY KEY) - รหัสตระกร้า
customer_id (INTEGER) - รหัสลูกค้า
status (VARCHAR(20), DEFAULT 'active') - สถานะ: active, completed, cancelled
total_amount (DECIMAL(10,2), DEFAULT 0.00) - ยอดรวม
total_items (INTEGER, DEFAULT 0) - จำนวนรายการทั้งหมด
created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - วันที่สร้าง
updated_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - วันที่อัปเดตล่าสุด


🛍️ ตาราง cart_items (สินค้าในตระกร้า)

id (SERIAL, PRIMARY KEY) - รหัสรายการ
cart_id (INTEGER, NOT NULL, FK → carts.id) - รหัสตระกร้า
ic_code (VARCHAR(50), NOT NULL) - รหัสสินค้าจาก ic_inventory
barcode (VARCHAR(255)) - บาร์โค้ด
unit_code (VARCHAR(50)) - รหัสหน่วย
quantity (DECIMAL(10,2), NOT NULL, NOT NULL) - จำนวน
unit_price (DECIMAL(10,2), NOT NULL) - ราคาต่อหน่วย
total_price (DECIMAL(10,2), NOT NULL) - ราคารวม
created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - วันที่สร้าง
updated_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - วันที่อัปเดตล่าสุด
CONSTRAINT unique_cart_ic_code UNIQUE(cart_id, ic_code, unit_code,unit_price) - ควบคุมไม่ให้มีสินค้าซ้ำในตระกร้า


📦 ตาราง orders (คำสั่งซื้อ)

id (SERIAL, PRIMARY KEY) - รหัสคำสั่งซื้อ
cart_id (INTEGER, NOT NULL, FK → carts.id) - รหัสตระกร้า
customer_id (INTEGER, NOT NULL) - รหัสลูกค้า
order_number (VARCHAR(50), UNIQUE, NOT NULL) - หมายเลขคำสั่งซื้อ
status (VARCHAR(20), DEFAULT 'pending') - สถานะ: pending, confirmed, processing, shipped, delivered, cancelled
total_amount (DECIMAL(10,2), NOT NULL) - ยอดรวม
shipping_address (TEXT) - ที่อยู่จัดส่ง
payment_method (VARCHAR(50)) - วิธีการชำระเงิน
payment_status (VARCHAR(20), DEFAULT 'pending') - สถานะการชำระเงิน: pending, paid, failed, refunded
notes (TEXT) - หมายเหตุ
ordered_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - วันที่สั่งซื้อ


📋 ตาราง order_items (รายการสินค้าในคำสั่งซื้อ)

id (SERIAL, PRIMARY KEY) - รหัสรายการ
order_id (INTEGER, NOT NULL, FK → orders.id) - รหัสคำสั่งซื้อ
ic_code (VARCHAR(50), NOT NULL) - รหัสสินค้าจาก ic_inventory
product_name (VARCHAR(255), NOT NULL) - ชื่อสินค้า
barcode (VARCHAR(255)) - บาร์โค้ด
unit_code (VARCHAR(50)) - รหัสหน่วย
quantity (DECIMAL(10,2), NOT NULL) - จำนวน
unit_price (DECIMAL(10,2), NOT NULL) - ราคาต่อหน่วย
total_price (DECIMAL(10,2), NOT NULL) - ราคารวม

