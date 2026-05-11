import '../models/home_models.dart';

class HomeMockService {
  Future<HomeDashboardModel> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return const HomeDashboardModel(
      user: HomeUserModel(
        greeting: 'Benvenuto,',
        displayName: 'Ciao, Arif!',
        streakLabel: '21d',
        notificationCount: 1,
        messageCount: 2,
      ),
      overview: HomeOverviewModel(
        title: 'Daily Overview',
        subtitle: 'Your learning activity this week',
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
        title: 'Capitolo 2: Saluti\n(Greetings)',
        progressLabel: 'Progress',
        progress: 0.6,
        buttonLabel: 'Continue Lesson',
      ),
      quickTools: <HomeToolModel>[
        HomeToolModel(
          title: 'CV Builder',
          subtitle: 'Takes 2 mins',
          iconKey: 'document',
          tone: HomeToolTone.blue,
        ),
        HomeToolModel(
          title: 'CAF Services',
          subtitle: 'Tax & Legal Help',
          iconKey: 'gavel',
          tone: HomeToolTone.orange,
        ),
      ],
      workItems: <HomeWorkItemModel>[
        HomeWorkItemModel(title: 'Restaurant Job', emoji: '🍽️'),
        HomeWorkItemModel(title: 'Order Coffee', emoji: '☕'),
        HomeWorkItemModel(title: 'Find Housing', emoji: '🏠'),
      ],
      support: HomeSupportModel(title: 'Need Help?', subtitle: 'Join Community'),
      webinar: HomeWebinarModel(
        badgeLabel: 'UPCOMING WEBINAR',
        title: 'Greeting In Italia',
        hostName: 'Mr. Devson',
        timeLabel: 'Today, 04:30 PM',
        buttonLabel: 'Join',
      ),
      culturalTip: HomeInfoCardModel(
        eyebrow: 'Cultural Tip of the Day',
        title: 'Cultural Tip of the Day',
        body:
            'In Italy, coffee is often standing at the bar. Saying “Un caffè, per favore” is the first step to your morning routine.',
        actionLabel: '',
      ),
      streak: HomeInfoCardModel(
        eyebrow: '',
        title: '14 Day Streak',
        body: 'Keep it up!',
        actionLabel: '',
      ),
      aiTutor: HomeInfoCardModel(
        eyebrow: 'AI TUTOR',
        title: 'Master Italian\nthrough natural\nconversations.',
        body:
            'Practice ordering coffee or discussing art with your friendly virtual guide.',
        actionLabel: 'Start Chatting',
      ),
      dailyChallenges: HomeDailyChallengesModel(
        label: 'DAILY CHALLENGES',
        completed: 2,
        total: 3,
      ),
    );
  }
}
