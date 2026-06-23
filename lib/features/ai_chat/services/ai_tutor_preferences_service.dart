import 'package:get/get.dart';

import '../models/ai_tutor_level_test_models.dart';

/// In-memory cache only. The NestJS backend is the source of truth.
class AiTutorPreferencesService extends GetxService {
  final Rxn<AiTutorLearnerProfileModel> learnerProfile =
      Rxn<AiTutorLearnerProfileModel>();

  void setProfile(AiTutorLearnerProfileModel profile) {
    learnerProfile.value = profile;
  }

  void clearProfile() {
    learnerProfile.value = null;
  }
}
