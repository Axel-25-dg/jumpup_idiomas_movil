import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/auth/feedback_service.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return const FeedbackService();
});

class FeedbackNotifier extends StateNotifier<AsyncValue<void>> {
  FeedbackNotifier(this._service) : super(const AsyncValue.data(null));

  final FeedbackService _service;

  Future<void> sendSuggestion({
    required String message,
    String? category,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.sendSuggestion(
          message: message,
          category: category,
        ));
  }
}

final feedbackNotifierProvider =
    StateNotifierProvider<FeedbackNotifier, AsyncValue<void>>((ref) {
  return FeedbackNotifier(ref.watch(feedbackServiceProvider));
});
