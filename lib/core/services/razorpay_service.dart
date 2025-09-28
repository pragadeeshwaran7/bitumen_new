import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';

class RazorpayService {
  static const String _keyId = 'rzp_test_ZXpLTWIn4Ro6NC';
  
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
  }

  // Initialize Razorpay with callbacks
  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;
    
    // Clear existing listeners
    _razorpay.clear();
    
    // Add new listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Open Razorpay payment gateway
  Future<void> openPaymentGateway({
    required String orderId,
    required double amount,
    required String currency,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? description,
  }) async {
    try {
      print('=== OPENING RAZORPAY PAYMENT GATEWAY ===');
      print('Platform: ${Platform.operatingSystem}');
      print('Order ID: $orderId');
      print('Amount: $amount');
      
      // Check if running on Windows (desktop)
      if (Platform.isWindows) {
        print('Running on Windows - Razorpay not supported on desktop');
        throw Exception('Razorpay payment gateway is not supported on Windows desktop. Please test on Android/iOS device.');
      }
      
      // Generate a unique Razorpay order ID
      final razorpayOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      final options = {
        'key': _keyId,
        'amount': (amount * 100).toInt(), // Convert to paise
        'currency': currency,
        'name': 'Trucker App',
        'description': description ?? 'Payment for Order $orderId',
        'order_id': razorpayOrderId,
        'prefill': {
          'contact': customerPhone ?? '+91 9876543210',
          'email': customerEmail ?? 'customer@example.com',
          'name': customerName ?? 'Customer',
        },
        'external': {
          'wallets': ['paytm', 'phonepe', 'gpay']
        },
        'theme': {
          'color': '#FF5722'
        },
        'retry': {
          'enabled': true,
          'max_count': 3
        },
        'timeout': 300, // 5 minutes
        'modal': {
          'ondismiss': () {
            print('Payment modal dismissed');
          }
        }
      };

      print('Razorpay options: $options');
      _razorpay.open(options);
      print('Razorpay.open() called successfully');
      
    } catch (e) {
      print('Error opening Razorpay: $e');
      throw Exception('Failed to open payment gateway: $e');
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    if (_onPaymentSuccess != null) {
      _onPaymentSuccess!(response);
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    if (_onPaymentError != null) {
      _onPaymentError!(response);
    }
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  // Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }

  // Get Razorpay key ID
  String getKeyId() {
    return _keyId;
  }
}
