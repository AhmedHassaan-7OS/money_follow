# 💰 Money Follow - Smart Financial Tracker

A modern Flutter expense tracking app with **AI-powered insights** and **intelligent categorization**.

------------------------------------------------------------------------------------------------------
![WhatsApp Image 2026-02-17 at 3 33 30 PM](https://github.com/user-attachments/assets/5a06dc30-27b2-4ddb-a187-6fcf832f5739)
![WhatsApp Image 2026-02-17 at 3 33 29 PM](https://github.com/user-attachments/assets/679ef28a-85d6-441b-96ed-1190faae9266)
![WhatsApp Image 2026-02-17 at 3 33 29 PM (3)](https://github.com/user-attachments/assets/a5aa1439-428f-4a03-a862-c04e301e8119)
![WhatsApp Image 2026-02-17 at 3 33 29 PM (2)](https://github.com/user-attachments/assets/d967d197-bcb0-46cf-b8e3-684a5c8198f6)
![WhatsApp Image 2026-02-17 at 3 33 29 PM (1)](https://github.com/user-attachments/assets/5305468f-ab9e-4ccc-af18-a2069138afaf)
![WhatsApp Image 2026-02-17 at 3 33 28 PM (4)](https://github.com/user-attachments/assets/e9d83f45-a06f-4810-a35b-5f062602384b)
![WhatsApp Image 2026-02-17 at 3 33 28 PM (3)](https://github.com/user-attachments/assets/a2c5e5f0-eb0f-413a-b907-a175a4e49fee)
![WhatsApp Image 2026-02-17 at 3 33 28 PM (2)](https://github.com/user-attachments/assets/c8563436-cfd3-4a5f-b19f-0ff795725e7e)
![WhatsApp Image 2026-02-17 at 3 33 28 PM (1)](https://github.com/user-attachments/assets/51d35ecf-40c6-4896-96e5-c05a5d92c2ac)
![3](https://github.com/user-attachments/assets/a2731546-d176-43ee-a7d5-b6f74a5b1e7f)
![2](https://github.com/user-attachments/assets/1847ab35-320d-4dfa-92a5-ade652838aef)
![1](https://github.com/user-attachments/assets/a0d79938-3b44-4b0d-8b54-545b309cedb5)

------------------------------------------------------------------------------------------------------

## ✨ Features

### 🤖 **AI-Powered Smart Features**
- **Automatic Category Detection** - AI suggests categories based on expense descriptions
- **Personalized Financial Tips** - Get smart recommendations based on your spending patterns
- **Budget Insights** - AI analyzes your spending and provides actionable advice
- **Custom Categories** - Create personalized expense categories

### 🎨 **Modern UI/UX**
- **Dark/Light Mode** - Beautiful themes with proper contrast
- **Multi-Language Support** - English, Arabic, French, German, Japanese
- **Material Design 3** - Modern, clean interface
- **Responsive Design** - Works perfectly on all screen sizes

### 🏗️ **Robust Architecture**
- **BLoC Pattern** - Clean separation of business logic and UI
- **SQLite Database** - Reliable local data storage
- **Comprehensive Validation** - Smart form validation with helpful messages
- **Error Handling** - Graceful error handling throughout the app

### 📊 **Financial Management**
- **Expense Tracking** - Track all your expenses with categories
- **Income Management** - Record and manage income sources
- **Commitments** - Track recurring bills and commitments
- **History & Analytics** - View spending history with insights
- **Backup & Restore** - Secure data backup and restore functionality

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd money_follow

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building for Release
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## 🤖 AI Features Demo

### Smart Category Detection
```
Type "Coffee at Starbucks" → AI suggests "Food" category
Type "Uber ride to airport" → AI suggests "Transport" category  
Type "Netflix subscription" → AI suggests "Bills" category
```

### Personalized Tips
```
"Food expenses are 25% of income - consider meal planning"
"Great job! You're saving 20% of your income"
"Transport costs are high. Consider carpooling or public transport"
```

## 📱 Screenshots

| Light Mode | Dark Mode | AI Insights |
|------------|-----------|-------------|
| ![Light](screenshots/light.png) | ![Dark](screenshots/dark.png) | ![AI](screenshots/ai.png) |

## 🏗️ Architecture

### BLoC Pattern Implementation
```
lib/
├── bloc/                 # Business Logic Components
│   ├── expense/         # Expense-related BLoC
│   ├── income/          # Income-related BLoC
│   └── commitment/      # Commitment-related BLoC
├── model/               # Data Models
├── services/            # Services (AI, Database, etc.)
├── view/                # UI Components
└── utils/               # Utilities and Helpers
```

### Key Components
- **Events** - Define what can happen (AddExpense, UpdateExpense, etc.)
- **States** - Define app states (Loading, Loaded, Error, etc.)
- **BLoCs** - Handle business logic and state transitions
- **UI** - Clean presentation layer with no business logic

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/ai_suggestion_test.dart

# Generate coverage report
flutter test --coverage
```

## 📚 Documentation

- [**IMPROVEMENTS_SUMMARY.md**](IMPROVEMENTS_SUMMARY.md) - Detailed list of all improvements
- [**DEMO_GUIDE.md**](DEMO_GUIDE.md) - Step-by-step guide to test new features
- [**API Documentation**](docs/api.md) - Code documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- Contributors and testers

## 📞 Support

If you have any questions or need help:
- Create an issue on GitHub
- Check the [FAQ](docs/faq.md)
- Review the [troubleshooting guide](docs/troubleshooting.md)

---

**Made with ❤️ using Flutter and AI**
