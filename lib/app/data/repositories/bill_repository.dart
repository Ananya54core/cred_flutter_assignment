import '../models/bill_section_model.dart';
import '../providers/api_service.dart';
import '../exceptions/network_exception.dart';

/// Repository that sits between ApiService and the Controller.
/// Parses raw API responses into domain models.
class BillRepository {
  final ApiService apiService;

  BillRepository({required this.apiService});

  /// API endpoints
  static const String mock1Url = 'https://api.mocklets.com/p26/mock1';
  static const String mock2Url = 'https://api.mocklets.com/p26/mock2';

  /// Fetches bill section data from the given [url].
  /// Returns a parsed [BillSectionModel].
  /// Throws [NetworkException] on failure.
  Future<BillSectionModel> fetchBills(String url) async {
    try {
      final response = await apiService.get(url);

      if (response.data == null) {
        throw NetworkException(message: 'Empty response from server.');
      }

      final data = response.data as Map<String, dynamic>;
      return BillSectionModel.fromJson(data);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: 'Failed to parse bill data. Please try again.',
      );
    }
  }
}
