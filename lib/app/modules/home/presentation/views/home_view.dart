import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/gap_constants.dart';
import '../controllers/home_controller.dart';
import '../components/widgets/search_bar.dart';
import '../components/widgets/empty_state.dart';
import '../components/widgets/error_state.dart';
import '../components/widgets/loading_state.dart';
import '../components/widgets/product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [_buildAppBar(colorScheme), _buildBody(colorScheme)],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning 👋',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'Discover',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/profile'),
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person_rounded,
              size: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        gapW8,
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(child: LoadingState());
      }

      if (controller.error.value != null) {
        return SliverFillRemaining(
          child: ErrorState(
            message: controller.error.value!,
            onRetry: controller.loadProducts,
          ),
        );
      }

      if (controller.products.isEmpty) {
        return const SliverFillRemaining(child: EmptyState());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SearchBarWidget(colorScheme: colorScheme),
              );
            }
            final product = controller.products[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(product: product, colorScheme: colorScheme),
            );
          }, childCount: controller.products.length + 1),
        ),
      );
    });
  }
}
