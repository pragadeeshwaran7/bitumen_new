import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/models/tracking.dart';
import '../../../core/services/tracking_service.dart' as api;

class TrackingApiService {
  static final TrackingApiService _instance = TrackingApiService._internal();
  factory TrackingApiService() => _instance;
  TrackingApiService._internal();

  final api.TrackingService _trackingService = api.TrackingService();

  final List<Tracking> _mockTrackingOrders = [
    Tracking(
      trackingId: 'TR123456789',
      status: 'In Transit',
      eta: '2 hrs 15 mins',
      pickup: 'Mumbai, Maharashtra',
      delivery: 'Pune, Maharashtra',
      updates: [
        'Pickup Point Confirmed',
        'Loading',
        'In Transit',
        'Reached Drop Point',
        'Unloading',
        'Delivered',
      ],
      gpsCoordinates: [
        LatLng(19.0760, 72.8777),
        LatLng(18.5204, 73.8567),
      ],
      cameraFeedUrl: 'https://example.com/mock-feed.mp4',
    ),
  ];

  Future<List<Tracking>> fetchTrackingOrders() async {
    try {
      // Try to fetch from real API first
      final orders = await _trackingService.getAllOrders();
      return orders.map((order) => _mapOrderToTracking(order)).toList();
    } catch (e) {
      // Fallback to mock data if API fails
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockTrackingOrders;
    }
  }

  Future<Tracking?> trackOrder(String orderId) async {
    try {
      final orderData = await _trackingService.trackOrder(orderId);
      return _mapOrderToTracking(orderData);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOrderLocationHistory(String orderId) async {
    try {
      return await _trackingService.getOrderLocationHistory(orderId);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentOrderLocation(String orderId) async {
    try {
      return await _trackingService.getCurrentOrderLocation(orderId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOrderLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      await _trackingService.updateOrderLocation(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    } catch (e) {
      // Handle error silently or log it
    }
  }

  Tracking _mapOrderToTracking(Map<String, dynamic> orderData) {
    return Tracking(
      trackingId: orderData['id']?.toString() ?? orderData['order_id']?.toString() ?? '',
      status: orderData['status'] ?? 'Unknown',
      eta: orderData['estimated_delivery'] ?? 'Calculating...',
      pickup: orderData['pickup_location'] ?? 'Unknown',
      delivery: orderData['delivery_location'] ?? 'Unknown',
      updates: List<String>.from(orderData['status_updates'] ?? []),
      gpsCoordinates: _extractCoordinates(orderData),
      cameraFeedUrl: orderData['camera_feed_url'],
    );
  }

  List<LatLng> _extractCoordinates(Map<String, dynamic> orderData) {
    final coordinates = <LatLng>[];
    
    // Extract from location history
    if (orderData['location_history'] != null) {
      final history = List<Map<String, dynamic>>.from(orderData['location_history']);
      for (final location in history) {
        final lat = location['latitude']?.toDouble();
        final lng = location['longitude']?.toDouble();
        if (lat != null && lng != null) {
          coordinates.add(LatLng(lat, lng));
        }
      }
    }
    
    // Add current location if available
    if (orderData['current_location'] != null) {
      final current = orderData['current_location'];
      final lat = current['latitude']?.toDouble();
      final lng = current['longitude']?.toDouble();
      if (lat != null && lng != null) {
        coordinates.add(LatLng(lat, lng));
      }
    }
    
    return coordinates;
  }
}
