import 'package:get/get.dart';

import '../service/user_block_api_service.dart';
import '../models/user_block_models.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../services/chat_socket_service.dart';

class UserBlockController extends GetxController {
  UserBlockController({required UserBlockApiService apiService})
    : _apiService = apiService;

  final UserBlockApiService _apiService;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxList<UserListItemModel> users = <UserListItemModel>[].obs;
  final RxList<BlockedUserItemModel> blockedUsers =
      <BlockedUserItemModel>[].obs;
  final RxString blockStatus = 'none'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  Future<void> loadUser(String id) async {
    isLoading.value = true;
    try {
      final ApiHandledResponse<UserModel> res = await _apiService.getUser(id);
      if (res.success && res.data != null) {
        user.value = res.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUsers({
    required String q,
    int page = 1,
    int perPage = 20,
  }) async {
    isLoading.value = true;
    try {
      final ApiHandledResponse<UserSearchResponseModel> res = await _apiService
          .searchByName(q: q, page: page, perPage: perPage);
      if (res.success && res.data != null) {
        users.assignAll(
          res.data!.items.map(
            (e) => UserListItemModel(
              id: e.id,
              fullName: e.fullName,
              email: e.email,
              phone: e.phone,
              isOnline: e.isOnline,
              lastSeenAt: e.lastSeenAt,
            ),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllUsers() async {
    isLoading.value = true;
    try {
      final ApiHandledResponse<List<UserListItemModel>> res = await _apiService
          .getAllUsers();
      if (res.success && res.data != null) {
        users.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBlockStatus(String otherUserId) async {
    final ApiHandledResponse<BlockStatusModel> res = await _apiService
        .getBlockStatus(otherUserId);
    if (res.success && res.data != null) {
      blockStatus.value = res.data!.status;
    }
  }

  Future<bool> blockUser(String blockedId) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      final ApiHandledResponse<UserBlockModel> res = await _apiService
          .blockUser(blockedId);
      if (res.success && res.data != null) {
        // update blocked users list optimistically
        blockedUsers.insert(
          0,
          BlockedUserItemModel(
            blockedUserId: res.data!.blockedId,
            fullName: '',
            email: '',
            phone: null,
            blockedAt: res.data!.createdAt,
          ),
        );
        blockStatus.value = 'blocked_by_me';
        
        // Notify socket so all views (Chat, Messages list, User Info) update immediately
        try {
          if (Get.isRegistered<ChatSocketService>()) {
            Get.find<ChatSocketService>().emitUserBlockChange(
              userId: blockedId,
              status: 'blocked_by_me',
            );
          }
        } catch (_) {}

        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> unblockUser(String blockedId) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      final ApiHandledResponse<void> res = await _apiService.unblockUser(
        blockedId,
      );
      if (res.success) {
        blockedUsers.removeWhere(
          (element) => element.blockedUserId == blockedId,
        );
        blockStatus.value = 'none';

        // Notify socket so all views (Chat, Messages list, User Info) update immediately
        try {
          if (Get.isRegistered<ChatSocketService>()) {
            Get.find<ChatSocketService>().emitUserBlockChange(
              userId: blockedId,
              status: 'none',
            );
          }
        } catch (_) {}

        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchBlockedUsers() async {
    isLoading.value = true;
    try {
      final ApiHandledResponse<List<BlockedUserItemModel>> res =
          await _apiService.getBlockedUsers();
      if (res.success && res.data != null) {
        blockedUsers.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
