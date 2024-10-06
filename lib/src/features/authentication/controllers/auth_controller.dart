import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/firebase/firebase_auth_service.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _firebaseService = FirebaseAuthService();
  final RxBool isLoading = false.obs;

  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      await _firebaseService.signUp(email, password);
      Get.offAllNamed(AppRoutes.rooms);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      await _firebaseService.signIn(email, password);
      Get.offAllNamed(AppRoutes.rooms);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  User? get currentUser => _firebaseService.currentUser;
}
