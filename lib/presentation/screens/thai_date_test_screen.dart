import 'package:flutter/material.dart';
import '../../utils/thai_date_formatter.dart';

/// หน้าจอทดสอบการแสดงวันที่แบบไทย
class ThaiDateTestScreen extends StatelessWidget {
  const ThaiDateTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final sampleDate = DateTime(2024, 1, 15, 14, 30, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ทดสอบการแสดงวันที่แบบไทย'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateCard('วันที่ปัจจุบัน', now, [
              'รูปแบบเต็ม: ${ThaiDateFormatter.formatFullThai(now)}',
              'รูปแบบเต็มพร้อมเวลา: ${ThaiDateFormatter.formatFullThaiWithTime(now)}',
              'รูปแบบเต็มพร้อมเวลาและวัน: ${ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(now)}',
              'รูปแบบสั้น: ${ThaiDateFormatter.formatShortThai(now)}',
              'รูปแบบสั้นมาก: ${ThaiDateFormatter.formatVeryShort(now)}',
              'รูปแบบรายการ: ${ThaiDateFormatter.formatForList(now)}',
              'เดือนและปี: ${ThaiDateFormatter.formatMonthYear(now)}',
              'รูปแบบสัมพัทธ์: ${ThaiDateFormatter.formatRelative(now)}',
              'สัมพัทธ์พร้อมเวลา: ${ThaiDateFormatter.formatRelativeWithTime(now)}',
            ]),
            const SizedBox(height: 20),
            _buildDateCard('เมื่อวาน', yesterday, [
              'รูปแบบเต็ม: ${ThaiDateFormatter.formatFullThai(yesterday)}',
              'รูปแบบสัมพัทธ์: ${ThaiDateFormatter.formatRelative(yesterday)}',
              'สัมพัทธ์พร้อมเวลา: ${ThaiDateFormatter.formatRelativeWithTime(yesterday)}',
            ]),
            const SizedBox(height: 20),
            _buildDateCard('วันที่ตัวอย่าง (15 มกราคม 2567)', sampleDate, [
              'รูปแบบเต็ม: ${ThaiDateFormatter.formatFullThai(sampleDate)}',
              'รูปแบบเต็มพร้อมเวลา: ${ThaiDateFormatter.formatFullThaiWithTime(sampleDate)}',
              'รูปแบบเต็มพร้อมเวลาและวัน: ${ThaiDateFormatter.formatFullThaiWithTimeAndWeekday(sampleDate)}',
              'รูปแบบสั้น: ${ThaiDateFormatter.formatShortThai(sampleDate)}',
              'รูปแบบสั้นมาก: ${ThaiDateFormatter.formatVeryShort(sampleDate)}',
              'รูปแบบรายการ: ${ThaiDateFormatter.formatForList(sampleDate)}',
              'เดือนและปี: ${ThaiDateFormatter.formatMonthYear(sampleDate)}',
              'รูปแบบสัมพัทธ์: ${ThaiDateFormatter.formatRelative(sampleDate)}',
              'รูปแบบเรียงลำดับ: ${ThaiDateFormatter.formatSortable(sampleDate)}',
            ]),
            const SizedBox(height: 20),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime dateTime, List<String> formats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ข้อมูลต้นฉบับ: ${dateTime.toString()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            ...formats.map(
              (format) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(format, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'ข้อมูลเพิ่มเติม',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• วันที่แปลงเป็นพุทธศักราช (+543 ปี)',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '• ชื่อเดือนและวันเป็นภาษาไทย',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '• รองรับรูปแบบสัมพัทธ์ (วันนี้, เมื่อวาน)',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '• มีรูปแบบให้เลือกใช้หลากหลาย',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
