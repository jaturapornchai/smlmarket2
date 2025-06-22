-- ========================================
-- 🗄️ PostgreSQL Script สำหรับระบบตระกร้า
-- ========================================
-- วันที่สร้าง: 2025-06-22
-- คำอธิบาย: Drop และ Create ตารางระบบตระกร้าใหม่ทั้งหมด

-- ========================================
-- 🗑️ DROP TABLES (ลบตารางเก่า)
-- ========================================

-- ลบในลำดับที่ไม่ขัดแย้งกับ Foreign Key
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS carts CASCADE;

-- ========================================
-- 🆕 CREATE TABLES (สร้างตารางใหม่)
-- ========================================

-- 🛒 ตาราง carts (ตระกร้าหลัก)
CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    total_items INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 🛍️ ตาราง cart_items (สินค้าในตระกร้า)
CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_cart_product UNIQUE(cart_id, product_id)
);

-- 📦 ตาราง orders (คำสั่งซื้อ)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL REFERENCES carts(id),
    user_id INTEGER NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    notes TEXT,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 📋 ตาราง order_items (รายการสินค้าในคำสั่งซื้อ)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

-- ========================================
-- 📊 CREATE INDEXES (สร้าง Index)
-- ========================================

-- Indexes สำหรับ carts
CREATE INDEX idx_carts_user_id ON carts(user_id);
CREATE INDEX idx_carts_status ON carts(status);
CREATE INDEX idx_carts_created_at ON carts(created_at);

-- Indexes สำหรับ cart_items
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX idx_cart_items_barcode ON cart_items(barcode);

-- Indexes สำหรับ orders
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_cart_id ON orders(cart_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_ordered_at ON orders(ordered_at);

-- Indexes สำหรับ order_items
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_barcode ON order_items(barcode);

-- ========================================
-- 🔄 CREATE TRIGGERS (สร้าง Trigger)
-- ========================================

-- Function สำหรับอัพเดท updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger สำหรับ carts
CREATE TRIGGER update_carts_updated_at 
    BEFORE UPDATE ON carts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger สำหรับ cart_items
CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON cart_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 🔢 CREATE FUNCTIONS (สร้างฟังก์ชัน)
-- ========================================

-- ฟังก์ชันสำหรับอัพเดทยอดรวมในตระกร้า
CREATE OR REPLACE FUNCTION update_cart_totals(cart_id_param INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE carts 
    SET 
        total_amount = (
            SELECT COALESCE(SUM(total_price), 0) 
            FROM cart_items 
            WHERE cart_id = cart_id_param
        ),
        total_items = (
            SELECT COALESCE(SUM(quantity), 0) 
            FROM cart_items 
            WHERE cart_id = cart_id_param
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = cart_id_param;
END;
$$ LANGUAGE plpgsql;

-- ฟังก์ชันสำหรับสร้างหมายเลขคำสั่งซื้อ
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    new_order_number VARCHAR(50);
    counter INTEGER;
BEGIN
    -- สร้างหมายเลขคำสั่งซื้อในรูปแบบ ORD-YYYYMMDD-NNNN
    SELECT COUNT(*) + 1 INTO counter 
    FROM orders 
    WHERE DATE(ordered_at) = CURRENT_DATE;
    
    new_order_number := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(counter::TEXT, 4, '0');
    
    RETURN new_order_number;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 📋 CREATE VIEWS (สร้าง View)
-- ========================================

-- View สำหรับดูตระกร้าพร้อมสินค้า
CREATE OR REPLACE VIEW v_cart_details AS
SELECT 
    c.id as cart_id,
    c.user_id,
    c.status,
    c.total_amount,
    c.total_items,
    c.created_at,
    c.updated_at,
    ci.id as item_id,
    ci.product_id,
    ci.barcode,
    ci.unit_code,
    ci.quantity,
    ci.unit_price,
    ci.total_price as item_total,
    ci.added_at
FROM carts c
LEFT JOIN cart_items ci ON c.id = ci.cart_id;

-- View สำหรับดูคำสั่งซื้อพร้อมรายการสินค้า
CREATE OR REPLACE VIEW v_order_details AS
SELECT 
    o.id as order_id,
    o.cart_id,
    o.user_id,
    o.order_number,
    o.status,
    o.total_amount,
    o.shipping_address,
    o.payment_method,
    o.payment_status,
    o.notes,
    o.ordered_at,
    oi.id as item_id,
    oi.product_id,
    oi.product_name,
    oi.barcode,
    oi.unit_code,
    oi.quantity,
    oi.unit_price,
    oi.total_price as item_total
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id;

-- ========================================
-- ✅ GRANT PERMISSIONS (สิทธิ์การใช้งาน)
-- ========================================

-- Grant permissions to common roles (ปรับตามความต้องการ)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- ========================================
-- 🎉 SCRIPT COMPLETED SUCCESSFULLY!
-- ========================================

SELECT 'Cart system tables created successfully!' as message;

-- แสดงจำนวนตารางที่สร้าง
SELECT 
    COUNT(*) as total_tables_created,
    'carts, cart_items, orders, order_items' as table_names
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('carts', 'cart_items', 'orders', 'order_items');
