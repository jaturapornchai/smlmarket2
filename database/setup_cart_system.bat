@echo off
echo =================================================================
echo 🗃️ SML Market - Recreate Cart System Database
echo =================================================================
echo.

REM ตรวจสอบว่ามี psql command หรือไม่
where psql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: PostgreSQL psql command not found!
    echo Please install PostgreSQL or add psql to your PATH
    echo.
    pause
    exit /b 1
)

REM ขอ Database connection info
set /p DB_HOST="Enter PostgreSQL Host (default: localhost): "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_PORT="Enter PostgreSQL Port (default: 5432): "
if "%DB_PORT%"=="" set DB_PORT=5432

set /p DB_NAME="Enter Database Name (default: smlmarket): "
if "%DB_NAME%"=="" set DB_NAME=smlmarket

set /p DB_USER="Enter Username (default: postgres): "
if "%DB_USER%"=="" set DB_USER=postgres

echo.
echo 🔄 Connecting to PostgreSQL...
echo Host: %DB_HOST%
echo Port: %DB_PORT%
echo Database: %DB_NAME%
echo User: %DB_USER%
echo.

REM รัน SQL script เพื่อสร้างระบบตะกร้าใหม่
echo 🛒 Creating cart system tables...
psql -h %DB_HOST% -p %DB_PORT% -d %DB_NAME% -U %DB_USER% -f recreate_cart_system.sql

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ ERROR: Failed to create cart system!
    pause
    exit /b 1
)

echo.
echo ✅ Cart system created successfully!
echo.

REM ถามว่าต้องการสร้างข้อมูลทดสอบหรือไม่
set /p CREATE_TEST_DATA="Do you want to create test data? (Y/N): "
if /i "%CREATE_TEST_DATA%"=="Y" (
    echo.
    echo 🧪 Creating test data...
    psql -h %DB_HOST% -p %DB_PORT% -d %DB_NAME% -U %DB_USER% -f test_data_cart_system.sql
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ⚠️  WARNING: Failed to create test data, but cart system is ready!
    ) else (
        echo.
        echo ✅ Test data created successfully!
    )
)

echo.
echo =================================================================
echo 🎉 SML Market Cart System Setup Complete!
echo =================================================================
echo.
echo Next steps:
echo 1. Test the Flutter app with 'flutter run -d windows'
echo 2. Try adding products to cart
echo 3. Create orders and verify database
echo.
pause
