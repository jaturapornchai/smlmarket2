-- =================================================================
-- 🧾 ระบบการจัดการใบขอยืนยันราคาและขอยืนยันจำนวน (Quotation System)
-- =================================================================

-- =================================================================
-- 📋 สร้างตาราง quotations (ใบขอยืนยันราคาและขอยืนยันจำนวนหลัก)
-- =================================================================

CREATE TABLE IF NOT EXISTS quotations (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    quotation_number VARCHAR(50) UNIQUE NOT NULL, -- เลขที่ใบขอยืนยัน เช่น QU-2025-000001
    status VARCHAR(30) DEFAULT 'pending' NOT NULL,
    -- Status: pending (รอการยืนยัน), confirmed (ยืนยันแล้ว), cancelled (ยกเลิก), 
    --         negotiating (กำลังต่อรอง), completed (สำเร็จ)
    total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    total_items DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    original_total_amount DECIMAL(10,2) DEFAULT 0.00 NOT NULL, -- ราคาเดิมจากตะกร้า
    notes TEXT, -- หมายเหตุจากลูกค้า
    seller_notes TEXT, -- หมายเหตุจากผู้ขาย
    expires_at TIMESTAMP, -- วันหมดอายุของใบขอยืนยัน
    confirmed_at TIMESTAMP, -- วันที่ยืนยัน
    cancelled_at TIMESTAMP, -- วันที่ยกเลิก
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_quotations_cart FOREIGN KEY (cart_id) REFERENCES carts(id),
    
    -- Constraints
    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'negotiating', 'completed'))
);

-- Index สำหรับการค้นหา
CREATE INDEX idx_quotations_customer_id ON quotations(customer_id);
CREATE INDEX idx_quotations_status ON quotations(status);
CREATE INDEX idx_quotations_quotation_number ON quotations(quotation_number);
CREATE INDEX idx_quotations_created_at ON quotations(created_at);

-- =================================================================
-- 📝 สร้างตาราง quotation_items (รายการสินค้าในใบขอยืนยัน)
-- =================================================================

CREATE TABLE IF NOT EXISTS quotation_items (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER NOT NULL,
    ic_code VARCHAR(50) NOT NULL,
    barcode VARCHAR(255),
    unit_code VARCHAR(50),
    
    -- ข้อมูลเดิมจากตะกร้า
    original_quantity DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    original_unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    original_total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    -- ข้อมูลที่ลูกค้าขอ
    requested_quantity DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    requested_unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    requested_total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    -- ข้อมูลที่ผู้ขายเสนอ (ในกรณีต่อรอง)
    offered_quantity DECIMAL(10,2),
    offered_unit_price DECIMAL(10,2),
    offered_total_price DECIMAL(10,2),
    
    -- ข้อมูลสุดท้ายที่ตกลงกัน
    final_quantity DECIMAL(10,2),
    final_unit_price DECIMAL(10,2),
    final_total_price DECIMAL(10,2),
    
    status VARCHAR(20) DEFAULT 'active' NOT NULL, -- active, cancelled
    item_notes TEXT, -- หมายเหตุสำหรับรายการนี้
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_quotation_items_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE,
    
    -- Constraints
    CHECK (status IN ('active', 'cancelled')),
    CHECK (original_quantity > 0),
    CHECK (requested_quantity >= 0),
    CHECK (original_unit_price >= 0),
    CHECK (requested_unit_price >= 0)
);

-- Index สำหรับการค้นหา
CREATE INDEX idx_quotation_items_quotation_id ON quotation_items(quotation_id);
CREATE INDEX idx_quotation_items_ic_code ON quotation_items(ic_code);
CREATE INDEX idx_quotation_items_status ON quotation_items(status);

-- =================================================================
-- 📞 สร้างตาราง quotation_negotiations (ประวัติการต่อรอง)
-- =================================================================

CREATE TABLE IF NOT EXISTS quotation_negotiations (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER NOT NULL,
    quotation_item_id INTEGER, -- NULL หมายถึงต่อรองใบทั้งใบ
    negotiation_type VARCHAR(20) NOT NULL, -- 'price', 'quantity', 'both', 'note'
    
    -- ข้อมูลการต่อรอง
    from_role VARCHAR(20) NOT NULL, -- 'customer', 'seller'
    to_role VARCHAR(20) NOT NULL, -- 'customer', 'seller'
    
    -- ข้อมูลที่เสนอ
    proposed_quantity DECIMAL(10,2),
    proposed_unit_price DECIMAL(10,2),
    proposed_total_price DECIMAL(10,2),
    message TEXT, -- ข้อความแนบ
    
    status VARCHAR(20) DEFAULT 'pending' NOT NULL, -- pending, accepted, rejected, countered
    responded_at TIMESTAMP, -- วันที่ตอบกลับ
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_negotiations_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE,
    CONSTRAINT fk_negotiations_item FOREIGN KEY (quotation_item_id) REFERENCES quotation_items(id) ON DELETE CASCADE,
    
    -- Constraints
    CHECK (negotiation_type IN ('price', 'quantity', 'both', 'note')),
    CHECK (from_role IN ('customer', 'seller')),
    CHECK (to_role IN ('customer', 'seller')),
    CHECK (status IN ('pending', 'accepted', 'rejected', 'countered'))
);

-- Index สำหรับการค้นหา
CREATE INDEX idx_negotiations_quotation_id ON quotation_negotiations(quotation_id);
CREATE INDEX idx_negotiations_item_id ON quotation_negotiations(quotation_item_id);
CREATE INDEX idx_negotiations_status ON quotation_negotiations(status);
CREATE INDEX idx_negotiations_created_at ON quotation_negotiations(created_at);

-- =================================================================
-- 🔄 สร้าง Triggers สำหรับ updated_at
-- =================================================================

-- Trigger สำหรับ quotations
CREATE TRIGGER update_quotations_updated_at 
    BEFORE UPDATE ON quotations 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger สำหรับ quotation_items
CREATE TRIGGER update_quotation_items_updated_at 
    BEFORE UPDATE ON quotation_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =================================================================
-- 🔧 สร้าง Functions สำหรับการจัดการใบขอยืนยัน
-- =================================================================

-- Function สำหรับสร้างเลขที่ใบขอยืนยัน
CREATE OR REPLACE FUNCTION generate_quotation_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    current_year VARCHAR(4);
    sequence_num INTEGER;
    quotation_number VARCHAR(50);
BEGIN
    -- ได้ปีปัจจุบัน
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;
    
    -- หาลำดับถัดไป
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(quotation_number FROM 'QU-' || current_year || '-(\d+)')
            AS INTEGER
        )
    ), 0) + 1
    INTO sequence_num
    FROM quotations
    WHERE quotation_number LIKE 'QU-' || current_year || '-%';
    
    -- สร้างเลขที่ใบขอยืนยัน
    quotation_number := 'QU-' || current_year || '-' || LPAD(sequence_num::VARCHAR, 6, '0');
    
    RETURN quotation_number;
END;
$$ LANGUAGE plpgsql;

-- Function สำหรับอัปเดตยอดรวมในใบขอยืนยัน
CREATE OR REPLACE FUNCTION update_quotation_totals(quotation_id_param INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE quotations 
    SET 
        total_amount = (
            SELECT COALESCE(SUM(
                CASE 
                    WHEN final_total_price IS NOT NULL THEN final_total_price
                    WHEN offered_total_price IS NOT NULL THEN offered_total_price
                    ELSE requested_total_price
                END
            ), 0) 
            FROM quotation_items 
            WHERE quotation_id = quotation_id_param AND status = 'active'
        ),
        total_items = (
            SELECT COALESCE(SUM(
                CASE 
                    WHEN final_quantity IS NOT NULL THEN final_quantity
                    WHEN offered_quantity IS NOT NULL THEN offered_quantity
                    ELSE requested_quantity
                END
            ), 0) 
            FROM quotation_items 
            WHERE quotation_id = quotation_id_param AND status = 'active'
        )
    WHERE id = quotation_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function Trigger สำหรับอัปเดตยอดรวมอัตโนมัติ
CREATE OR REPLACE FUNCTION trigger_update_quotation_totals()
RETURNS TRIGGER AS $$
BEGIN
    -- อัปเดตยอดรวมในใบขอยืนยัน
    PERFORM update_quotation_totals(NEW.quotation_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- สร้าง Trigger สำหรับอัปเดตยอดรวมอัตโนมัติ
CREATE TRIGGER trigger_quotation_items_update_totals
    AFTER INSERT OR UPDATE OR DELETE ON quotation_items
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_quotation_totals();

-- =================================================================
-- 💬 Comments สำหรับ Documentation
-- =================================================================

COMMENT ON TABLE quotations IS 'ตารางใบขอยืนยันราคาและขอยืนยันจำนวนหลัก';
COMMENT ON COLUMN quotations.quotation_number IS 'เลขที่ใบขอยืนยัน รูปแบบ QU-YYYY-XXXXXX';
COMMENT ON COLUMN quotations.status IS 'สถานะ: pending, confirmed, cancelled, negotiating, completed';
COMMENT ON COLUMN quotations.original_total_amount IS 'ราคารวมเดิมจากตะกร้า';
COMMENT ON COLUMN quotations.expires_at IS 'วันหมดอายุของใบขอยืนยัน';

COMMENT ON TABLE quotation_items IS 'ตารางรายการสินค้าในใบขอยืนยัน';
COMMENT ON COLUMN quotation_items.original_quantity IS 'จำนวนเดิมจากตะกร้า';
COMMENT ON COLUMN quotation_items.requested_quantity IS 'จำนวนที่ลูกค้าขอ';
COMMENT ON COLUMN quotation_items.offered_quantity IS 'จำนวนที่ผู้ขายเสนอ';
COMMENT ON COLUMN quotation_items.final_quantity IS 'จำนวนสุดท้ายที่ตกลงกัน';

COMMENT ON TABLE quotation_negotiations IS 'ตารางประวัติการต่อรองราคาและจำนวน';
COMMENT ON COLUMN quotation_negotiations.negotiation_type IS 'ประเภทการต่อรอง: price, quantity, both, note';
COMMENT ON COLUMN quotation_negotiations.from_role IS 'ผู้เสนอ: customer, seller';
COMMENT ON COLUMN quotation_negotiations.to_role IS 'ผู้รับข้อเสนอ: customer, seller';
