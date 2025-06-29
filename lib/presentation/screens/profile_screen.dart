import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/quotation_cubit.dart';
import '../cubit/quotation_state.dart';
import '../widgets/app_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลตระกร้าและใบเสนอราคา
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartCubit>().loadCart(customerId: '1');
        context.read<QuotationCubit>().loadQuotations(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const AppNavigationBar(title: 'โปรไฟล์'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ข้อมูลผู้ใช้
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ลูกค้า SML',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'รหัสลูกค้า: 001',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'ข้อมูลติดต่อ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const ListTile(
                            leading: Icon(Icons.email, color: Colors.blue),
                            title: Text('customer@smlmarket.com'),
                            subtitle: Text('อีเมล'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const ListTile(
                            leading: Icon(Icons.phone, color: Colors.green),
                            title: Text('02-123-4567'),
                            subtitle: Text('เบอร์โทรศัพท์'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const ListTile(
                            leading: Icon(Icons.location_on, color: Colors.red),
                            title: Text(
                              '123 ถนนสีลม แขวงสีลม เขตบางรัก กรุงเทพฯ 10500',
                            ),
                            subtitle: Text('ที่อยู่'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // เมนูการตั้งค่า
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
                          title: const Text('แก้ไขข้อมูลส่วนตัว'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to edit profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ฟีเจอร์นี้กำลังพัฒนา'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: Colors.orange,
                          ),
                          title: const Text('ประวัติการสั่งซื้อ'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, '/history');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.receipt_long,
                            color: Colors.purple,
                          ),
                          title: const Text('ใบเสนอราคา'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, '/quotations');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help, color: Colors.teal),
                          title: const Text('ความช่วยเหลือ'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to help
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ฟีเจอร์นี้กำลังพัฒนา'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.grey,
                          ),
                          title: const Text('การตั้งค่า'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ฟีเจอร์นี้กำลังพัฒนา'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // สถิติการใช้งาน
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'สถิติการใช้งาน',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    BlocBuilder<CartCubit, CartState>(
                                      builder: (context, state) {
                                        final itemCount = state is CartLoaded
                                            ? state.items.length
                                            : 0;
                                        return Text(
                                          itemCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        );
                                      },
                                    ),
                                    const Text(
                                      'สินค้าในตะกร้า',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    BlocBuilder<QuotationCubit, QuotationState>(
                                      builder: (context, state) {
                                        final quotationCount =
                                            state is QuotationLoaded
                                            ? state.quotations.length
                                            : 0;
                                        return Text(
                                          quotationCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        );
                                      },
                                    ),
                                    const Text(
                                      'ใบเสนอราคา',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ปุ่มออกจากระบบ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('ออกจากระบบ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
}
