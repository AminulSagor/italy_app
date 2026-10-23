import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/features/practice_hub/models/daily_challenge_models.dart';

void main() {
  test('daily challenge task keeps backend completion details', () {
    final DailyChallengeTaskModel task =
        DailyChallengeTaskModel.fromJson(<String, dynamic>{
          'id': 'task-1',
          'taskKey': 'learn_new_words',
          'title': 'Learn 5 New Words',
          'details': 'Open Vocabulary and review five new words.',
          'targetValue': 5,
          'progressValue': 2,
          'rewardXp': 10,
          'status': 'in_progress',
        });

    expect(task.details, 'Open Vocabulary and review five new words.');
    expect(task.toJson()['details'], task.details);
  });
}
