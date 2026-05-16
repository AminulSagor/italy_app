import '../models/message_models.dart';

class MessagesMockService {
  final Set<String> _blockedThreadIds = <String>{};

  Future<MessagesResponseModel> fetchMessages() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    return const MessagesResponseModel(
      currentUserName: 'Alex Rivera',
      currentUserAvatarUrl: 'https://i.pravatar.cc/120?img=11',
      threads: <MessageThreadModel>[
        MessageThreadModel(
          id: 'luca-rossi',
          learnerName: 'Luca Rossi',
          lastMessage: "Hai finito l'esercizio di ieri?",
          timeLabel: '10:45 AM',
          unreadCount: 2,
          isOnline: true,
          isHighlighted: true,
          isDelivered: false,
          avatarUrl: 'https://i.pravatar.cc/120?img=47',
        ),
        MessageThreadModel(
          id: 'giulia-bianchi',
          learnerName: 'Giulia Bianchi',
          lastMessage: 'La pizza è incredibile!',
          timeLabel: '9:12 AM',
          unreadCount: 0,
          isOnline: true,
          isHighlighted: false,
          isDelivered: true,
          avatarUrl: 'https://i.pravatar.cc/120?img=32',
        ),
        MessageThreadModel(
          id: 'marco-galli-1',
          learnerName: 'Marco Galli',
          lastMessage: 'Can we practice the past tense?',
          timeLabel: 'YESTERDAY',
          unreadCount: 0,
          isOnline: false,
          isHighlighted: false,
          isDelivered: false,
          avatarUrl: 'https://i.pravatar.cc/120?img=59',
        ),
        MessageThreadModel(
          id: 'sofia-conti',
          learnerName: 'Sofia Conti',
          lastMessage: 'Ti ho inviato i nuovi appunti',
          timeLabel: 'TUE',
          unreadCount: 1,
          isOnline: true,
          isHighlighted: true,
          isDelivered: false,
          avatarUrl: 'https://i.pravatar.cc/120?img=45',
        ),
        MessageThreadModel(
          id: 'marco-galli-2',
          learnerName: 'Marco Galli',
          lastMessage: 'Can we practice the past tense?',
          timeLabel: 'YESTERDAY',
          unreadCount: 0,
          isOnline: false,
          isHighlighted: false,
          isDelivered: false,
          avatarUrl: 'https://i.pravatar.cc/120?img=59',
        ),
      ],
    );
  }

  Future<MessageChatModel> fetchChat(MessageThreadModel thread) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));

    return MessageChatModel(
      contactName: thread.learnerName == 'Luca Rossi'
          ? 'Elena'
          : thread.learnerName,
      contactStatus: thread.isOnline ? 'Online' : 'Offline',
      contactAvatarUrl: thread.learnerName == 'Luca Rossi'
          ? 'https://i.pravatar.cc/160?img=48'
          : thread.avatarUrl,
      isOnline: thread.isOnline,
      messages: const <MessageChatItemModel>[
        MessageChatItemModel(
          id: 'm1',
          text:
              'Ciao! How is your Italian practice going today? Pronta per la lezione di oggi?',
          timeLabel: '10:24 AM',
          statusLabel: '',
          isMine: false,
        ),
        MessageChatItemModel(
          id: 'm2',
          text:
              "Ciao Elena! Sì, sono pronta. I've been practicing the past tense all morning! 🇮🇹",
          timeLabel: '10:30 AM',
          statusLabel: 'Seen',
          isMine: true,
        ),
        MessageChatItemModel(
          id: 'm3',
          text:
              "Perfect! That really helps with the rolling 'R' sound. Grazie mille!",
          timeLabel: '10:30 AM',
          statusLabel: 'Delivered',
          isMine: true,
        ),
      ],
    );
  }

  Future<MessageUserProfileModel> fetchUserProfile(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 380));

    return MessageUserProfileModel(
      name: 'Alex Rivera',
      statusLabel: 'ONLINE',
      avatarUrl: 'https://i.pravatar.cc/180?img=11',
      streakValue: '45 Days',
      xpValue: '12,450 XP',
      isBlocked: _blockedThreadIds.contains(threadId),
    );
  }

  Future<MessageUserProfileModel> blockUser(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    _blockedThreadIds.add(threadId);
    return fetchUserProfile(threadId);
  }

  Future<MessageUserProfileModel> unblockUser(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    _blockedThreadIds.remove(threadId);
    return fetchUserProfile(threadId);
  }

  Future<MessageReportResultModel> submitReport(
    MessageReportRequestModel request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 620));

    return const MessageReportResultModel(
      referenceId: '#SHK-REP-4922',
      statusLabel: 'Under Review',
      reviewSteps: <String>[
        'Our team has been notified',
        'Manual review is in progress',
        'You will be notified once a decision is made',
      ],
    );
  }
}
