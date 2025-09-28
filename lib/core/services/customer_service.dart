import 'base_api_service.dart';
import 'api_config.dart';

class CustomerService extends BaseApiService {
  
  // Get customer profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/customer/profile');
    return response.data;
  }

  // Update customer profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? gstNumber,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (gstNumber != null) data['gst_number'] = gstNumber;

    final response = await put('/customer/profile', data: data);
    return response.data;
  }

  // Get customer orders
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int? page,
    int? limit,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'order_id': 'TR123456789',
          'status': 'In Transit',
          'pickup_location': 'Mumbai, Maharashtra',
          'delivery_location': 'Pune, Maharashtra',
          'goods_type': 'VG30 Bitumen (2 Tons)',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
        {
          'id': '2',
          'order_id': 'TR987654321',
          'status': 'Pending',
          'pickup_location': 'Delhi, Delhi',
          'delivery_location': 'Jaipur, Rajasthan',
          'goods_type': 'PMB Bitumen (3 Tons)',
          'amount': 18750.0,
          'created_at': '2025-02-18T14:30:00Z',
        },
      ];
    }

    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await get(
        '/customer/orders',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'order_id': 'TR123456789',
          'status': 'In Transit',
          'pickup_location': 'Mumbai, Maharashtra',
          'delivery_location': 'Pune, Maharashtra',
          'goods_type': 'VG30 Bitumen (2 Tons)',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
      ];
    }
  }

  // Get specific order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await get('/customer/orders/$orderId');
    return response.data;
  }

  // Create new order
  Future<Map<String, dynamic>> createOrder({
    required String pickupLocation,
    required String deliveryLocation,
    required String goodsType,
    required double quantity,
    required double amount,
    String? notes,
    DateTime? pickupDate,
    DateTime? deliveryDate,
  }) async {
    final data = {
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'goods_type': goodsType,
      'quantity': quantity,
      'amount': amount,
    };

    if (notes != null) data['notes'] = notes;
    if (pickupDate != null) data['pickup_date'] = pickupDate.toIso8601String();
    if (deliveryDate != null) data['delivery_date'] = deliveryDate.toIso8601String();

    final response = await post('/customer/orders', data: data);
    return response.data;
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await put('/customer/orders/$orderId/cancel', data: data);
    return response.data;
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPayments({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/customer/payments',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Update order status after payment
  Future<Map<String, dynamic>> updateOrderStatusAfterPayment({
    required String orderId,
    required String paymentId,
    required String status,
  }) async {
    final data = {
      'order_id': orderId,
      'payment_id': paymentId,
      'status': status,
      'payment_completed_at': DateTime.now().toIso8601String(),
    };

    final response = await put('/customer/orders/$orderId/status', data: data);
    return response.data;
  }

  // Create payment
  Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    final data = {
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod,
    };

    if (transactionId != null) data['transaction_id'] = transactionId;

    final response = await post('/customer/payments', data: data);
    return response.data;
  }

  // Get available tankers
  Future<List<Map<String, dynamic>>> getAvailableTankers({
    String? location,
    String? tankerType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (location != null) queryParams['location'] = location;
    if (tankerType != null) queryParams['tanker_type'] = tankerType;

    final response = await get(
      '/tankers/available',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Rate driver/supplier
  Future<Map<String, dynamic>> rateService({
    required String orderId,
    required int rating,
    String? review,
    String? type, // 'driver' or 'supplier'
  }) async {
    final data = {
      'order_id': orderId,
      'rating': rating,
    };

    if (review != null) data['review'] = review;
    if (type != null) data['type'] = type;

    final response = await post('/customer/ratings', data: data);
    return response.data;
  }
}
