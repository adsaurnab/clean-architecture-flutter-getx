import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/gap_constants.dart';
import '../../../home/presentation/components/widgets/error_state.dart';
import '../components/widgets/avatar.dart';
import '../components/widgets/info_card.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () {},
          ),
          gapW4,
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return ErrorState(
            message: controller.error.value!,
            onRetry: controller.loadProfile,
          );
        }

        final profile = controller.profile.value;
        if (profile == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              gapH16,

              Avatar(
                imageUrl: profile.image,
                name: profile.name,
                colorScheme: colorScheme,
              ),
              gapH16,
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              gapH4,
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              gapH32,

              InfoCard(
                colorScheme: colorScheme,
                items: [
                  InfoItem(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: profile.email,
                  ),
                  InfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phone,
                  ),
                ],
              ),
              gapH16,

              InfoCard(
                colorScheme: colorScheme,
                items: [
                  InfoItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    value: 'Manage',
                  ),
                  InfoItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Privacy',
                    value: 'View',
                  ),
                  InfoItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & support',
                    value: '',
                  ),
                ],
              ),
              gapH16,

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              gapH32,
            ],
          ),
        );
      }),
    );
  }
}
