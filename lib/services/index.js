const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updateStreak = functions.firestore
  .document("users/{userId}/workouts/{workoutId}")
  .onCreate(async (snap, context) => {

    const userId = context.params.userId;
    const userRef = admin.firestore().collection("users").doc(userId);
    const userDoc = await userRef.get();

    const today = new Date().toDateString();
    const lastWorkout = userDoc.data().lastWorkoutDate;

    let streak = userDoc.data().streakCount || 0;

    if (lastWorkout !== today) {
      streak += 1;
    }

    await userRef.update({
      streakCount: streak,
      lastWorkoutDate: today
    });

    return null;
  });
  