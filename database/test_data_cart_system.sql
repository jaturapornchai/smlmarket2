-- =================================================================
-- 🧪 ข้อมูลทดสอบสำหรับระบบตระกร้าและออเดอร์
-- =================================================================

-- ล้างข้อมูลเก่า (ถ้ามี)
TRUNCATE TABLE order_items, orders, cart_items, carts RESTART IDENTITY CASCADE;

-- =================================================================
-- 📝 สร้างข้อมูลตระกร้าทดสอบ
-- =================================================================

-- ตระกร้าสำหรับลูกค้า ID 1 (active)
INSERT INTO carts (customer_id, status, total_amount, total_items) 
VALUES (1, 'active', 0.00, 0);

-- ตระกร้าสำหรับลูกค้า ID 2 (active)
INSERT INTO carts (customer_id, status, total_amount, total_items) 
VALUES (2, 'active', 0.00, 0);

-- ตระกร้าเก่าที่สำเร็จแล้ว (completed)
INSERT INTO carts (customer_id, status, total_amount, total_items) 
VALUES (1, 'completed', 7900.00, 3);

-- =================================================================
-- 🛍️ สร้างข้อมูลสินค้าในตระกร้าทดสอบ
-- =================================================================

-- เพิ่มสินค้าในตระกร้าของลูกค้า ID 1 (ตระกร้า ID 1)
-- สินค้า Toyota ราคา 3500
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (1, 'TOYOTA-003', NULL, 'ชุด', 1.00, 3500.00, 3500.00);

-- สินค้า Compressor ราคา 3600
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (1, 'C-TOYOTA-02', NULL, 'ลูก', 1.00, 3600.00, 3600.00);

-- สินค้า COIL ราคา 2340
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (1, 'TG446600-3470', NULL, 'ใบ', 2.00, 2340.00, 4680.00);

-- เพิ่มสินค้าในตระกร้าเก่าที่ completed (ตระกร้า ID 3)
INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (3, 'TOYOTA-003', NULL, 'ชุด', 1.00, 3500.00, 3500.00);

INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (3, 'C-TOYOTA-02', NULL, 'ลูก', 1.00, 3600.00, 3600.00);

INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price)
VALUES (3, 'JT036', NULL, 'แผ่น', 5.00, 1400.00, 7000.00);

-- =================================================================
-- 📦 สร้างข้อมูลออเดอร์ทดสอบ
-- =================================================================

-- ออเดอร์จากตระกร้า ID 3
INSERT INTO orders (
    cart_id, customer_id, order_number, status, total_amount, 
    shipping_address, payment_method, payment_status, notes
) VALUES (
    3, 1, 'ORD2025062401', 'delivered', 14100.00,
    '123 ถนนสุขุมวิท กรุงเทพฯ 10110', 'credit_card', 'paid',
    'ออเดอร์ทดสอบระบบ - จัดส่งเรียบร้อยแล้ว'
);

-- รายการสินค้าในออเดอร์
INSERT INTO order_items (order_id, ic_code, product_name, barcode, unit_code, quantity, unit_price, total_price)
VALUES 
(1, 'TOYOTA-003', 'COIL COMMUTER 2019 หลัง พร้อมเปลือก แท้', NULL, 'ชุด', 1.00, 3500.00, 3500.00),
(1, 'C-TOYOTA-02', 'COMPRESSOR 10PA15C TIGER ใหม่ JJ ร่องเดี่ยว', NULL, 'ลูก', 1.00, 3600.00, 3600.00),
(1, 'JT036', 'แผง JT TOYOTA REVO', NULL, 'แผ่น', 5.00, 1400.00, 7000.00);

-- ออเดอร์ใหม่ที่ pending
INSERT INTO orders (
    cart_id, customer_id, order_number, status, total_amount, 
    payment_method, payment_status, notes
) VALUES (
    1, 1, 'ORD2025062402', 'pending', 11780.00,
    'bank_transfer', 'pending',
    'รอการชำระเงิน'
);

-- =================================================================
-- 🔄 อัปเดตยอดรวมในตระกร้า (Triggers จะทำอัตโนมัติ แต่เรียกเพื่อให้แน่ใจ)
-- =================================================================

SELECT update_cart_totals(1);
SELECT update_cart_totals(2);
SELECT update_cart_totals(3);

-- =================================================================
-- 📊 ตรวจสอบข้อมูลที่สร้าง
-- =================================================================

-- แสดงตะกร้าทั้งหมด
SELECT 
    c.id,
    c.customer_id,
    c.status,
    c.total_amount,
    c.total_items,
    c.created_at,
    COUNT(ci.id) as actual_items,
    COALESCE(SUM(ci.total_price), 0) as actual_amount
FROM carts c
LEFT JOIN cart_items ci ON c.id = ci.cart_id
GROUP BY c.id, c.customer_id, c.status, c.total_amount, c.total_items, c.created_at
ORDER BY c.id;

-- แสดงรายการสินค้าในตะกร้า
SELECT 
    ci.id,
    ci.cart_id,
    c.customer_id,
    ci.ic_code,
    ci.quantity,
    ci.unit_price,
    ci.total_price,
    ci.unit_code
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
ORDER BY ci.cart_id, ci.id;

-- แสดงออเดอร์ทั้งหมด
SELECT 
    o.id,
    o.order_number,
    o.customer_id,
    o.status,
    o.total_amount,
    o.payment_status,
    o.ordered_at,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, o.customer_id, o.status, o.total_amount, o.payment_status, o.ordered_at
ORDER BY o.id;

-- =================================================================
-- ✅ ข้อมูลทดสอบถูกสร้างเรียบร้อยแล้ว!
-- =================================================================

SELECT 
    'Test data created successfully!' as result,
    (SELECT COUNT(*) FROM carts) as total_carts,
    (SELECT COUNT(*) FROM cart_items) as total_cart_items,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM order_items) as total_order_items;
