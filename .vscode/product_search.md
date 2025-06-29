# Product Search Screen Rules / กฎสำหรับหน้าจอค้นหา

## 🚫 **CRITICAL: DO NOT MODIFY THESE FILES WITHOUT EXPLICIT PERMISSION**
### ห้ามแก้ไขไฟล์เหล่านี้โดยไม่ได้รับอนุญาตชัดเจน:

- `lib/presentation/screens/product_search_screen.dart` - **WORKING PERFECTLY**
- `lib/presentation/widgets/product_grid.dart` - **INFINITE SCROLL IMPLEMENTED**
- `lib/presentation/cubit/product_search_cubit.dart` - **LOAD MORE LOGIC COMPLETE**
- `lib/presentation/cubit/product_search_state.dart` - **ALL STATES DEFINED**

## ✅ **CURRENT WORKING FEATURES / ฟีเจอร์ที่ทำงานแล้ว:**

### 🔍 **Search Functionality:**
- ✅ Real-time product search with query
- ✅ Search summary with result count
- ✅ Error handling with retry button
- ✅ Empty state with helpful message
- ✅ Welcome message on initial load

### 📱 **Infinite Scroll System:**
- ✅ Auto load more when scrolling to 90% of list
- ✅ Loading indicator during load more
- ✅ Preserves existing products when loading more
- ✅ Handles `ProductSearchLoadingMore` state properly
- ✅ Shows "แสดง X จาก Y รายการ" format
- ✅ Shows "(กำลังโหลดเพิ่ม...)" during loading

### 🎨 **UI/UX Components:**
- ✅ AppNavigationBar with cart/quotation counters
- ✅ SearchBarWidget with proper controller
- ✅ ProductGrid with responsive layout
- ✅ Loading states and error states
- ✅ Product cards with proper navigation

### 🔄 **State Management:**
- ✅ BlocBuilder for reactive UI updates
- ✅ Proper state handling for all scenarios:
  - `ProductSearchInitial` - Welcome screen
  - `ProductSearchLoading` - First search loading
  - `ProductSearchSuccess` - Results with products
  - `ProductSearchLoadingMore` - Loading additional pages
  - `ProductSearchError` - Error with retry option

## 🎯 **PERFECT IMPLEMENTATION DETAILS:**

### **Search Summary Logic:**
```dart
// ✅ PERFECT - DO NOT CHANGE
state.products.length < state.total 
  ? 'แสดง ${state.products.length} จาก ${state.total} รายการ สำหรับ "${state.query}"'
  : 'พบ ${state.total} รายการ สำหรับ "${state.query}"'
```

### **Load More State Handling:**
```dart
// ✅ PERFECT - DO NOT CHANGE
final products = state is ProductSearchSuccess 
    ? state.products 
    : (state as ProductSearchLoadingMore).currentProducts;
```

### **Navigation Integration:**
```dart
// ✅ PERFECT - DO NOT CHANGE
void _onProductTap(ProductModel product) {
  Navigator.pushNamed(
    context,
    '/product/${product.code}',
    arguments: product,
  );
}
```

## 🚨 **RULES FOR AI ASSISTANTS:**

### **1. MODIFICATION RESTRICTIONS:**
- ❌ **NEVER** modify the search screen layout
- ❌ **NEVER** change the infinite scroll logic
- ❌ **NEVER** alter the state management pattern
- ❌ **NEVER** modify the BlocBuilder implementations
- ❌ **NEVER** change the search summary format

### **2. IF CHANGES ARE REQUESTED:**
- ✅ **ASK FIRST** before making any changes
- ✅ **CREATE NEW FILES** instead of modifying existing ones
- ✅ **BACKUP** the original file before any modification
- ✅ **TEST THOROUGHLY** before suggesting replacements
- ✅ **PRESERVE** all existing functionality

### **3. WHAT YOU CAN DO:**
- ✅ Add NEW screens that use the search functionality
- ✅ Create NEW widgets that complement the search
- ✅ Add NEW features in SEPARATE files
- ✅ Suggest improvements via NEW implementations

### **4. DEPLOYMENT REQUIREMENTS:**
- ✅ Always test the search functionality before deployment
- ✅ Verify infinite scroll works properly
- ✅ Check all state transitions work correctly
- ✅ Ensure performance is not degraded

## 📊 **CURRENT PERFORMANCE METRICS:**

- **Search Response Time:** < 500ms
- **Infinite Scroll Trigger:** 90% scroll position
- **Load More Batch Size:** 50 products per request
- **Memory Usage:** Optimized with lazy loading
- **User Experience:** Seamless and responsive

## 🔒 **PROTECTION LEVEL: MAXIMUM**

This search screen is **PRODUCTION READY** and **WORKING PERFECTLY**. 
Any modifications must be:
1. **Explicitly requested** by the user
2. **Approved** before implementation  
3. **Tested thoroughly** before deployment
4. **Backwards compatible** with existing functionality

---

ProductModel ใช้สำหรับหน้าจอค้นหาสินค้า เพาะเป็นการค้นหาแบบ Vector Search ที่มีการใช้ AI ในการค้นหา
และไม่ควรแก้ไข ProductModel เดิมที่มีอยู่ในระบบ 

**Remember: If it's working, don't fix it! / ถ้าทำงานได้แล้ว อย่าไปแก้!** 🚫🔧