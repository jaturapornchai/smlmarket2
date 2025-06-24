-- =================================================================
-- 🗑️ ลบระบบตระกร้าและออเดอร์เดิม (RECREATE CART SYSTEM)
-- =================================================================

-- ลบตารางเดิม (เรียงลำดับตาม Foreign Key)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;

-- =================================================================
-- 🛒 สร้างตาราง carts (ตระกร้าหลัก)
-- =================================================================

CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    total_items DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index สำหรับการค้นหาตะกร้าของลูกค้า
CREATE INDEX idx_carts_customer_status ON carts(customer_id, status);
CREATE INDEX idx_carts_status ON carts(status);

-- =================================================================
-- 🛍️ สร้างตาราง cart_items (สินค้าในตระกร้า)
-- =================================================================

CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    ic_code VARCHAR(50) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1.00 CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    
    -- Unique constraint - ไม่ให้มีสินค้าเดียวกันซ้ำในตระกร้า
    CONSTRAINT unique_cart_item UNIQUE(cart_id, ic_code, unit_code, unit_price)
);

-- Index สำหรับประสิทธิภาพ
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_ic_code ON cart_items(ic_code);

-- =================================================================
-- 📦 สร้างตาราง orders (คำสั่งซื้อ)
-- =================================================================

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    notes TEXT,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_orders_cart FOREIGN KEY (cart_id) REFERENCES carts(id)
);

-- Index สำหรับการค้นหาออเดอร์
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_ordered_at ON orders(ordered_at);

-- =================================================================
-- 📋 สร้างตาราง order_items (รายการสินค้าในคำสั่งซื้อ)
-- =================================================================

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    ic_code VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    
    -- Foreign Key
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Index สำหรับประสิทธิภาพ
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_ic_code ON order_items(ic_code);

-- =================================================================
-- 🔄 สร้าง Triggers สำหรับ updated_at
-- =================================================================

-- Function สำหรับอัปเดต updated_at
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

-- =================================================================
-- 🔧 สร้าง Functions สำหรับการจัดการตระกร้า
-- =================================================================

-- Function สำหรับอัปเดตยอดรวมในตระกร้า
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

-- =================================================================
-- 🎯 สร้าง Triggers สำหรับอัปเดตยอดรวมอัตโนมัติ
-- =================================================================

-- Function สำหรับอัปเดตยอดรวมเมื่อมีการเปลี่ยนแปลง cart_items
CREATE OR REPLACE FUNCTION trigger_update_cart_totals()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM update_cart_totals(OLD.cart_id);
        RETURN OLD;
    ELSE
        PERFORM update_cart_totals(NEW.cart_id);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- สร้าง Triggers
CREATE TRIGGER cart_items_update_totals
    AFTER INSERT OR UPDATE OR DELETE ON cart_items
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_cart_totals();

-- =================================================================
-- 📝 Comments สำหรับ Documentation
-- =================================================================

COMMENT ON TABLE carts IS 'ตระกร้าสินค้าของลูกค้า';
COMMENT ON COLUMN carts.customer_id IS 'รหัสลูกค้า';
COMMENT ON COLUMN carts.status IS 'สถานะตระกร้า: active, completed, cancelled';
COMMENT ON COLUMN carts.total_amount IS 'ยอดรวมทั้งหมด';
COMMENT ON COLUMN carts.total_items IS 'จำนวนสินค้าทั้งหมด';

COMMENT ON TABLE cart_items IS 'รายการสินค้าในตระกร้า';
COMMENT ON COLUMN cart_items.ic_code IS 'รหัสสินค้าจาก ic_inventory';
COMMENT ON COLUMN cart_items.barcode IS 'บาร์โค้ดสินค้า';
COMMENT ON COLUMN cart_items.unit_code IS 'รหัสหน่วยสินค้า';

COMMENT ON TABLE orders IS 'คำสั่งซื้อ';
COMMENT ON COLUMN orders.order_number IS 'หมายเลขคำสั่งซื้อ (ไม่ซ้ำ)';
COMMENT ON COLUMN orders.status IS 'สถานะคำสั่งซื้อ';
COMMENT ON COLUMN orders.payment_status IS 'สถานะการชำระเงิน';

COMMENT ON TABLE order_items IS 'รายการสินค้าในคำสั่งซื้อ';

-- =================================================================
-- ✅ สำเร็จ! ระบบตระกร้าและออเดอร์ถูกสร้างขึ้นใหม่แล้ว
-- =================================================================

SELECT 'Cart system recreated successfully!' as result;
