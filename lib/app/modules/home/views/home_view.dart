import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets.dart';
import '../../../widgets/vertical_stack_carousel.dart';

/// Home screen — displays the section header and the vertical card carousel.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return const LoadingWidget();
          }

          // Error state
          if (controller.errorMessage.isNotEmpty) {
            return ErrorStateWidget(
              message: controller.errorMessage.value,
              onRetry: controller.fetchBills,
            );
          }

          final section = controller.billSection.value;
          if (section == null) {
            return const ErrorStateWidget(message: 'No data available.');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Section header: "UPCOMING BILLS (n)" + "view all >"
              SectionHeader(
                title: section.title,
                billsCount: section.billsCount,
              ),

              const SizedBox(height: 8),

              // Card carousel
              Expanded(
                child: VerticalStackCarousel(
                  cards: section.cards,
                ),
              ),

              // API toggle button (for testing both states)
              _buildApiToggle(),
            ],
          );
        }),
      ),
    );
  }

  /// Footer toggle to switch between mock1 (2 items) and mock2 (9 items).
  Widget _buildApiToggle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Obx(() {
          final isMock2 = controller.isUsingMock2.value;
          return GestureDetector(
            onTap: controller.switchApi,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                isMock2
                    ? 'Showing 9 items  ·  Tap for 2 items'
                    : 'Showing 2 items  ·  Tap for 9 items',
                style: TextStyle(
                  color: AppColors.textOnDark.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
