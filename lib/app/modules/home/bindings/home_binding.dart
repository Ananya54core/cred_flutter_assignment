import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/bill_repository.dart';
import '../controllers/home_controller.dart';

/// Binding for the Home module.
/// Lazy-puts ApiService → BillRepository → HomeController.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<BillRepository>(
      () => BillRepository(apiService: Get.find<ApiService>()),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(repository: Get.find<BillRepository>()),
    );
  }
}
