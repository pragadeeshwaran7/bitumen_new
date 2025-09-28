# 🚀 Mobile App Development Guide

## 📱 Running on Mobile Device

### For Development (Mock Data)
The app is currently configured to use **mock data** for development. This means:
- ✅ No API calls to backend
- ✅ Instant responses with mock data
- ✅ Perfect for UI development and testing
- ✅ No network dependency

### To Switch to Real API
When the backend is ready, change this in `lib/core/services/api_config.dart`:

```dart
static const bool useMock = false; // Change from true to false
```

## 🔧 Current Configuration

### Mock Data Features:
- **OTP**: Always returns `123456`
- **Login**: Always successful with mock user data
- **Registration**: Always successful
- **Orders**: Uses existing mock data in screens
- **Tracking**: Uses existing mock tracking data

### Mock User Data:
- **Customer**: Mock Customer (phone: your input, email: mock@example.com)
- **Supplier**: Mock Supplier (phone: your input, email: mock@example.com)  
- **Driver**: Mock Driver (phone: your input, email: mock@example.com)

## 📲 Running the App

### On Android:
```bash
flutter run
```

### On iOS:
```bash
flutter run
```

### On Web (for testing):
```bash
flutter run -d chrome
```

## 🎯 Testing the App

1. **Login Flow**: 
   - Enter any phone number
   - OTP will be "123456" (mock)
   - Login will always succeed

2. **Registration Flow**:
   - Fill any form data
   - Registration will always succeed

3. **Navigation**:
   - All screens are functional
   - Orders show mock data
   - Tracking works with mock locations

## 🔄 When Backend is Ready

1. Change `useMock = false` in `api_config.dart`
2. Update API endpoints if needed
3. Test with real backend
4. Deploy to production

## 📞 Support

The app is now fully functional for mobile development with mock data. All screens work perfectly and you can test the complete user flow without any backend dependency!
