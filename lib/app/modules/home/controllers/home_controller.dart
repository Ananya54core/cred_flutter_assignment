import 'package:get/get.dart';
import '../../../data/exceptions/network_exception.dart';
import '../../../data/models/bill_section_model.dart';
import '../../../data/repositories/bill_repository.dart';

/// Controller for the Home screen.
/// Manages bill fetching state and API toggling.
class HomeController extends GetxController {
  final BillRepository repository;

  HomeController({required this.repository});

  // Observable state
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final billSection = Rxn<BillSectionModel>();

  // Track which API is active (false = mock1/2 items, true = mock2/9 items)
  final isUsingMock2 = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBills();
  }

  /// Current API URL based on toggle state.
  String get _currentUrl =>
      isUsingMock2.value ? BillRepository.mock2Url : BillRepository.mock1Url;

  /// Fetch bills from the current API endpoint.
  Future<void> fetchBills() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.fetchBills(_currentUrl);
      billSection.value = result;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle between mock1 (2 items) and mock2 (9 items) APIs.
  void switchApi() {
    isUsingMock2.value = !isUsingMock2.value;
    fetchBills();
  }
}
