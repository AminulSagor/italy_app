import '../models/ message_call_models.dart';


class MessageCallMockService {
  Future<MessageCallSessionModel> startCall({
    required String conversationId,
    required MessageCallType callType,
    required MessageCallParticipantModel participant,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return MessageCallSessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      type: callType,
      participant: participant,
      startedAt: DateTime.now(),
    );
  }

  Future<void> endCall({required String callId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}