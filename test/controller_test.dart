import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cred_assignment/app/data/models/bill_section_model.dart';
import 'package:cred_assignment/app/data/repositories/bill_repository.dart';
import 'package:cred_assignment/app/data/providers/api_service.dart';
import 'package:cred_assignment/app/data/exceptions/network_exception.dart';
import 'package:cred_assignment/app/modules/home/controllers/home_controller.dart';

// ─────────────────────────────────────────────────────────────
//  Manual mock — no code generation needed
// ─────────────────────────────────────────────────────────────

/// Stub [ApiService] that is never actually called.
class StubApiService extends ApiService {
  StubApiService();
}

/// A fake [BillRepository] that returns pre-set data or throws errors.
class FakeBillRepository extends BillRepository {
  BillSectionModel? mock1Response;
  BillSectionModel? mock2Response;
  Exception? errorToThrow;

  FakeBillRepository() : super(apiService: StubApiService());

  @override
  Future<BillSectionModel> fetchBills(String url) async {
    if (errorToThrow != null) throw errorToThrow!;

    if (url == BillRepository.mock1Url) {
      return mock1Response ?? _buildSection('MOCK1', 2);
    }
    return mock2Response ?? _buildSection('MOCK2', 9);
  }
}

/// Helper to build a minimal [BillSectionModel].
BillSectionModel _buildSection(String title, int cardCount) {
  return BillSectionModel.fromJson({
    'template_properties': {
      'body': {
        'title': title,
        'bills_count': '$cardCount',
      },
      'child_list': List.generate(
        cardCount,
        (i) => {
          'entity_type': 'card',
          'external_id': '${title}_card_$i',
          'template_properties': {
            'body': {
              'title': 'Card $i',
              'sub_title': 'Sub $i',
              'payment_amount': '₹${(i + 1) * 100}',
            },
          },
        },
      ),
    },
  });
}

void main() {
  late FakeBillRepository fakeRepo;
  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    fakeRepo = FakeBillRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController', () {
    test('sets billSection and loading state on successful fetch', () async {
      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
      expect(controller.billSection.value, isNotNull);
      // Default is mock2
      expect(controller.billSection.value!.title, 'MOCK2');
    });

    test('shows mock2 (9 items) by default', () async {
      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isUsingMock2.value, true);
      expect(controller.billSection.value!.cards.length, 9);
    });

    test('switchApi toggles between mock1 and mock2', () async {
      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      // Initially mock2 (9 items)
      expect(controller.billSection.value!.title, 'MOCK2');
      expect(controller.billSection.value!.cards.length, 9);

      // Switch to mock1
      controller.switchApi();
      expect(controller.isUsingMock2.value, false);
      expect(controller.billSection.value!.title, 'MOCK1');
      expect(controller.billSection.value!.cards.length, 2);

      // Switch back to mock2
      controller.switchApi();
      expect(controller.isUsingMock2.value, true);
      expect(controller.billSection.value!.title, 'MOCK2');
    });

    test('sets errorMessage on NetworkException', () async {
      fakeRepo.errorToThrow = NetworkException(message: 'No internet');

      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'No internet');
      expect(controller.billSection.value, isNull);
    });

    test('sets generic error on unexpected exception', () async {
      fakeRepo.errorToThrow = Exception('Something broke');

      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'An unexpected error occurred.');
    });

    test('fetchBills retries by calling _prefetchAll again', () async {
      // First: fail
      fakeRepo.errorToThrow = NetworkException(message: 'Timeout');
      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.errorMessage.value, 'Timeout');

      // Now: succeed on retry
      fakeRepo.errorToThrow = null;
      await controller.fetchBills();

      expect(controller.errorMessage.value, '');
      expect(controller.billSection.value, isNotNull);
    });

    test('switchApi is instant (uses cached data)', () async {
      controller = HomeController(repository: fakeRepo);
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));

      // Switch should be synchronous since data is cached
      final stopwatch = Stopwatch()..start();
      controller.switchApi();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10),
          reason: 'switchApi should be instant from cache');
      expect(controller.billSection.value!.title, 'MOCK1');
    });
  });
}
