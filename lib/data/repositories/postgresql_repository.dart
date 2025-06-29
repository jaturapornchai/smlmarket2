import '../models/ic_inventory_model.dart';
import '../models/ar_customer_model.dart';
import '../models/product_model.dart';
import '../services/postgresql_service.dart';

/// Repository สำหรับจัดการข้อมูลจาก PostgreSQL Database
/// ยกเว้น หน้าค้นหาสินค้าที่ยังใช้ API /search ปกติ
abstract class PostgreSQLRepository {
  // Inventory methods
  Future<List<IcInventoryModel>> getAllInventory();
  Future<IcInventoryModel?> getInventoryByCode(String code);
  Future<List<IcInventoryModel>> searchInventoryInDatabase(String searchTerm);
  Future<List<ProductModel>> convertInventoryToProducts(
    List<IcInventoryModel> inventoryList,
  );

  // Customer methods
  Future<List<ArCustomerModel>> getAllCustomers();
  Future<ArCustomerModel?> getCustomerByCode(String code);

  // Cart methods
  Future<List<Map<String, dynamic>>> getActiveCart(String customerCode);
  Future<List<Map<String, dynamic>>> getCartItems(int cartId);

  // Quotation methods
  Future<List<Map<String, dynamic>>> getCustomerQuotations(String customerCode);

  // Order methods
  Future<List<Map<String, dynamic>>> getCustomerOrders(String customerCode);
}

class PostgreSQLRepositoryImpl implements PostgreSQLRepository {
  // === INVENTORY METHODS ===

  @override
  Future<List<IcInventoryModel>> getAllInventory() async {
    try {
      return await PostgreSQLService.getAllInventory();
    } catch (e) {
      throw Exception('Failed to get all inventory: $e');
    }
  }

  @override
  Future<IcInventoryModel?> getInventoryByCode(String code) async {
    try {
      return await PostgreSQLService.getInventoryByCode(code);
    } catch (e) {
      throw Exception('Failed to get inventory by code: $e');
    }
  }

  @override
  Future<List<IcInventoryModel>> searchInventoryInDatabase(
    String searchTerm,
  ) async {
    try {
      return await PostgreSQLService.searchInventory(searchTerm);
    } catch (e) {
      throw Exception('Failed to search inventory: $e');
    }
  }

  @override
  Future<List<ProductModel>> convertInventoryToProducts(
    List<IcInventoryModel> inventoryList,
  ) async {
    try {
      return inventoryList.map((inventory) {
        final productJson = inventory.toProductJson();
        return ProductModel.fromJson(productJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to convert inventory to products: $e');
    }
  }

  // === CUSTOMER METHODS ===

  @override
  Future<List<ArCustomerModel>> getAllCustomers() async {
    try {
      return await PostgreSQLService.getAllCustomers();
    } catch (e) {
      throw Exception('Failed to get all customers: $e');
    }
  }

  @override
  Future<ArCustomerModel?> getCustomerByCode(String code) async {
    try {
      return await PostgreSQLService.getCustomerByCode(code);
    } catch (e) {
      throw Exception('Failed to get customer by code: $e');
    }
  }

  // === CART METHODS ===

  @override
  Future<List<Map<String, dynamic>>> getActiveCart(String customerCode) async {
    try {
      return await PostgreSQLService.getActiveCart(customerCode);
    } catch (e) {
      throw Exception('Failed to get active cart: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCartItems(int cartId) async {
    try {
      return await PostgreSQLService.getCartItems(cartId);
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  // === QUOTATION METHODS ===

  @override
  Future<List<Map<String, dynamic>>> getCustomerQuotations(
    String customerCode,
  ) async {
    try {
      return await PostgreSQLService.getCustomerQuotations(customerCode);
    } catch (e) {
      throw Exception('Failed to get customer quotations: $e');
    }
  }

  // === ORDER METHODS ===

  @override
  Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerCode,
  ) async {
    try {
      return await PostgreSQLService.getCustomerOrders(customerCode);
    } catch (e) {
      throw Exception('Failed to get customer orders: $e');
    }
  }
}
