import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/security/secure_storage.dart';
import '../core/security/token_manager.dart';
import '../core/storage/draft_storage.dart';
import '../shared/models/user_model.dart';
import '../shared/models/user_role.dart';

/// Global secure storage provider.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Token manager provider.
final tokenManagerProvider = Provider<TokenManager>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenManager(storage);
});

/// API Client provider with injected token manager.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return ApiClient(tokenManager: tokenManager);
});

/// Offline check-in draft storage provider.
final draftStorageProvider = Provider<DraftStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DraftStorage(storage);
});

/// Current authenticated user state management via Riverpod Notifier.
class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    return const UserModel(
      id: 'demo-user-101',
      email: 'participant@example.org',
      fullName: 'Demo Participant',
      role: UserRole.victim,
      preferredLanguage: 'en',
      activeCaseId: 'CASE-1042',
    );
  }

  void setUser(UserModel? user) => state = user;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, UserModel?>(CurrentUserNotifier.new);

/// Active app dark mode state management via Riverpod Notifier.
class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setDarkMode(bool value) => state = value;
}

final isDarkModeProvider =
    NotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);
