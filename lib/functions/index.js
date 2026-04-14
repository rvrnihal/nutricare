const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/* ================= MEDICINE BACKEND ================= */

/**
 * Trigger when a medicine is added
 */
exports.onMedicineAdded = functions.firestore
  .document("medicines/{medicineId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    console.log("Medicine added:", data.name);

    return null;
  });

/**
 * Detect missed dose (30 mins after schedule)
 */
exports.detectMissedDose = functions.pubsub
  .schedule("every 30 minutes")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const snapshot = await db
      .collection("medicines")
      .where("taken", "==", false)
      .where("scheduledAt", "<", now)
      .get();

    snapshot.forEach(async (doc) => {
      const med = doc.data();

      console.log("Missed dose:", med.name);

      // Here you can:
      // 1. Send notification
      // 2. Update status
      // 3. Log analytics
    });

    return null;
  });
