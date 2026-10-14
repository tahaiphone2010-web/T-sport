const admin = require('firebase-admin');
const functions = require('firebase-functions');
const {
  generateSlotId,
  isSlotWithinOperatingHours,
  calculateSlotEnd,
  LOCK_DURATION_MS,
  toMillis,
} = require('./slotUtils');

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Authoritative 5-Minute Atomic Slot Lock Acquisition
 * Prevents race conditions and double-booking across concurrent players.
 */
async function acquireSlotLockHandler(data, context, injectedDb) {
  const userId = context?.auth?.uid;
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHORIZED');
  }

  const { venueId, courtId, scheduleDate, slotStart } = data || {};
  if (!venueId || !courtId || !scheduleDate || !slotStart) {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_SLOT_ARGUMENTS');
  }

  if (!isSlotWithinOperatingHours(slotStart)) {
    throw new functions.https.HttpsError('failed-precondition', 'OUTSIDE_OPERATING_HOURS');
  }

  let lockId;
  try {
    lockId = generateSlotId(venueId, courtId, scheduleDate, slotStart);
  } catch (err) {
    throw new functions.https.HttpsError('invalid-argument', err.message);
  }

  const calculatedEnd = data.slotEnd || calculateSlotEnd(slotStart);
  const db = injectedDb || admin.firestore();
  const lockRef = db.collection('locks').doc(lockId);
  const bookingRef = db.collection('bookings').doc(lockId);

  try {
    const lockResult = await db.runTransaction(async (transaction) => {
      const lockDoc = await transaction.get(lockRef);
      const bookingDoc = await transaction.get(bookingRef);

      const serverNow = admin.firestore.Timestamp.now();

      // 1. Check if slot already has a permanent booking or manager cash block
      if (bookingDoc.exists) {
        const bookingData = bookingDoc.data();
        const status = bookingData.status;
        if (status === 'confirmed' || status === 'completed' || status === 'blocked_cash') {
          throw new functions.https.HttpsError('aborted', 'SLOT_ALREADY_BOOKED');
        }
      }

      // 2. Check if locked by another user and lock is still unexpired
      if (lockDoc.exists) {
        const lockData = lockDoc.data();
        const lockExpiryMillis = toMillis(lockData.expiresAt);
        const nowMillis = toMillis(serverNow);

        if (lockExpiryMillis > nowMillis && lockData.userId !== userId && lockData.status === 'active') {
          throw new functions.https.HttpsError('aborted', 'SLOT_LOCKED');
        }
      }

      // 3. Atomically acquire/renew lock (authoritative 5 minutes)
      const expiresAt = admin.firestore.Timestamp.fromMillis(toMillis(serverNow) + LOCK_DURATION_MS);

      transaction.set(lockRef, {
        lockId,
        venueId: String(venueId),
        courtId: String(courtId),
        scheduleDate: String(scheduleDate),
        slotStart: String(slotStart),
        slotEnd: String(calculatedEnd),
        userId,
        status: 'active',
        expiresAt,
        createdAt: serverNow,
        updatedAt: serverNow,
      });

      return {
        lockId,
        expiresAt: expiresAt.toDate().toISOString(),
        expiresAtMillis: expiresAt.toMillis(),
      };
    });

    return lockResult;
  } catch (error) {
    if (error instanceof functions.https.HttpsError || error.code) {
      throw error;
    }
    console.error(`Lock failed for ${lockId} by ${userId}:`, error);
    throw new functions.https.HttpsError('internal', 'INTERNAL_LOCK_ERROR');
  }
}

exports.acquireSlotLock = functions.https.onCall(async (data, context) => {
  return acquireSlotLockHandler(data, context);
});

exports.acquireSlotLockHandler = acquireSlotLockHandler;
