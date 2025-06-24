/// Helper class สำหรับจัดการเลขที่ใบขอยืนยันราคา
class QuotationNumberHelper {
  /// สร้างเลขที่ใบขอยืนยันราคาใหม่
  /// รูปแบบ: QU-YYYY-NNNNNN (เช่น QU-2025-000001)
  static String generateQuotationNumber() {
    final now = DateTime.now();
    final year = now.year;
    final timestamp = now.millisecondsSinceEpoch;

    // ใช้ timestamp ท้าย 6 หลักเป็นเลขที่
    final number = (timestamp % 1000000).toString().padLeft(6, '0');

    return 'QU-$year-$number';
  }

  /// ตรวจสอบว่าเลขที่ใบขอยืนยันราคาถูกต้องหรือไม่
  static bool isValidQuotationNumber(String quotationNumber) {
    final regex = RegExp(r'^QU-\d{4}-\d{6}$');
    return regex.hasMatch(quotationNumber);
  }

  /// แยกปีจากเลขที่ใบขอยืนยันราคา
  static int? getYearFromQuotationNumber(String quotationNumber) {
    if (!isValidQuotationNumber(quotationNumber)) return null;

    final parts = quotationNumber.split('-');
    if (parts.length == 3) {
      return int.tryParse(parts[1]);
    }
    return null;
  }

  /// แยกลำดับจากเลขที่ใบขอยืนยันราคา
  static int? getSequenceFromQuotationNumber(String quotationNumber) {
    if (!isValidQuotationNumber(quotationNumber)) return null;

    final parts = quotationNumber.split('-');
    if (parts.length == 3) {
      return int.tryParse(parts[2]);
    }
    return null;
  }
}
