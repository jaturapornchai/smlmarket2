import 'package:flutter/material.dart';
import 'lib/utils/service_locator.dart';
import 'lib/presentation/cubit/quotation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Initialize service locator

  // Test the quotation API
  final cubit = sl<QuotationCubit>();
  print('🧪 Testing quotation detail loading...');

  try {
    await cubit.loadQuotationDetails(7); // Test with quotation ID 7 from logs
    print('✅ Quotation details loaded successfully');
  } catch (e) {
    print('❌ Error loading quotation details: $e');
  }
}
