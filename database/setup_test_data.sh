#!/bin/bash

# 🧪 Script สำหรับเพิ่มข้อมูลทดสอบระบบตระกร้า

echo "🚀 Adding test data to cart system..."

# API endpoint
API_URL="https://smlgoapi.dedepos.com/v1/pgpost"

# Function to execute SQL
execute_sql() {
    local sql_query="$1"
    echo "📝 Executing: $sql_query"
    
    curl -s -X POST "$API_URL" \
         -H "Content-Type: application/json" \
         -d "{\"query\": \"$sql_query\"}" | jq .
}

# 1. ลบข้อมูลเก่า
echo "🗑️ Cleaning old data..."
execute_sql "DELETE FROM cart_items;"
execute_sql "DELETE FROM carts;"

# 2. สร้างตระกร้าทดสอบ
echo "🛒 Creating test carts..."
execute_sql "INSERT INTO carts (customer_id, status, total_amount, total_items) VALUES (1, 'active', 150.00, 3);"
execute_sql "INSERT INTO carts (customer_id, status, total_amount, total_items) VALUES (2, 'active', 75.50, 2);"

# 3. เพิ่มสินค้าในตระกร้า customer_id = 1
echo "📦 Adding cart items for customer 1..."
execute_sql "INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES (1, 'IC001', 'BAR001', 'PCS', 2, 25.00, 50.00);"
execute_sql "INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES (1, 'IC002', 'BAR002', 'PCS', 1, 100.00, 100.00);"

# 4. เพิ่มสินค้าในตระกร้า customer_id = 2
echo "📦 Adding cart items for customer 2..."
execute_sql "INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES (2, 'IC003', 'BAR003', 'PCS', 3, 15.50, 46.50);"
execute_sql "INSERT INTO cart_items (cart_id, ic_code, barcode, unit_code, quantity, unit_price, total_price) VALUES (2, 'IC004', 'BAR004', 'PCS', 1, 29.00, 29.00);"

# 5. ตรวจสอบข้อมูล
echo "✅ Verifying data..."
echo "🔍 Checking cart items for customer 1:"
execute_sql "SELECT ci.* FROM cart_items ci JOIN carts c ON ci.cart_id = c.id WHERE c.customer_id = 1 AND c.status = 'active' ORDER BY ci.created_at DESC;"

echo "🔍 Checking all data:"
execute_sql "SELECT c.customer_id, c.status as cart_status, ci.ic_code, ci.quantity, ci.unit_price, ci.total_price FROM carts c LEFT JOIN cart_items ci ON c.id = ci.cart_id ORDER BY c.customer_id, ci.created_at;"

echo "✅ Test data setup complete!"
