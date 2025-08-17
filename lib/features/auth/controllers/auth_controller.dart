import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_inc_authapp/core/providers/firebase_provider.dart';
import 'package:smart_inc_authapp/features/auth/data/auth_repositary.dart';

/// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
});

/// Auth operations + loading/error status using AsyncValue
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Keep current user in state if needed
    return ref.read(firebaseAuthProvider).currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email, password);
      state = AsyncData(user);
      // OPTIONAL: set SharedPreferences isLoggedIn here if you still want it.
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(email, password);
      state = AsyncData(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
