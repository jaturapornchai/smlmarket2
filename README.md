# SML Market - Flutter Product Search App

แอปพลิเคชัน Flutter สมัยใหม่สำหรับการค้นหาสินค้า พร้อมฟีเจอร์ AI และการออกแบบที่ตอบสนอง

## ✨ ฟีเจอร์

- 🔍 **การค้นหาสินค้า**: ค้นหาสินค้าพร้อมผลลัพธ์แบบเรียลไทม์
- 🧠 **AI Search**: เปิด/ปิดฟังก์ชันค้นหาด้วย AI  
- 📱 **Responsive Design**: เหมาะสำหรับทุกขนาดหน้าจอ (2-6 คอลัมน์)
- 🔄 **Infinite Scroll**: เลื่อนดูต่อไปได้อย่างไม่สิ้นสุด
- 💳 **Product Cards**: การ์ดสินค้าสวยงามพร้อมข้อมูลครบถ้วน
- 🎨 **Modern UI**: ดีไซน์สะอาดด้วย Material 3 components
- 🛒 **ระบบตะกร้า**: จัดการสินค้าในตะกร้าอย่างครบถ้วน
- 📋 **ใบยืนยันราคา**: ระบบสร้างและจัดการใบยืนยันราคา
- 📊 **Wrap Layout**: ใช้พื้นที่ 100% โดยไม่มีช่องว่าง

## 🏗️ สถาปัตยกรรม

โปรเจกต์นี้ปฏิบัติตาม Flutter best practices พร้อม clean architecture:

```
lib/
├── data/
│   ├── models/          # Product และ response models  
│   ├── repositories/    # Data repositories abstraction
│   └── data_sources/    # API communication layer
├── presentation/
│   ├── screens/         # หน้าจอหลักของแอป
│   ├── widgets/         # UI components ที่ใช้ซ้ำได้
│   └── cubit/          # State management (Cubit pattern)
├── utils/              # Utilities และ helpers
└── main.dart           # จุดเริ่มต้นของแอปพลิเคชัน
```

## 🛠️ เทคโนโลยีที่ใช้

- **Flutter** - Cross-platform UI framework
- **Cubit (flutter_bloc)** - Predictable state management
- **Dio** - HTTP client สำหรับ API communication
- **Logger** - Advanced logging และ debugging
- **Equatable** - Object comparison และ state immutability
- **JSON Serializable** - Type-safe JSON serialization
- **GetIt** - Dependency injection

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^8.1.3
  dio: ^5.4.0
  equatable: ^2.0.5
  get_it: ^7.6.7
  logger: ^2.0.2+1
  intl: ^0.19.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

## 🚀 การเริ่มต้น

### ข้อกำหนดเบื้องต้น
- Flutter SDK (3.8.1 หรือสูงกว่า)
- Dart SDK  
- Android Studio / VS Code
- อุปกรณ์ Android/iOS หรือ emulator

### การติดตั้ง

1. **Clone repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smlmarket.git
   cd smlmarket
   ```

2. **ติดตั้ง dependencies**
   ```bash
   flutter pub get
   ```

3. **สร้าง JSON serialization code**
   ```bash
   dart run build_runner build
   ```

4. **รันแอป**
   ```bash
   flutter run
   ```

## 🌐 การตั้งค่า API

แอปเชื่อมต่อกับ backend API ด้วยการตั้งค่าดังนี้:

- **Base URL**: `https://smlgoapi.dedepos.com/v1`
- **PostgreSQL Select**: `POST /pgselect` - ดึงข้อมูลจาก PostgreSQL
- **PostgreSQL Command**: `POST /pgcommand` - ส่งคำสั่งไปยัง PostgreSQL  
- **Product Search**: `POST /search` - ค้นหาข้อมูลสินค้า
- **Parameters**: 
  - `query` (string): คำค้นหา
  - `ai` (integer): เปิด/ปิด AI (0/1)
  - `limit` (integer): จำนวนรายการต่อหน้า (default: 50)
  - `offset` (integer): Pagination offset

## 📱 รายละเอียดฟีเจอร์หลัก

### การค้นหาสินค้า
- **Real-time Search**: ผลลัพธ์ทันทีขณะพิมพ์
- **AI Enhancement**: เปิด/ปิดการแนะนำด้วย AI
- **Error Handling**: จัดการ error states พร้อมตัวเลือก retry

### การแสดงสินค้า  
- **Responsive Grid**: 2-6 คอลัมน์ตามขนาดหน้าจอ
- **Wrap Layout**: ใช้พื้นที่ 100% โดยไม่มีขอบข้าง
- **Dynamic Height**: การ์ดปรับขนาดตามเนื้อหา

### ข้อมูลสินค้า
- **ราคา**: ราคาปกติ, ราคาลด, และราคาสุดท้ายพร้อมส่วนลด
- **สถานะสต็อก**: แสดงจำนวนที่มีอยู่
- **ข้อมูลยอดขาย**: ข้อมูล "จำนวนที่ขายแล้ว"  
- **ส่วนลด**: จำนวนเงิน, เปอร์เซ็นต์, และข้อเสนอพิเศษ

### ระบบตะกร้า
- **จัดการสินค้า**: เพิ่ม, ลบ, แก้ไขจำนวนสินค้า
- **ตรวจสอบสต็อก**: ป้องกันการสั่งเกินจำนวนที่มี
- **คำนวณราคา**: คำนวณราคารวมอัตโนมัติ
- **แสดงจำนวน**: Badge บน icon ตะกร้าแสดงจำนวนสินค้า

### ระบบใบยืนยันราคา
- **สร้างใบยืนยัน**: สร้างใบยืนยันราคาจากตะกร้า
- **จัดการใบยืนยัน**: ดู, แก้ไข, ยกเลิกใบยืนยัน
- **การต่อรอง**: ระบบการต่อรองราคาและจำนวน
- **ติดตามสถานะ**: ติดตามสถานะของใบยืนยัน

## 🎯 รูปแบบ Product Card

การออกแบบการ์ดใหม่แสดงข้อมูลในแนวตั้ง:

1. **รูปภาพสินค้า** (ความสูงคงที่ 140px)
2. **ชื่อสินค้า** (แสดงเต็ม ไม่ตัดทอน)
3. **Premium Badge** (ถ้ามี)
4. **ข้อมูลส่วนลด** (จำนวนเงิน, เปอร์เซ็นต์, รายละเอียด)
5. **สถานะสต็อก** (ขนาดใหญ่ เด่นชัด)
6. **ราคาสุดท้าย** (ใหญ่ที่สุด อยู่ตำแหน่งล่างสุด)

## 📱 Responsive Design

### จุดแบ่งหน้าจอ
- **≤480px**: 2 คอลัมน์ (มือถือ)
- **481-768px**: 3 คอลัมน์ (มือถือใหญ่/แท็บเล็ตเล็ก)
- **769-1024px**: 4 คอลัมน์ (แท็บเล็ต)
- **1025-1200px**: 5 คอลัมน์ (เดสก์ท็อปเล็ก)
- **>1200px**: 6 คอลัมน์ (เดสก์ท็อปใหญ่)

## 🎨 หลักการออกแบบ UI/UX

### มาตรฐานการออกแบบ
- ใช้ Flutter Material Design
- Responsive design สำหรับทุกอุปกรณ์
- เพิ่ม Flutter animations เพื่อ UX ที่ดีขึ้น

### การจัดรูปแบบตัวเลข
- เพิ่ม comma คั่นหลักพันสำหรับจำนวนเงินและสต็อก
- ลบทศนิยม .00 และแสดงเป็นจำนวนเต็ม
- ตัวอย่าง:
  - 1000.00 → 1,000
  - 25500.50 → 25,500.50
  - 100000.00 → 100,000

## 🔧 การจัดการ State

### ห้องสมุดจัดการ State
- **Cubit**: สำหรับจัดการ state ของแต่ละหน้าจอ
- **Flutter Bloc**: สำหรับจัดการ state ของตะกร้า
- **GetIt**: สำหรับ dependency injection

### กฎการใช้ UI Component
- ใช้ Wrap แทน GridView สำหรับ widget ที่มีขนาดไม่เท่ากัน
- คำนวณขนาดกล่องสินค้าให้พอดีกับหน้าจอ

## 🤝 การมีส่วนร่วม

1. Fork โปรเจกต์
2. สร้าง feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit การเปลี่ยนแปลง (`git commit -m 'Add some AmazingFeature'`)
4. Push ไปยัง branch (`git push origin feature/AmazingFeature`)
5. เปิด Pull Request

## 📄 License

โปรเจกต์นี้อยู่ภายใต้ MIT License

## 👨‍💻 ทีมพัฒนา

สร้างด้วย ❤️ โดยใช้ Flutter และหลักการพัฒนาสมัยใหม่

---

**หมายเหตุ**: แอปพลิเคชันนี้ต้องการ backend API server ที่ใช้งานได้เพื่อฟังก์ชันเต็มรูปแบบ ตรวจสอบให้แน่ใจว่า API endpoint ได้รับการตั้งค่าอย่างถูกต้องก่อนทดสอบ
