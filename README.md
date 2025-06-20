# SML Market - Flutter Product Search App

Modern Flutter application for product search with AI-powered features and responsive design.

## ✨ Features

- 🔍 **Product Search**: Search products with real-time results
- 🧠 **AI Search**: Toggle AI-powered search functionality  
- 📱 **Responsive Design**: Optimized for all screen sizes (2-6 columns)
- 🔄 **Infinite Scroll**: Seamless pagination with smooth loading
- 💳 **Product Cards**: Beautiful cards with comprehensive product information
- 🎨 **Modern UI**: Clean design with Material 3 components
- 📊 **Wrap Layout**: 100% width utilization without gaps

## 🏗️ Architecture

This project follows Flutter best practices with clean architecture:

```
lib/
├── data/
│   ├── models/          # Product and response models
│   ├── repositories/    # Data repositories abstraction
│   └── data_sources/    # API communication layer
├── presentation/
│   ├── screens/         # Main app screens
│   ├── widgets/         # Reusable UI components
│   └── cubit/          # State management (Cubit pattern)
└── main.dart           # Application entry point
```

## 🛠️ Technologies Used

- **Flutter** - Cross-platform UI framework
- **Cubit (flutter_bloc)** - Predictable state management
- **HTTP** - RESTful API communication
- **Logger** - Advanced logging and debugging
- **Equatable** - Object comparison and state immutability

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.1.0
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  logger: ^2.0.2+1
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK  
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smlmarket.git
   cd smlmarket
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🌐 API Integration

The app connects to a backend API with the following configuration:

- **Base URL**: `http://localhost:8008`
- **Endpoint**: `POST /search`
- **Parameters**: 
  - `query` (string): Search term
  - `ai` (integer): AI toggle (0/1)
  - `limit` (integer): Items per page (default: 50)
  - `offset` (integer): Pagination offset

## 📱 Key Features Detail

### Product Search
- **Real-time Search**: Instant results as you type
- **AI Enhancement**: Toggle AI-powered recommendations
- **Error Handling**: Graceful error states with retry options

### Product Display
- **Responsive Grid**: 2-6 columns based on screen size
- **Wrap Layout**: 100% width utilization without side margins
- **Dynamic Height**: Cards adjust to content length

### Product Information
- **Pricing**: Regular, sale, and final prices with discounts
- **Stock Status**: Available quantity display
- **Sales Data**: "Sold quantity" information  
- **Discounts**: Amount, percentage, and special offers

## 🎯 Product Card Layout

The new card design features a vertical information flow:

1. **Product Image** (140px fixed height)
2. **Product Name** (full display, no truncation)
3. **Premium Badge** (if available)
4. **Discount Information** (amount, percentage, details)
5. **Stock Status** (large, prominent display)
6. **Final Price** (largest, bottom position)

## 📱 Responsive Design

### Screen Breakpoints
- **≤480px**: 2 columns (mobile phones)
- **481-768px**: 3 columns (large phones/small tablets)
- **769-1024px**: 4 columns (tablets)
- **1025-1200px**: 5 columns (small desktop)
- **>1200px**: 6 columns (large desktop)

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Development Team

Built with ❤️ using Flutter and modern development practices.

---

**Note**: This application requires an active backend API server for full functionality. Make sure your API endpoint is configured correctly before testing.
