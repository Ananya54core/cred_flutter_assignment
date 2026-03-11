import 'package:get/get.dart';
import '../../../data/exceptions/network_exception.dart';
import '../../../data/models/bill_section_model.dart';
import '../../../data/repositories/bill_repository.dart';

/// Controller for the Home screen.
/// Pre-fetches both API responses on init for instant toggling.
class HomeController extends GetxController {
  final BillRepository repository;

  HomeController({required this.repository});

  // Observable state
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final billSection = Rxn<BillSectionModel>();

  // Track which API is active (false = mock1/2 items, true = mock2/9 items)
  final isUsingMock2 = true.obs;

  // Cached responses for instant switching.
  BillSectionModel? _mock1Cache;
  BillSectionModel? _mock2Cache;

  @override
  void onInit() {
    super.onInit();
    _prefetchAll();
  }

  /// Fetch both APIs in parallel on startup; show the default one immediately.
  Future<void> _prefetchAll() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        repository.fetchBills(BillRepository.mock1Url),
        repository.fetchBills(BillRepository.mock2Url),
      ]);

      _mock1Cache = results[0];
      _mock2Cache = results[1];

      // Show the default state.
      billSection.value = isUsingMock2.value ? _mock2Cache : _mock1Cache;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry fetching both APIs.
  Future<void> fetchBills() async => _prefetchAll();

  /// Toggle between mock1 (2 items) and mock2 (9 items) — instant swap.
  void switchApi() {
    isUsingMock2.value = !isUsingMock2.value;
    billSection.value = isUsingMock2.value ? _mock2Cache : _mock1Cache;
  }
}
