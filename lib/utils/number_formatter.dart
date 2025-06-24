import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.##');
  static final NumberFormat _integerFormat = NumberFormat('#,##0');

  /// Format currency with comma separator and remove .00 for whole numbers
  /// Example: 1000.00 → ฿1,000, 25500.50 → ฿25,500.50
  static String formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      // If it's a whole number, format as integer
      return '฿${_integerFormat.format(amount.round())}';
    } else {
      // If it has decimal places, format with decimals
      return '฿${_currencyFormat.format(amount)}';
    }
  }

  /// Format quantity with comma separator
  /// Example: 1.0 → 1, 1000.0 → 1,000, 25500.5 → 25,500.5
  static String formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      // If it's a whole number, format as integer
      return _integerFormat.format(quantity.round());
    } else {
      // If it has decimal places, format with decimals
      return _currencyFormat.format(quantity);
    }
  }

  /// Format price without currency symbol
  /// Example: 1000.00 → 1,000, 25500.50 → 25,500.50
  static String formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return _integerFormat.format(price.round());
    } else {
      return _currencyFormat.format(price);
    }
  }
}
