import '../models/home_models.dart';

@Deprecated('Use HomeApiService for live home data.')
class HomeMockService {
  Future<HomeDashboardModel> fetchDashboard() async {
    return HomeDashboardModel.initial;
  }
}
