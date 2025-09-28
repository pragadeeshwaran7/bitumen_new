import 'base_api_service.dart';
import 'api_config.dart';

class TrackingService extends BaseApiService {
  
  // Get all orders (for tracking service compatibility)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'order_id': 'TR123456789',
          'status': 'In Transit',
          'pickup_location': 'Mumbai, Maharashtra',
          'delivery_location': 'Pune, Maharashtra',
          'goods_type': 'VG30 Bitumen',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
        {
          'id': '2',
          'order_id': 'TR987654321',
          'status': 'Pending',
          'pickup_location': 'Delhi, Delhi',
          'delivery_location': 'Jaipur, Rajasthan',
          'goods_type': 'PMB Bitumen',
          'amount': 18750.0,
          'created_at': '2025-02-18T14:30:00Z',
        },
      ];
    }

    try {
      final response = await get('/orders');
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
          'goods_type': 'VG30 Bitumen',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
      ];
    }
  }
  
  // Track order by ID
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    final response = await get('/track/$orderId');
    return response.data;
  }

  // Track order by tracking number
  Future<Map<String, dynamic>> trackOrderByNumber(String trackingNumber) async {
    final response = await get('/track/number/$trackingNumber');
    return response.data;
  }

  // Get order location history
  Future<List<Map<String, dynamic>>> getOrderLocationHistory(String orderId) async {
    final response = await get('/track/$orderId/location-history');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get current order location
  Future<Map<String, dynamic>> getCurrentOrderLocation(String orderId) async {
    final response = await get('/track/$orderId/current-location');
    return response.data;
  }

  // Update order location
  Future<Map<String, dynamic>> updateOrderLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    final data = {
      'order_id': orderId,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (address != null) data['address'] = address;
    if (accuracy != null) data['accuracy'] = accuracy;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;

    final response = await post('/track/location', data: data);
    return response.data;
  }

  // Update driver location
  Future<Map<String, dynamic>> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    final data = {
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (address != null) data['address'] = address;
    if (accuracy != null) data['accuracy'] = accuracy;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;

    final response = await post('/track/driver-location', data: data);
    return response.data;
  }

  // Update tanker location
  Future<Map<String, dynamic>> updateTankerLocation({
    required String tankerId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    final data = {
      'tanker_id': tankerId,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (address != null) data['address'] = address;
    if (accuracy != null) data['accuracy'] = accuracy;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;

    final response = await post('/track/tanker-location', data: data);
    return response.data;
  }

  // Get estimated delivery time
  Future<Map<String, dynamic>> getEstimatedDeliveryTime(String orderId) async {
    final response = await get('/track/$orderId/estimated-delivery');
    return response.data;
  }

  // Get route information
  Future<Map<String, dynamic>> getRouteInfo({
    required String orderId,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    final queryParams = <String, dynamic>{};
    if (currentLatitude != null) queryParams['current_latitude'] = currentLatitude;
    if (currentLongitude != null) queryParams['current_longitude'] = currentLongitude;

    final response = await get(
      '/track/$orderId/route',
      queryParameters: queryParams,
    );
    return response.data;
  }

  // Get nearby drivers
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
    if (status != null) queryParams['status'] = status;

    final response = await get(
      '/track/nearby-drivers',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get nearby tankers
  Future<List<Map<String, dynamic>>> getNearbyTankers({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    String? status,
    String? tankerType,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
    if (status != null) queryParams['status'] = status;
    if (tankerType != null) queryParams['tanker_type'] = tankerType;

    final response = await get(
      '/track/nearby-tankers',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Start tracking session
  Future<Map<String, dynamic>> startTrackingSession({
    required String orderId,
    required String driverId,
    required String tankerId,
  }) async {
    final response = await post('/track/session/start', data: {
      'order_id': orderId,
      'driver_id': driverId,
      'tanker_id': tankerId,
    });
    return response.data;
  }

  // End tracking session
  Future<Map<String, dynamic>> endTrackingSession({
    required String orderId,
    String? notes,
  }) async {
    final data = {'order_id': orderId};
    if (notes != null) data['notes'] = notes;

    final response = await post('/track/session/end', data: data);
    return response.data;
  }

  // Get tracking session details
  Future<Map<String, dynamic>> getTrackingSession(String orderId) async {
    final response = await get('/track/session/$orderId');
    return response.data;
  }

  // Get real-time updates
  Future<List<Map<String, dynamic>>> getRealTimeUpdates({
    required String orderId,
    DateTime? lastUpdate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lastUpdate != null) queryParams['last_update'] = lastUpdate.toIso8601String();

    final response = await get(
      '/track/$orderId/real-time-updates',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Set geofence alerts
  Future<Map<String, dynamic>> setGeofenceAlert({
    required String orderId,
    required double latitude,
    required double longitude,
    required double radius,
    required String alertType,
    String? message,
  }) async {
    final response = await post('/track/geofence', data: {
      'order_id': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'alert_type': alertType,
      'message': message,
    });
    return response.data;
  }

  // Get geofence alerts
  Future<List<Map<String, dynamic>>> getGeofenceAlerts(String orderId) async {
    final response = await get('/track/$orderId/geofence-alerts');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get tracking statistics
  Future<Map<String, dynamic>> getTrackingStatistics({
    String? driverId,
    String? supplierId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (driverId != null) queryParams['driver_id'] = driverId;
    if (supplierId != null) queryParams['supplier_id'] = supplierId;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await get(
      '/track/statistics',
      queryParameters: queryParams,
    );
    return response.data;
  }
}
