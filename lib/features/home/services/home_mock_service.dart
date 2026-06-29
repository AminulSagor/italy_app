import 'package:get/get.dart';
import '../models/home_models.dart';

class HomeMockService {
  Future<HomeDashboardModel> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return HomeDashboardModel(
      user: HomeUserModel(
        greeting: 'Benvenuto,',
        displayName: 'Ciao, Arif!',
        streakLabel: '21d',
        notificationCount: 1,
        messageCount: 2,
      ),
      overview: HomeOverviewModel(
        title: 'gen_daily_overview'.tr.tr,
        subtitle: 'gen_your_learning_activity_this_we'.tr.tr,
        totalTime: '14.5h',
        totalTimeLabel: 'TOTAL TIME',
        activities: <HomeActivityModel>[
          HomeActivityModel(
            dayLabel: 'M',
            trackHeight: 82,
            valueHeight: 31,
            isSelected: false,
            tone: HomeActivityTone.soft,
          ),
          HomeActivityModel(
            dayLabel: 'T',
            trackHeight: 108,
            valueHeight: 76,
            isSelected: false,
            tone: HomeActivityTone.soft,
          ),
          HomeActivityModel(
            dayLabel: 'W',
            trackHeight: 130,
            valueHeight: 124,
            isSelected: true,
            tone: HomeActivityTone.primary,
          ),
          HomeActivityModel(
            dayLabel: 'T',
            trackHeight: 96,
            valueHeight: 58,
            isSelected: false,
            tone: HomeActivityTone.lime,
          ),
          HomeActivityModel(
            dayLabel: 'F',
            trackHeight: 122,
            valueHeight: 105,
            isSelected: false,
            tone: HomeActivityTone.soft,
          ),
          HomeActivityModel(
            dayLabel: 'S',
            trackHeight: 55,
            valueHeight: 16,
            isSelected: false,
            tone: HomeActivityTone.lime,
          ),
          HomeActivityModel(
            dayLabel: 'S',
            trackHeight: 70,
            valueHeight: 7,
            isSelected: false,
            tone: HomeActivityTone.muted,
          ),
        ],
      ),
      currentChapter: HomeChapterModel(
        eyebrow: 'CURRENT CHAPTER',
        title: 'gen_capitolo_2_saluti_n_greetings'.tr.tr,
        progressLabel: 'Progress',
        progress: 0.6,
        buttonLabel: 'Continue Lesson',
      ),
      quickTools: <HomeToolModel>[
        HomeToolModel(
          title: 'CV Builder',
          subtitle: 'gen_takes_2_mins'.tr.tr,
          iconKey: 'document',
          tone: HomeToolTone.blue,
        ),
        HomeToolModel(
          title: 'gen_caf_services'.tr.tr,
          subtitle: 'gen_tax_legal_help'.tr.tr,
          iconKey: 'gavel',
          tone: HomeToolTone.orange,
        ),
      ],
      workItems: <HomeWorkItemModel>[
        HomeWorkItemModel(title: 'gen_restaurant_job'.tr.tr, emoji: '🍽️'),
        HomeWorkItemModel(title: 'gen_order_coffee'.tr.tr, emoji: '☕'),
        HomeWorkItemModel(title: 'gen_find_housing'.tr.tr, emoji: '🏠'),
      ],
      support: HomeSupportModel(title: 'gen_need_help'.tr.tr, subtitle: 'gen_join_community'.tr.tr),
      webinar: HomeWebinarModel(
        badgeLabel: 'UPCOMING WEBINAR',
        title: 'gen_greeting_in_italia'.tr.tr,
        hostName: 'Mr. Devson',
        timeLabel: 'Today, 04:30 PM',
        buttonLabel: 'Join',
      ),
      culturalTip: HomeInfoCardModel(
        eyebrow: 'Cultural Tip of the Day',
        title: 'gen_cultural_tip_of_the_day'.tr.tr,
        body:
            'In Italy, coffee is often standing at the bar. Saying “Un caffè, per favore” is the first step to your morning routine.',
        actionLabel: '',
      ),
      streak: HomeInfoCardModel(
        eyebrow: '',
        title: 'gen_14_day_streak'.tr.tr,
        body: 'Keep it up!',
        actionLabel: '',
      ),
      aiTutor: HomeInfoCardModel(
        eyebrow: 'AI TUTOR',
        title: 'gen_master_italian_nthrough_natura'.tr.tr,
        body:
            'Practice ordering coffee or discussing art with your friendly virtual guide.',
        actionLabel: 'Start Chatting',
      ),
      dailyChallenges: HomeDailyChallengesModel(
        label: 'gen_daily_challenges_1'.tr.tr,
        completed: 2,
        total: 3,
      ),
    );
  }
}
