import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String currency;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? description;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.description,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String _paymentStatus = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    print('=== INITIALIZING RAZORPAY IN PAYMENT SCREEN ===');
    // Note: Razorpay instance will be created in _processPayment
    print('PaymentScreen initialized');
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment successful: ${response.paymentId}');
    
    setState(() {
      _isLoading = false;
      _paymentStatus = 'Payment successful!';
    });

    // Show success dialog immediately
    _showPaymentSuccessDialog(response);
    
    // Return true to indicate successful payment
    Navigator.of(context).pop(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentStatus = 'Payment failed';
      _errorMessage = response.message ?? 'Payment failed';
      _isLoading = false;
    });

    _showPaymentErrorDialog(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _paymentStatus = 'External wallet selected: ${response.walletName}';
    });
  }

  Future<void> _processPayment() async {
    print('=== PROCESSING PAYMENT IN PAYMENT SCREEN ===');
    print('Platform: ${Platform.operatingSystem}');
    
    setState(() {
      _isLoading = true;
      _paymentStatus = 'Opening payment gateway...';
      _errorMessage = '';
    });

    try {
      // Check if running on Windows (desktop)
      if (Platform.isWindows) {
        print('Running on Windows - Razorpay may not work on desktop');
        setState(() {
          _isLoading = false;
          _paymentStatus = 'Payment gateway not supported on Windows desktop';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Razorpay payment gateway is not supported on Windows desktop. Please test on Android/iOS device.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Simulate payment success for testing
        await Future.delayed(const Duration(seconds: 2));
        _handlePaymentSuccess(PaymentSuccessResponse(
          'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
          'mock_order_${DateTime.now().millisecondsSinceEpoch}',
          'mock_signature',
          {},
        ));
        return;
      }

      // Create Razorpay instance if not already created
      if (!mounted) return;
      
      final razorpay = Razorpay();
      
      // Create checkout options
      var options = {
        'key': 'rzp_test_ZXpLTWIn4Ro6NC', // Your Razorpay Key ID
        'amount': (widget.amount * 100).toInt(), // Amount in paise
        'currency': widget.currency,
        'name': 'Trucker App',
        'description': widget.description ?? 'Payment for Order ${widget.orderId}',
        'order_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'timeout': 300, // 5 minutes
        'prefill': {
          'contact': widget.customerPhone ?? '+91 9876543210',
          'email': widget.customerEmail ?? 'customer@example.com',
          'name': widget.customerName ?? 'Customer',
        },
        'theme': {
          'color': '#FF5722'
        },
        'retry': {
          'enabled': true,
          'max_count': 3
        }
      };

      print('About to open Razorpay with options: $options');
      
      // Attach event listeners
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      razorpay.open(options);
      print('Razorpay.open() called successfully');
      
      setState(() {
        _paymentStatus = 'Payment gateway opened';
      });
      
    } catch (e) {
      print('Error in payment process: $e');
      setState(() {
        _isLoading = false;
        _paymentStatus = 'Failed to open payment gateway';
        _errorMessage = e.toString();
      });
    }
  }

  void _showPaymentSuccessDialog(PaymentSuccessResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment ID: ${response.paymentId}'),
              const SizedBox(height: 8),
              Text('Order ID: ${response.orderId}'),
              const SizedBox(height: 8),
              Text('Amount: ₹${widget.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text(
                'Your payment has been processed successfully. You will receive a confirmation email shortly.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Return success
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentErrorDialog(PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Payment Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Error Code: ${response.code}'),
              const SizedBox(height: 8),
              Text('Error Message: ${response.message}'),
              const SizedBox(height: 16),
              const Text(
                'Your payment could not be processed. Please try again or use a different payment method.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment(); // Retry payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order ID:'),
                        Text(
                          widget.orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '₹${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Currency:'),
                        Text(
                          widget.currency,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Methods
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Razorpay Payment Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  _isLoading ? 'Processing...' : 'Pay with Razorpay',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Status
            if (_paymentStatus.isNotEmpty) ...[
              Card(
                color: _errorMessage.isNotEmpty ? Colors.red.shade50 : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _errorMessage.isNotEmpty ? Icons.error : Icons.info,
                        color: _errorMessage.isNotEmpty ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _paymentStatus,
                          style: TextStyle(
                            color: _errorMessage.isNotEmpty ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Supported Payment Methods
            const Text(
              'Supported Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Credit/Debit Cards',
                'Net Banking',
                'UPI',
                'Wallets',
                'Paytm',
                'PhonePe',
                'Google Pay',
              ].map((method) => Chip(
                label: Text(method),
                backgroundColor: Colors.grey.shade200,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
