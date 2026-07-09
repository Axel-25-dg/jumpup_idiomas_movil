import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/data/repository/auth/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return const DashboardService();
});

final userProfileProvider = FutureProvider<UserProfileModel>((ref) async {
  return ref.watch(dashboardServiceProvider).getProfile();
});

final dashboardSummaryProvider =
    FutureProvider<DashboardSummaryModel>((ref) async {
  return ref.watch(dashboardServiceProvider).getDashboardSummary();
});

class ProfileUpdateNotifier
    extends StateNotifier<AsyncValue<UserProfileModel?>> {
  ProfileUpdateNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  final DashboardService _service;
  final Ref _ref;

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedProfile = await _service.updateProfile(data);
      _ref.invalidate(userProfileProvider);
      return updatedProfile;
    });
  }
}

final profileUpdateNotifierProvider =
    StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<UserProfileModel?>>(
        (ref) {
  return ProfileUpdateNotifier(ref.watch(dashboardServiceProvider), ref);
});
