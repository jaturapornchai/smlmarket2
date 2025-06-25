# Flutter Development Guide for AI / คู่มือการพัฒนา Flutter สำหรับ AI

## Overview / ภาพรวม

This guide provides standards and rules for developing Flutter applications with AI assistance.
คู่มือนี้กำหนดมาตรฐานและกฎสำหรับการพัฒนาแอปพลิเคชัน Flutter ด้วยความช่วยเหลือจาก AI

## Technology Stack / เทคโนโลยีที่ใช้

- Flutter SDK (latest version) / Flutter SDK (เวอร์ชันล่าสุด)
- Dart (latest version) / Dart (เวอร์ชันล่าสุด)
- Navigator 2.0 for routing / Navigator 2.0 สำหรับ routing
- Cubit for state management / Cubit สำหรับจัดการ state
- Dio for HTTP requests / Dio สำหรับ HTTP requests
- Material Design for UI / Material Design สำหรับ UI
- Target platforms: Web (primary), Android, iOS, Windows / แพลตฟอร์มเป้าหมาย: Web (หลัก), Android, iOS, Windows
- Development: Debug on Windows/macOS for speed / พัฒนา: Debug บน Windows/macOS เพื่อความเร็ว

## Language Standards / มาตรฐานภาษา

- Primary communication in Thai / สื่อสารเป็นภาษาไทยเป็นหลัก
- Use English for technical terms that cannot be translated / ใช้ภาษาอังกฤษสำหรับคำสั่งที่ไม่สามารถแปลได้

## Development Standards / มาตรฐานการพัฒนา

### Required Practices / สิ่งที่ต้องทำ

1. Folder structure by screen / แยก folder ตามหน้าจอ
2. Separate data sources / แยก data source ออกจากกัน
3. Single responsibility principle for files / แบ่งไฟล์ตามความรับผิดชอบเดียว
4. Write concise code / เขียนโค้ดให้สั้นกระชับ
5. Create separate files to prevent code damage / สร้างไฟล์แยกเพื่อป้องกันความเสียหายของโค้ด
6. Use meaningful names / ใช้ชื่อที่มีความหมายและสื่อถึงการทำงาน
7. Remove unnecessary files / ลบไฟล์ที่ไม่จำเป็นออกจากโปรเจกต์
8. Search for solutions on Google, Stack Overflow, Discord, GitHub when needed / ค้นหาข้อมูลจาก Google, Stack Overflow, Discord, GitHub เมื่อจำเป็น
9. Format numbers with comma separator for amounts and quantities / ใส่ comma คั่นหลักพันสำหรับจำนวนเงินและปริมาณ
10. Display whole numbers without .00 decimal / แสดงจำนวนเต็มโดยไม่ต้องมี .00
11. **Prevent GitHub Copilot from editing files in the .vscode folder** / ห้ามให้ GitHub Copilot แก้ไขไฟล์ในโฟลเดอร์ .vscode
ถ้าต้องสร้างไฟล์ทดสอบใหม่ ให้สร้างในโฟลเดอร์ /test เท่านั้น
ใช้ json_serializable ในการจัดการ JSON serialization

### Prohibited Practices / สิ่งที่ห้ามทำ

1. Do not use Bloc (use Cubit instead) / ห้ามใช้ Bloc (ใช้ Cubit แทน)
2. Do not use setState for complex state / ห้ามใช้ setState สำหรับ state ที่ซับซ้อน
3. Do not modify database structure or queries / ห้ามแก้โครงสร้างฐานข้อมูลหรือ query
4. Do not connect to database directly / ห้ามเชื่อมต่อฐานข้อมูลโดยตรง
5. Do not mock data (use real API only) / ห้าม mock up ข้อมูล (ใช้ API จริงเท่านั้น)
6. Do not use unnecessary packages / ห้ามใช้ package ที่ไม่จำเป็น
7. Do not add excessive comments or explanations / ไม่ต้องมีหมายเหตุหรืออธิบายโค้ดมากเกินความจำเป็น
8. Do not auto-upload code to GitHub / ไม่ต้อง upload code ขึ้น GitHub อัตโนมัติ
9. Do not use Navigation or Tab (work like Web App) / ไม่ต้องใช้ Navigation และ Tab (ทำงานเหมือน Web App)

## API Configuration / การตั้งค่า API

All operations must go through API using Dio for HTTP requests.
ทุกการทำงานต้องผ่าน API โดยใช้ Dio สำหรับ HTTP requests

### Endpoints / จุดเชื่อมต่อ

- PostgreSQL Select: https://smlgoapi.dedepos.com/v1/pgselect / ดึงข้อมูล PostgreSQL
- PostgreSQL Command: https://smlgoapi.dedepos.com/v1/pgcommand / ส่งคำสั่ง PostgreSQL
- ClickHouse Command: https://smlgoapi.dedepos.com/v1/command / ส่งคำสั่ง ClickHouse
- Product Search: https://smlgoapi.dedepos.com/v1/search / ค้นหาข้อมูลสินค้า

## State Management Architecture / สถาปัตยกรรมการจัดการ State

### State Management Libraries / ไลบรารีจัดการ State

- Cubit: For screen state management / สำหรับจัดการ state ของแต่ละหน้าจอ
- Flutter Bloc: For cart state management / สำหรับจัดการ state ของตระกร้า
- Provider/Riverpod: For app state management / สำหรับจัดการ state ของแอป
- GetIt: For dependency injection / สำหรับ dependency injection

### UI Component Rules / กฎการใช้ UI Component

- Use Wrap instead of GridView for widgets with unequal sizes / ใช้ Wrap แทน GridView สำหรับ widget ที่มีขนาดไม่เท่ากัน
- Calculate product box sizes to fit screen properly / คำนวณขนาดกล่องสินค้าให้พอดีกับหน้าจอ

## Dependencies Management / การจัดการ Dependencies

Use pub.dev for package management / ใช้ pub.dev ในการจัดการ dependencies:
- dependencies: Runtime libraries / libraries ที่ใช้ใน runtime
- dev_dependencies: Development libraries / libraries ที่ใช้ในระหว่างการพัฒนา

## Error Handling and Logging / การจัดการข้อผิดพลาดและการบันทึก

### Error Handling / การจัดการข้อผิดพลาด

1. Use try-catch for error management / ใช้ try-catch ในการจัดการข้อผิดพลาด
2. Display clear error messages to users / แสดงข้อความข้อผิดพลาดที่ชัดเจนต่อผู้ใช้
3. Log important errors for analysis / บันทึกข้อผิดพลาดที่สำคัญเพื่อการวิเคราะห์

### Logging / การบันทึก

- Use logger package for error logging / ใช้ logger package สำหรับบันทึกข้อผิดพลาด
- In kDebugMode, display errors using print or debugPrint / ใน kDebugMode แสดงข้อผิดพลาดด้วย print หรือ debugPrint

## UI/UX Design Principles / หลักการออกแบบ UI/UX

### Design Standards / มาตรฐานการออกแบบ

1. Use Flutter Material Design / ใช้ Flutter Material Design
2. Implement responsive design for all devices / ใช้ Flutter Responsive Design เพื่อให้แอปทำงานได้ดีบนทุกอุปกรณ์
3. Add Flutter animations for better UX / ใช้ Flutter Animation เพิ่มความน่าสนใจให้กับ UI

### Number Formatting / การจัดรูปแบบตัวเลข

1. Add comma separator for money amounts and stock quantities / ใส่ comma คั่นหลักพันสำหรับจำนวนเงินและยอดคงเหลือ
2. Remove decimal .00 and show as integer / ถ้าเป็น .00 ให้แสดงเป็นจำนวนเต็มแทน
3. Examples / ตัวอย่าง:
   - 1000.00 → 1,000
   - 25500.50 → 25,500.50
   - 100000.00 → 100,000

### Cart Icon Requirements / ข้อกำหนด Icon ตระกร้า

- Always show badge with item count / Icon ตระกร้ามี Badge แสดงจำนวนสินค้าเสมอ
- Update on every cart change / อัพเดททุกครั้งที่มีการเปลี่ยนแปลงในตระกร้า
- Support multi-device with same account / รองรับการใช้งาน account เดียวกันหลายเครื่อง

## Application Screens / หน้าจอแอปพลิเคชัน

### Main Screens / หน้าจอหลัก

1. Home Screen - Product list with search / หน้าแรก - แสดงรายการสินค้าพร้อมการค้นหา
2. Product Screen - Product details / หน้าสินค้า - รายละเอียดสินค้า
3. Cart Screen - Cart management / หน้าตระกร้า - จัดการสินค้าในตระกร้า
4. Order History Screen - Past orders / หน้าประวัติการสั่งซื้อ - คำสั่งซื้อที่ผ่านมา
5. Profile Screen - User information / หน้าโปรไฟล์ - ข้อมูลผู้ใช้

## Screen Specifications / รายละเอียดหน้าจอ

### Home Screen / หน้าแรก

- Display product list / แสดงรายการสินค้า
- Search input field / มีช่องค้นหา
- Cart icon with badge showing item count / Icon ตระกร้าพร้อม Badge จำนวนสินค้า
- Login button / ปุ่มเข้าสู่ระบบ

### Product Search Screen / หน้าค้นหาสินค้า

#### Layout / การจัดวาง
- Use Wrap for product arrangement (prevent bottom overflow) / ใช้ Wrap ในการจัดเรียงสินค้า (ป้องกัน Bottom Overflow)
- Calculate box sizes to fit screen / คำนวณขนาดกล่องให้พอดีกับหน้าจอ

#### Search Functionality / ฟังก์ชันการค้นหา
- Text input for search / ช่องค้นหาที่สามารถพิมพ์ได้
- Search on button press or Enter key / ค้นหาเมื่อกดปุ่มค้นหาหรือกด Enter
- Infinite scroll - load more products when near bottom / เลื่อนหน้าจอลงใกล้ด้านล่างจะโหลดสินค้าเพิ่ม

#### ProductCard Design / การออกแบบ ProductCard
- Display products in attractive format / แสดงผลสินค้าในรูปแบบที่สวยงาม
- Navigate to product details on tap / เมื่อกดจะไปหน้ารายละเอียดสินค้า
- Price positioned at bottom right corner / ราคาอยู่ด้านล่างชิดขวาของกล่องเสมอ

### ProductCard Components / องค์ประกอบ ProductCard
จาก API Response: /search
- Product image (img_url) / รูปภาพสินค้า (img_url)
- Product name (no line breaks) / ชื่อสินค้า (ไม่ตัดบรรทัด)
- Product code and unit name / รหัสสินค้า และชื่อหน่วย
- Barcode (if available) / Barcode (ถ้ามี)
- Premium word / คำพิเศษ
- discount_price (if available) / ราคาลด (ถ้ามี)
- sale_price (if available) / ราคาขาย (ถ้ามี)
- Final price (if available) / ราคาสุดท้าย (ถ้ามี)
- Sold quantity / จำนวนที่ขายไปแล้ว
- Multi-packing information / ข้อมูลการบรรจุหลายชิ้น 
- Stock quantity (with comma separator) qty_available / ยอดคงเหลือ (ใส่ comma คั่นหลักพัน)
- Price (large, bold, orange color with border and shadow, comma separator, no .00) / ราคา (ตัวใหญ่ เข้ม สีส้ม มีกรอบและเงา ใส่ comma และไม่แสดง .00)
- No add to cart button / ไม่มีปุ่มเพิ่มลงตระกร้า
- Tap to view details / กดที่กล่องเพื่อดูรายละเอียด

### Product Detail Screen / หน้ารายละเอียดสินค้า

Display Information / แสดงข้อมูล:
- Product image / รูปภาพสินค้า
- Product name / ชื่อสินค้า
- Product code / รหัสสินค้า
- Stock quantity (with comma separator) / ยอดคงเหลือ (ใส่ comma คั่นหลักพัน)
- Price (large, bold, orange color with border and shadow, comma separator, no .00) / ราคา (ตัวใหญ่ เข้ม สีส้ม มีกรอบและเงา ใส่ comma และไม่แสดง .00)
- ในหน้าจอรายละเอียดสินค้า ให้มีจำนวนที่ต้องการ สามารถแก้ไขได้ สามารถกดปุ่ม + - ได้ ก่อน เพิ่มเข้าในตระกร้า

Action Buttons / ปุ่มการทำงาน:
- If not in cart: Show "Add to Cart" button / ถ้าไม่มีในตระกร้า: แสดงปุ่ม "เพิ่มลงตระกร้า"
- If in cart: Show message "This product is already in cart" / ถ้ามีในตระกร้าแล้ว: แสดงข้อความ "สินค้าตัวนี้มีอยู่ในตระกร้าแล้ว"
- Back to search button / ปุ่มกลับไปหน้าค้นหา

Important Notes / หมายเหตุสำคัญ:
- Do not show "Adding to cart" message when entering product detail screen / ไม่ต้องแสดงข้อความ "กำลังเพิ่มเข้าตระกร้า" เมื่อเข้าหน้ารายละเอียดสินค้า
- No loading states when navigating to product details / ไม่ต้องมี loading state เมื่อเข้าหน้ารายละเอียด

### Cart Screen / หน้าตระกร้า

Features / ฟังก์ชัน:
- List of cart items / แสดงรายการสินค้าในตระกร้า
- Item quantities / แสดงจำนวนสินค้า
- Delete item button / ปุ่มลบสินค้า
- Update quantity button / ปุ่มอัพเดทจำนวนสินค้า
- Clear cart button / ปุ่มล้างตระกร้า

### Order History Screen / หน้าประวัติการสั่งซื้อ

- List of past orders / รายการคำสั่งซื้อที่เคยทำ
- Order status / สถานะของคำสั่งซื้อ
- View details button / ปุ่มดูรายละเอียด

### Profile Screen / หน้าโปรไฟล์

- User personal information / ข้อมูลส่วนตัวของผู้ใช้
- Edit profile button / ปุ่มแก้ไขข้อมูลส่วนตัว

## Core Principles Summary / สรุปหลักการสำคัญ

1. Work through API only / ทำงานผ่าน API เท่านั้น
2. Use Cubit for state management / ใช้ Cubit จัดการ State
3. No Navigation/Tab usage / ไม่ใช้ Navigation/Tab
4. Work like Web App / ทำงานเหมือน Web App
5. Use real data, no mocking / ใช้ข้อมูลจริง ไม่ mock data
6. Keep code concise, separate files by responsibility / โค้ดสั้นกระชับ แยกไฟล์ตามหน้าที่
7. Use Material Design and Responsive Design / ใช้ Material Design และ Responsive Design

### File Protection Rules / กฎการป้องกันไฟล์

11. **Prevent GitHub Copilot from editing files in the .vscode folder** / ห้ามให้ GitHub Copilot แก้ไขไฟล์ในโฟลเดอร์ .vscode
12. **Do not modify existing working files without explicit permission** / ห้ามแก้ไขไฟล์ที่ทำงานได้แล้วโดยไม่ได้รับอนุญาตชัดเจน
13. **Create new files instead of modifying existing ones when adding features** / สร้างไฟล์ใหม่แทนการแก้ไขไฟล์เดิมเมื่อเพิ่มฟีเจอร์
14. **Ask before making major structural changes** / ขออนุญาตก่อนทำการเปลี่ยนแปลงโครงสร้างหลัก
15. **Backup important files before modification** / สำรองไฟล์สำคัญก่อนการแก้ไข
16. **Test thoroughly before suggesting file replacements** / ทดสอบอย่างละเอียดก่อนแนะนำการเปลี่ยนไฟล์
17. **Preserve existing functionality when updating** / รักษาฟังก์ชันเดิมไว้เมื่อทำการอัปเดต