import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';
import '../core/services/customer_service.dart';
import '../core/services/razorpay_service.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int selectedIndex = 0;

  String username = "Hariharan";
  String selectedTanker = "Small Tanker";
  String selectedGoods = "VG30";
  int loadingQty = 20;
  int unloadingQty = 20;
  int totalDistance = 42;
  int ratePerKm = 25;
  String selectedPaymentMethod = "Net Banking";
  int viewStep = -1;

  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final receiverEmailController = TextEditingController();

  // Services
  final CustomerService _customerService = CustomerService();
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    print('=== INITIALIZING RAZORPAY SERVICE ===');
    
    // Initialize Razorpay service with callbacks
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    
    print('Razorpay service initialized');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment successful: ${response.paymentId}');
    
    // Create order in backend
    _createOrderInBackend(response);
    
    setState(() {
      viewStep = 2; // Show success view
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! Payment ID: ${response.paymentId}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _createOrderInBackend(PaymentSuccessResponse response) async {
    try {
      // Create order using customer service
      await _customerService.createOrder(
        pickupLocation: pickupController.text,
        deliveryLocation: dropController.text,
        goodsType: selectedGoods,
        quantity: loadingQty.toDouble(),
        amount: calculateTotal().toDouble(),
        notes: 'Order created via mobile app',
      );
      print('Order created successfully in backend');
    } catch (e) {
      print('Failed to create order in backend: $e');
      // Continue with success flow even if backend creation fails
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment failed: ${response.message}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose(); // Dispose Razorpay service
    super.dispose();
  }

  final trucks = {
    "Small Tanker": {"range": "10-15 Tons", "rate": 20},
    "Medium Tanker": {"range": "16-25 Tons", "rate": 22},
    "Large Tanker": {"range": "26-35 Tons", "rate": 25},
  };

  final goodsOptions = [
    "PMB", "CRMB", "VG30", "VG40",
    "RS1", "RS2", "SS1", "SS2", "MR"
  ];

  int calculateTotal() => (trucks[selectedTanker]!["rate"] as int) * totalDistance;
  int calculateAdvance() => (calculateTotal() * 0.75).round();

  Future<void> proceedToPayment() async {
    print('=== PROCEED TO PAYMENT CALLED ===');
    print('Platform: ${Platform.operatingSystem}');
    print('About to call confirmAndPay()');
    
    // Directly open Razorpay payment gateway
    await confirmAndPay();
    
    print('=== PROCEED TO PAYMENT COMPLETED ===');
  }

  Future<void> confirmAndPay() async {
    try {
      print('=== CONFIRM AND PAY CALLED ===');
      print('Platform: ${Platform.operatingSystem}');
      
      // Calculate payment amount (75% advance)
      final advanceAmount = calculateAdvance();
      print('Advance amount: $advanceAmount');
      
      // Generate order ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      // Use Razorpay service to open payment gateway
      await _razorpayService.openPaymentGateway(
        orderId: orderId,
        amount: advanceAmount.toDouble(),
        currency: 'INR',
        customerName: username,
        customerEmail: receiverEmailController.text.isNotEmpty 
            ? receiverEmailController.text 
            : 'customer@example.com',
        customerPhone: receiverPhoneController.text.isNotEmpty 
            ? receiverPhoneController.text 
            : '+91 9876543210',
        description: 'Advance payment for ${selectedGoods} delivery',
      );
      
      print('Razorpay payment gateway opened successfully');
      
    } catch (e) {
      print('Error in confirmAndPay: $e');
      print('Error type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void makePayment() {
    // Mock payment success
    setState(() => viewStep = 2);
  }

  void onBottomBarTap(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customer-orders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/customer-payments');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/customer-track');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/customer-account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: viewStep == -1
      ? null
      : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              viewStep = viewStep == 2 ? -1 : viewStep - 1;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/test-razorpay');
            },
            tooltip: 'Test Razorpay',
          ),
        ],
      ),
      body: viewStep == -1
          ? buildInitialView()
          : viewStep == 0
              ? buildBookingView()
              : viewStep == 1
                  ? buildPaymentView()
                  : viewStep == 2
                    ? buildSuccessView()
                    : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onBottomBarTap,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  Widget buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome, $username!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(Icons.local_shipping, size: 120, color: Colors.red),
                const Text("Book and Track",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => viewStep = 0),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50)),
            child: const Text("Tankers Within State"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() => viewStep = 0),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50)),
            child: const Text("Tankers With All India Permit"),
          ),
        ],
      ),
    );
  }

  Widget buildBookingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        const Text("Select Tanker Type", style: TextStyle(fontWeight: FontWeight.bold)),
        ...trucks.entries.map((e) {
          final isSelected = selectedTanker == e.key;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.shade50 : Colors.white,
              border: Border.all(color: isSelected ? Colors.red : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.fire_truck, color: Colors.red),
              title: Text(e.key),
              subtitle: Text("Capacity: ${e.value["range"]}"),
              trailing: Text("₹${e.value["rate"]}/km"),
              onTap: () => setState(() {
                selectedTanker = e.key;
                ratePerKm = (e.value["rate"] as int);
              }),
            ),
          );
        }),
        buildInput("Pickup Location", pickupController),
        buildInput("Drop Location", dropController),
        buildInput("Receiver Name", receiverNameController),
        buildInput("Receiver Phone", receiverPhoneController),
        buildInput("Receiver Email", receiverEmailController),
        const SizedBox(height: 20),
        const Text("Select Goods Type", style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: goodsOptions.map((g) {
            final selected = g == selectedGoods;
            return ChoiceChip(
              label: Text(g),
              selected: selected,
              selectedColor: Colors.red,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
              onSelected: (_) => setState(() => selectedGoods = g),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text("Quantity at Loading", style: TextStyle(fontWeight: FontWeight.bold)),
        buildQtyRow(loadingQty, (val) => setState(() => loadingQty = val)),
        const SizedBox(height: 16),
        const Text("Quantity at Unloading", style: TextStyle(fontWeight: FontWeight.bold)),
        buildQtyRow(unloadingQty, (val) => setState(() => unloadingQty = val)),
        const SizedBox(height: 20),
        const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        buildSummaryRow("Price/km", "₹$ratePerKm"),
        buildSummaryRow("Distance", "$totalDistance km"),
        buildSummaryRow("Quantity", "$loadingQty Tons"),
        const Divider(),
        buildSummaryRow("Total Price", "₹${calculateTotal()}"),
        buildSummaryRow("75% Advance", "₹${calculateAdvance()}", highlight: true),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: proceedToPayment,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50)),
          child: const Text("Make Payment"),
        ),
      ]),
    );
  }

  Widget buildPaymentView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Price', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('₹${calculateTotal()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('75% Advance Payment', style: TextStyle(color: Colors.red)),
                    Text('₹${calculateAdvance()}.00', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text('Balance on Delivery\n₹${calculateTotal() - calculateAdvance()}.00', style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.red),
            title: const Text('Credit/Debit Card'),
            subtitle: const Text('All major cards accepted'),
            trailing: const Icon(Icons.radio_button_checked, color: Colors.red),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.green),
            title: const Text('UPI Payment'),
            subtitle: const Text('Google Pay, PhonePe, Paytm'),
            trailing: const Icon(Icons.radio_button_off, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance, color: Colors.blue),
            title: const Text('Net Banking'),
            subtitle: const Text('All major banks supported'),
            trailing: const Icon(Icons.radio_button_off, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Saved Cards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.credit_card),
            title: const Text('•••• •••• •••• 4567'),
            subtitle: const Text('Expires 05/25'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Default', style: TextStyle(color: Colors.green)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.red),
            label: const Text('+ Add New Card', style: TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: confirmAndPay,
            child: const Text('Confirm and Pay'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              backgroundColor: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget buildSuccessView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 20),
          const Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your order has been placed successfully. You can\ntrack your order using the tracking ID.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
            ),
            child: Column(
              children: const [
                Text('Order ID', style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 6),
                Text('ORD5045963', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          detailRow('Payment Amount', '₹12,456.00'),
          detailRow('Payment Method', 'Credit Card'),
          detailRow('Transaction Date', '5/21/2025'),
          detailRow('Transaction ID', 'TXN8435057153'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                viewStep = -1; // Go back to home step
              });
            },
            child: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget detailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}


  Widget buildQtyRow(int value, Function(int) onChange) {
    return Row(children: [
      IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: value > 1 ? () => onChange(value - 1) : null,
      ),
      Text("$value Tons", style: const TextStyle(fontSize: 16)),
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => onChange(value + 1),
      ),
    ]);
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: highlight ? Colors.red : Colors.black)),
        ],
      ),
    );
  }
}
