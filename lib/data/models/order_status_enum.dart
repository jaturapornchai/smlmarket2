// =================================================================
// 📋 Order Status Enums
// =================================================================

enum OrderStatus {
  pending('pending', 'รอดำเนินการ'),
  confirmed('confirmed', 'ยืนยันแล้ว'),
  processing('processing', 'กำลังเตรียมสินค้า'),
  shipped('shipped', 'จัดส่งแล้ว'),
  delivered('delivered', 'ส่งมอบแล้ว'),
  cancelled('cancelled', 'ยกเลิก'),
  refunded('refunded', 'คืนเงินแล้ว');

  const OrderStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatus.pending,
    );
  }

  // สีที่ใช้แสดงสถานะ
  String get colorCode {
    switch (this) {
      case OrderStatus.pending:
        return '#FFA500'; // Orange
      case OrderStatus.confirmed:
        return '#4CAF50'; // Green
      case OrderStatus.processing:
        return '#2196F3'; // Blue
      case OrderStatus.shipped:
        return '#9C27B0'; // Purple
      case OrderStatus.delivered:
        return '#4CAF50'; // Green
      case OrderStatus.cancelled:
        return '#F44336'; // Red
      case OrderStatus.refunded:
        return '#FF9800'; // Orange
    }
  }

  // ไอคอนที่ใช้แสดงสถานะ
  String get iconCode {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'check_circle';
      case OrderStatus.processing:
        return 'settings';
      case OrderStatus.shipped:
        return 'local_shipping';
      case OrderStatus.delivered:
        return 'done_all';
      case OrderStatus.cancelled:
        return 'cancel';
      case OrderStatus.refunded:
        return 'money_off';
    }
  }
}

enum PaymentStatus {
  pending('pending', 'รอชำระเงิน'),
  paid('paid', 'ชำระแล้ว'),
  cancelled('cancelled', 'ยกเลิกการชำระ'),
  refunded('refunded', 'คืนเงินแล้ว'),
  failed('failed', 'ชำระไม่สำเร็จ');

  const PaymentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentStatus fromString(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => PaymentStatus.pending,
    );
  }

  // สีที่ใช้แสดงสถานะ
  String get colorCode {
    switch (this) {
      case PaymentStatus.pending:
        return '#FFA500'; // Orange
      case PaymentStatus.paid:
        return '#4CAF50'; // Green
      case PaymentStatus.cancelled:
        return '#F44336'; // Red
      case PaymentStatus.refunded:
        return '#FF9800'; // Orange
      case PaymentStatus.failed:
        return '#F44336'; // Red
    }
  }
}

enum PaymentMethod {
  cash('cash', 'เงินสด'),
  creditCard('credit_card', 'บัตรเครดิต'),
  bankTransfer('bank_transfer', 'โอนเงิน'),
  qrCode('qr_code', 'QR Code'),
  promptPay('prompt_pay', 'พร้อมเพย์'),
  other('other', 'อื่นๆ');

  const PaymentMethod(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentMethod fromString(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == method,
      orElse: () => PaymentMethod.cash,
    );
  }
}
