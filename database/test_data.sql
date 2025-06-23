-- ========================================
-- 🧪 ข้อมูลทดสอบสำหรับระบบตระกร้า
-- ========================================

-- ลบข้อมูลเก่า
DELETE FROM cart_items;
DELETE FROM carts;

-- สร้างตระกร้าทดสอบ
INSERT INTO carts (customer_id, status, total_amount, total_items) VALUES
(1, 'active', 150.00, 3),
(2, 'active', 75.50, 2),
(3, 'completed', 200.00, 5);

-- เพิ่มสินค้าในตระกร้า customer_id = 1
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES
(1, 'IC001', 'BAR001', 'PCS', 2, 25.00, 50.00),
(1, 'IC002', 'BAR002', 'PCS', 1, 100.00, 100.00);

-- เพิ่มสินค้าในตระกร้า customer_id = 2
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES
(2, 'IC003', 'BAR003', 'PCS', 3, 15.50, 46.50),
(2, 'IC004', 'BAR004', 'PCS', 1, 29.00, 29.00);

-- เพิ่มสินค้าในตระกร้า customer_id = 3 (completed cart - ไม่ควรแสดง)
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES
(3, 'IC005', 'BAR005', 'PCS', 5, 40.00, 200.00);

-- ✅ ทดสอบ Query ที่ใช้ใน getCartItems
SELECT ci.*
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
WHERE c.customer_id = 1 AND c.status = 'active'
ORDER BY ci.created_at DESC;

-- ✅ ตรวจสอบข้อมูลทั้งหมด
SELECT 
    c.customer_id,
    c.status as cart_status,
    ci.ic_code,
    ci.quantity,
    ci.unit_price,
    ci.total_price
FROM carts c
LEFT JOIN cart_items ci ON c.id = ci.cart_id
ORDER BY c.customer_id, ci.created_at;
