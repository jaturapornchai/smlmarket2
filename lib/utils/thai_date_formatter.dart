/// Helper class สำหรับแปลงวันที่เป็นรูปแบบไทย
/// เช่น "1 มกราคม 2568 (อังคาร)"
class ThaiDateFormatter {
  // ชื่อเดือนภาษาไทย
  static const List<String> _thaiMonths = [
    '', // index 0 (ไม่ใช้)
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  // ชื่อเดือนภาษาไทยแบบสั้น
  static const List<String> _thaiMonthsShort = [
    '', // index 0 (ไม่ใช้)
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  // ชื่อวันในสัปดาห์ภาษาไทย
  static const List<String> _thaiWeekdays = [
    'อาทิตย์',
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
  ];

  /// แปลงวันที่เป็นรูปแบบไทยแบบเต็ม
  /// เช่น "1 มกราคม 2568 (อังคาร)"
  static String formatFullThai(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = _thaiMonths[dateTime.month];
    final year = dateTime.year + 543; // แปลงเป็นพุทธศักราช
    final weekday = _thaiWeekdays[dateTime.weekday == 7 ? 0 : dateTime.weekday];

    return '$day $month $year ($weekday)';
  }

  /// แปลงวันที่เป็นรูปแบบไทยแบบสั้น
  /// เช่น "1 ม.ค. 68"
  static String formatShortThai(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = _thaiMonthsShort[dateTime.month];
    final year = (dateTime.year + 543) % 100; // แสดงปีแค่ 2 หลัก

    return '$day $month $year';
  }

  /// แปลงวันที่เป็นรูปแบบไทยพร้อมเวลา
  /// เช่น "1 มกราคม 2568 เวลา 14:30"
  static String formatFullThaiWithTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = _thaiMonths[dateTime.month];
    final year = dateTime.year + 543;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year เวลา $hour:$minute';
  }

  /// แปลงวันที่เป็นรูปแบบไทยพร้อมเวลาและวันในสัปดาห์
  /// เช่น "1 มกราคม 2568 (อังคาร) เวลา 14:30"
  static String formatFullThaiWithTimeAndWeekday(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = _thaiMonths[dateTime.month];
    final year = dateTime.year + 543;
    final weekday = _thaiWeekdays[dateTime.weekday == 7 ? 0 : dateTime.weekday];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year ($weekday) เวลา $hour:$minute';
  }

  /// แปลงวันที่เป็นรูปแบบที่สั้นมากสำหรับ UI
  /// เช่น "1/1/68"
  static String formatVeryShort(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = dateTime.month;
    final year = (dateTime.year + 543) % 100;

    return '$day/$month/$year';
  }

  /// แปลงวันที่เป็นรูปแบบสำหรับแสดงในรายการ
  /// เช่น "วันอังคารที่ 1 มกราคม 2568"
  static String formatForList(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final month = _thaiMonths[dateTime.month];
    final year = dateTime.year + 543;
    final weekday = _thaiWeekdays[dateTime.weekday == 7 ? 0 : dateTime.weekday];

    return 'วัน$weekday ที่ $day $month $year';
  }

  /// แปลงเฉพาะเดือนและปีเป็นภาษาไทย
  /// เช่น "มกราคม 2568"
  static String formatMonthYear(DateTime? dateTime) {
    if (dateTime == null) return '';

    final month = _thaiMonths[dateTime.month];
    final year = dateTime.year + 543;

    return '$month $year';
  }

  /// แปลงเป็นรูปแบบสำหรับการเรียงลำดับ (ยังคงรูปแบบ ISO แต่แสดงเป็นไทย)
  /// เช่น "2568-01-01"
  static String formatSortable(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year + 543;

    return '$year-$month-$day';
  }

  /// ตรวจสอบว่าเป็นวันนี้หรือไม่
  static bool isToday(DateTime? dateTime) {
    if (dateTime == null) return false;
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// ตรวจสอบว่าเป็นเมื่อวานหรือไม่
  static bool isYesterday(DateTime? dateTime) {
    if (dateTime == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// แสดงวันที่แบบสัมพัทธ์ (วันนี้, เมื่อวาน, หรือวันที่ปกติ)
  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return '';

    if (isToday(dateTime)) {
      return 'วันนี้';
    } else if (isYesterday(dateTime)) {
      return 'เมื่อวาน';
    } else {
      return formatFullThai(dateTime);
    }
  }

  /// แสดงวันที่แบบสัมพัทธ์พร้อมเวลา
  static String formatRelativeWithTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (isToday(dateTime)) {
      return 'วันนี้ เวลา $hour:$minute';
    } else if (isYesterday(dateTime)) {
      return 'เมื่อวาน เวลา $hour:$minute';
    } else {
      return formatFullThaiWithTime(dateTime);
    }
  }
}
