import 'dart:io';
import 'package:dio/dio.dart';
import 'base_api_service.dart';

class TankerService extends BaseApiService {
  
  // Get all tankers
  Future<List<Map<String, dynamic>>> getAllTankers({
    String? status,
    String? tankerType,
    String? supplierId,
    String? driverId,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (tankerType != null) queryParams['tanker_type'] = tankerType;
    if (supplierId != null) queryParams['supplier_id'] = supplierId;
    if (driverId != null) queryParams['driver_id'] = driverId;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/tankers',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get tanker by ID
  Future<Map<String, dynamic>> getTankerById(String tankerId) async {
    final response = await get('/tankers/$tankerId');
    return response.data;
  }

  // Get available tankers
  Future<List<Map<String, dynamic>>> getAvailableTankers({
    String? location,
    String? tankerType,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final queryParams = <String, dynamic>{};
    if (location != null) queryParams['location'] = location;
    if (tankerType != null) queryParams['tanker_type'] = tankerType;
    if (latitude != null) queryParams['latitude'] = latitude;
    if (longitude != null) queryParams['longitude'] = longitude;
    if (radius != null) queryParams['radius'] = radius;

    final response = await get(
      '/tankers/available',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Create new tanker
  Future<Map<String, dynamic>> createTanker({
    required String supplierId,
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
    bool visibleToCustomer = true,
    String status = 'Available',
    double? latitude,
    double? longitude,
    File? rcDocument,
    File? insuranceDocument,
    File? fcDocument,
    File? npDocument,
  }) async {
    final formData = FormData.fromMap({
      'supplier_id': supplierId,
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
      'visible_to_customer': visibleToCustomer.toString(),
      'status': status,
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
    String? rcNumber,
    DateTime? rcExpiry,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? fcNumber,
    DateTime? fcExpiry,
    String? npNumber,
    DateTime? npExpiry,
    String? driverId,
    String? status,
    bool? visibleToCustomer,
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{};
    if (tankerNumber != null) data['tanker_number'] = tankerNumber;
    if (tankerType != null) data['tanker_type'] = tankerType;
    if (maxCapacity != null) data['max_capacity'] = maxCapacity;
    if (permissibleLimit != null) data['permissible_limit'] = permissibleLimit;
    if (rcNumber != null) data['rc_number'] = rcNumber;
    if (rcExpiry != null) data['rc_expiry'] = rcExpiry.toIso8601String();
    if (insuranceNumber != null) data['insurance_number'] = insuranceNumber;
    if (insuranceExpiry != null) data['insurance_expiry'] = insuranceExpiry.toIso8601String();
    if (fcNumber != null) data['fc_number'] = fcNumber;
    if (fcExpiry != null) data['fc_expiry'] = fcExpiry.toIso8601String();
    if (npNumber != null) data['np_number'] = npNumber;
    if (npExpiry != null) data['np_expiry'] = npExpiry.toIso8601String();
    if (driverId != null) data['driver_id'] = driverId;
    if (status != null) data['status'] = status;
    if (visibleToCustomer != null) data['visible_to_customer'] = visibleToCustomer;
    if (latitude != null) data['location.lat'] = latitude;
    if (longitude != null) data['location.lng'] = longitude;

    final response = await put('/tankers/$tankerId', data: data);
    return response.data;
  }

  // Update tanker status
  Future<Map<String, dynamic>> updateTankerStatus({
    required String tankerId,
    required String status,
    String? notes,
  }) async {
    final data = {'status': status};
    if (notes != null) data['notes'] = notes;

    final response = await put('/tankers/$tankerId/status', data: data);
    return response.data;
  }

  // Update tanker location
  Future<Map<String, dynamic>> updateTankerLocation({
    required String tankerId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await put(
      '/tankers/$tankerId/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return response.data;
  }

  // Assign driver to tanker
  Future<Map<String, dynamic>> assignDriverToTanker({
    required String tankerId,
    required String driverId,
  }) async {
    final response = await put(
      '/tankers/$tankerId/assign-driver',
      data: {'driver_id': driverId},
    );
    return response.data;
  }

  // Remove driver from tanker
  Future<Map<String, dynamic>> removeDriverFromTanker(String tankerId) async {
    final response = await put('/tankers/$tankerId/remove-driver');
    return response.data;
  }

  // Delete tanker
  Future<void> deleteTanker(String tankerId) async {
    await delete('/tankers/$tankerId');
  }

  // Get tanker history
  Future<List<Map<String, dynamic>>> getTankerHistory(String tankerId) async {
    final response = await get('/tankers/$tankerId/history');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get tanker documents
  Future<List<Map<String, dynamic>>> getTankerDocuments(String tankerId) async {
    final response = await get('/tankers/$tankerId/documents');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Upload tanker document
  Future<Map<String, dynamic>> uploadTankerDocument({
    required String tankerId,
    required String documentType,
    required File document,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
    });

    formData.files.add(MapEntry(
      'document',
      await MultipartFile.fromFile(
        document.path,
        filename: document.path.split('/').last,
      ),
    ));

    final response = await postFormData(
      '/tankers/$tankerId/documents',
      formData: formData,
    );
    return response.data;
  }

  // Search tankers
  Future<List<Map<String, dynamic>>> searchTankers({
    String? query,
    String? status,
    String? tankerType,
    String? supplierId,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null) queryParams['q'] = query;
    if (status != null) queryParams['status'] = status;
    if (tankerType != null) queryParams['tanker_type'] = tankerType;
    if (supplierId != null) queryParams['supplier_id'] = supplierId;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/tankers/search',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get tanker statistics
  Future<Map<String, dynamic>> getTankerStatistics({
    String? supplierId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (supplierId != null) queryParams['supplier_id'] = supplierId;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await get(
      '/tankers/statistics',
      queryParameters: queryParams,
    );
    return response.data;
  }
}
