import 'package:flutter_test/flutter_test.dart';
import 'package:nuticare/models/workout_model.dart';
import 'package:nuticare/providers/workout_provider.dart';

void main() {
  group('WorkoutProvider.stopWorkout', () {
    test('saves to user history and resets session on success', () async {
      String? capturedUserId;
      WorkoutSession? capturedSession;

      final provider = WorkoutProvider(
        currentUserIdProvider: () => 'user_123',
        saveWorkoutOverride: (userId, session) async {
          capturedUserId = userId;
          capturedSession = session;
        },
      );

      provider.startWorkout('HIIT');
      expect(provider.session, isNotNull);

      final result = await provider.stopWorkout();

      expect(result, isTrue);
      expect(capturedUserId, 'user_123');
      expect(capturedSession, isNotNull);
      expect(capturedSession!.status, WorkoutStatus.completed);
      expect(capturedSession!.endTime, isNotNull);
      expect(provider.session, isNull);
      expect(provider.seconds, 0);
      expect(provider.heartRateHistory, isEmpty);
    });

    test('returns false and keeps session when save fails', () async {
      final provider = WorkoutProvider(
        currentUserIdProvider: () => 'user_123',
        saveWorkoutOverride: (_, __) async {
          throw Exception('write failed');
        },
      );

      provider.startWorkout('Run');
      final activeSessionBefore = provider.session;

      final result = await provider.stopWorkout();

      expect(result, isFalse);
      expect(provider.session, same(activeSessionBefore));
      expect(provider.session!.status, WorkoutStatus.completed);
    });

    test('returns false when user is not logged in', () async {
      final provider = WorkoutProvider(
        currentUserIdProvider: () => null,
      );

      provider.startWorkout('Cycle');
      final result = await provider.stopWorkout();

      expect(result, isFalse);
      expect(provider.session, isNotNull);
    });
  });
}
