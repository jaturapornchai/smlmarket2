import 'package:flutter/material.dart';
import '../../data/models/ic_inventory_model.dart';
import '../../data/models/ar_customer_model.dart';
import '../../data/repositories/postgresql_repository.dart';

class PostgreSQLExampleWidget extends StatefulWidget {
  const PostgreSQLExampleWidget({Key? key}) : super(key: key);

  @override
  State<PostgreSQLExampleWidget> createState() =>
      _PostgreSQLExampleWidgetState();
}

class _PostgreSQLExampleWidgetState extends State<PostgreSQLExampleWidget> {
  final PostgreSQLRepository _repository = PostgreSQLRepositoryImpl();

  List<IcInventoryModel> _inventoryList = [];
  List<ArCustomerModel> _customerList = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load inventory data from PostgreSQL
      final inventory = await _repository.getAllInventory();
      final customers = await _repository.getAllCustomers();

      setState(() {
        _inventoryList = inventory;
        _customerList = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchInventory(String searchTerm) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final results = await _repository.searchInventoryInDatabase(searchTerm);
      setState(() {
        _inventoryList = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error searching: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostgreSQL Integration Demo'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Inventory',
                hintText: 'Enter search term...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _searchInventory,
            ),
          ),

          // Error Message
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.red.shade100,
              child: Text(_error, style: TextStyle(color: Colors.red.shade800)),
            ),

          // Loading Indicator
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            // Data Tabs
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Inventory'),
                        Tab(text: 'Customers'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [_buildInventoryTab(), _buildCustomerTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    if (_inventoryList.isEmpty) {
      return const Center(child: Text('No inventory items found'));
    }

    return ListView.builder(
      itemCount: _inventoryList.length,
      itemBuilder: (context, index) {
        final item = _inventoryList[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: item.imgUrl != null
                ? Image.network(
                    item.imgUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.inventory),
                  )
                : const Icon(Icons.inventory),
            title: Text(item.name ?? 'No Name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${item.code}'),
                Text('Price: ฿${item.price.toStringAsFixed(2)}'),
                Text('Available: ${item.qtyAvailable.toStringAsFixed(0)}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.isActive ? Icons.check_circle : Icons.cancel,
                  color: item.isActive ? Colors.green : Colors.red,
                ),
                Text(item.isActive ? 'Active' : 'Inactive'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerTab() {
    if (_customerList.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return ListView.builder(
      itemCount: _customerList.length,
      itemBuilder: (context, index) {
        final customer = _customerList[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('Customer: ${customer.code}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Level: ${customer.priceLevel ?? 'N/A'}'),
                Text('Order Ref: ${customer.rowOrderRef}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
