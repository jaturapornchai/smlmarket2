class AppConfig {
  // กำหนดว่าจะใช้ PostgreSQL หรือ API เดิม
  static const bool usePostgreSQL =
      true; // เปลี่ยนเป็น true เมื่อพร้อมใช้ PostgreSQL

  // API Configuration
  static const String apiBaseUrl = 'https://smlgoapi.dedepos.com/v1';
  static const String postgresqlApiUrl =
      'https://smlgoapi.dedepos.com/v1'; // ใช้ API เดียวกันที่รองรับ PostgreSQL endpoints

  // การตั้งค่าอื่นๆ
  static const int requestTimeout = 30; // วินาที
  static const bool enableDebugMode = true;

  // Database settings (สำหรับอนาคต)
  static const String databaseHost = '143.198.192.64';
  static const int databasePort = 19250;
  static const String databaseName = 'sml2';
}
