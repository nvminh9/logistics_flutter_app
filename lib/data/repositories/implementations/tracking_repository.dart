import 'package:nalogistics_app/core/constants/api_constants.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';

class TrackingRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _apiClient.post(
      ApiConstants.trackingLocation,
      body: {'lattitude': latitude, 'longitude': longitude},
      requiresAuth: true,
    );
  }
}
