import 'dart:io';
import 'package:dio/dio.dart';
import 'base_api_service.dart';
import 'api_config.dart';

class SupplierService extends BaseApiService {
  
  // Get supplier profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/supplier/profile');
    return response.data;
  }

  // Update supplier profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;

    final response = await put('/supplier/profile', data: data);
    return response.data;
  }

  // Get supplier orders
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
          'tanker_number': 'MH12AB1234',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
        {
          'id': '2',
          'order_id': 'TR987654321',
          'status': 'Pending',
          'pickup_location': 'Delhi, Delhi',
          'delivery_location': 'Jaipur, Rajasthan',
          'tanker_number': 'MH12AB1234',
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
        '/supplier/orders',
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
          'tanker_number': 'MH12AB1234',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
      ];
    }
  }

  // Get specific order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await get('/supplier/orders/$orderId');
    return response.data;
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? notes,
  }) async {
    final data = {'status': status};
    if (notes != null) data['notes'] = notes;

    final response = await put('/supplier/orders/$orderId/status', data: data);
    return response.data;
  }

  // Accept order
  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final response = await put('/supplier/orders/$orderId/accept');
    return response.data;
  }

  // Reject order
  Future<Map<String, dynamic>> rejectOrder(String orderId, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await put('/supplier/orders/$orderId/reject', data: data);
    return response.data;
  }

  // Get supplier tankers
  Future<List<Map<String, dynamic>>> getTankers({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/supplier/tankers',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Add new tanker
  Future<Map<String, dynamic>> addTanker({
    required String tankerNumber,
    required String tankerType,
    required double maxCapacity,
    required double permissibleLimit,
    required String rcNumber,
    required DateTime rcExpiry,
    required String insuranceNumber,
    required DateTime insuranceExpiry,
    required String fcNumber,
    required DateTime fcExpiry,
    required String npNumber,
    required DateTime npExpiry,
    required String driverId,
    File? rcDocument,
    File? insuranceDocument,
    File? fcDocument,
    File? npDocument,
    double? latitude,
    double? longitude,
  }) async {
    final formData = FormData.fromMap({
      'tanker_number': tankerNumber,
      'tanker_type': tankerType,
      'max_capacity': maxCapacity,
      'permissible_limit': permissibleLimit,
      'rc_number': rcNumber,
      'rc_expiry': rcExpiry.toIso8601String(),
      'insurance_number': insuranceNumber,
      'insurance_expiry': insuranceExpiry.toIso8601String(),
      'fc_number': fcNumber,
      'fc_expiry': fcExpiry.toIso8601String(),
      'np_number': npNumber,
      'np_expiry': npExpiry.toIso8601String(),
      'driver_id': driverId,
      'visible_to_customer': 'true',
      'status': 'Available',
    });

    if (latitude != null) formData.fields.add(MapEntry('location.lat', latitude.toString()));
    if (longitude != null) formData.fields.add(MapEntry('location.lng', longitude.toString()));

    // Add file uploads
    if (rcDocument != null) {
      formData.files.add(MapEntry(
        'rc_document',
        await MultipartFile.fromFile(
          rcDocument.path,
          filename: rcDocument.path.split('/').last,
        ),
      ));
    }

    if (insuranceDocument != null) {
      formData.files.add(MapEntry(
        'insurance_document',
        await MultipartFile.fromFile(
          insuranceDocument.path,
          filename: insuranceDocument.path.split('/').last,
        ),
      ));
    }

    if (fcDocument != null) {
      formData.files.add(MapEntry(
        'fc_document',
        await MultipartFile.fromFile(
          fcDocument.path,
          filename: fcDocument.path.split('/').last,
        ),
      ));
    }

    if (npDocument != null) {
      formData.files.add(MapEntry(
        'np_document',
        await MultipartFile.fromFile(
          npDocument.path,
          filename: npDocument.path.split('/').last,
        ),
      ));
    }

    final response = await postFormData('/tankers', formData: formData);
    return response.data;
  }

  // Update tanker
  Future<Map<String, dynamic>> updateTanker({
    required String tankerId,
    String? tankerNumber,
    String? tankerType,
    double? maxCapacity,
    double? permissibleLimit,
    String? status,
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{};
    if (tankerNumber != null) data['tanker_number'] = tankerNumber;
    if (tankerType != null) data['tanker_type'] = tankerType;
    if (maxCapacity != null) data['max_capacity'] = maxCapacity;
    if (permissibleLimit != null) data['permissible_limit'] = permissibleLimit;
    if (status != null) data['status'] = status;
    if (latitude != null) data['location.lat'] = latitude;
    if (longitude != null) data['location.lng'] = longitude;

    final response = await put('/tankers/$tankerId', data: data);
    return response.data;
  }

  // Delete tanker
  Future<void> deleteTanker(String tankerId) async {
    await delete('/tankers/$tankerId');
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
      '/supplier/payments',
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

    final response = await put('/supplier/orders/$orderId/status', data: data);
    return response.data;
  }

  // Get drivers associated with supplier
  Future<List<Map<String, dynamic>>> getDrivers() async {
    final response = await get('/supplier/drivers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Add driver to supplier
  Future<Map<String, dynamic>> addDriver({
    required String driverId,
  }) async {
    final response = await post('/supplier/drivers', data: {'driver_id': driverId});
    return response.data;
  }

  // Remove driver from supplier
  Future<void> removeDriver(String driverId) async {
    await delete('/supplier/drivers/$driverId');
  }
}
