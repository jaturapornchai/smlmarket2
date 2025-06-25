import 'lib/utils/thai_date_formatter.dart';

void main() {
  print('=== ทดสอบ Thai Date Formatter (Full with Weekday) ===');

  // ทดสอบ 25 มิถุนายน 2568 เวลา 06:29 (วันพุธ)
  final testDate1 = DateTime(2025, 6, 25, 6, 29);
  print('Test Date 1 (25 มิถุนายน 2568 เวลา 06:29):');
  print(
    '- formatFullThaiWithTimeAndWeekday: ${ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(testDate1)}',
  );
  print('- ควรแสดง: "25 มิถุนายน 2568 (พุธ) เวลา 06:29"');
  print('');

  // ทดสอบ 24 มิถุนายน 2568 เวลา 17:24 (วันอังคาร)
  final testDate2 = DateTime(2025, 6, 24, 17, 24);
  print('Test Date 2 (24 มิถุนายน 2568 เวลา 17:24):');
  print(
    '- formatFullThaiWithTimeAndWeekday: ${ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(testDate2)}',
  );
  print('- ควรแสดง: "24 มิถุนายน 2568 (อังคาร) เวลา 17:24"');
  print('');

  // ทดสอบวันอาทิตย์
  final sunday = DateTime(2025, 6, 29, 10, 0);
  print('Test Date 3 (วันอาทิตย์ 29 มิถุนายน 2568):');
  print(
    '- formatFullThaiWithTimeAndWeekday: ${ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(sunday)}',
  );
  print('- ควรแสดง: "29 มิถุนายน 2568 (อาทิตย์) เวลา 10:00"');
}
