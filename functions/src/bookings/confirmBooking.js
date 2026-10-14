const admin = require('firebase-admin');
const functions = require('firebase-functions');
const { generateBookingReference, toMillis } = require('../slots/slotUtils');

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Authoritative Booking Confirmation Operation
 * Transitions an active unexpired 5-minute lock into a confirmed booking.
 * Idempotent: repeated calls for the same lock return the confirmed booking.
 */
async function confirmBookingHandler(data, context, injectedDb) {
  const userId = context?.auth?.uid;
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHORIZED');
  }

  const { lockId, paymentMethod = 'cash', amount } = data || {};
  if (!lockId) {
    throw new functions.https.HttpsError('invalid-argument', 'MISSING_LOCK_ID');
  }

  const db = injectedDb || admin.firestore();
  const lockRef = db.collection('locks').doc(lockId);
  const bookingRef = db.collection('bookings').doc(lockId);

  try {
    const confirmationResult = await db.runTransaction(async (transaction) => {
      const lockDoc = await transaction.get(lockRef);
      const bookingDoc = await transaction.get(bookingRef);

      const serverNow = admin.firestore.Timestamp.now();

      // 1. Idempotency check: If already confirmed by the same user, return existing confirmation
      if (bookingDoc.exists) {
        const bookingData = bookingDoc.data();
        if (bookingData.status === 'confirmed') {
          if (bookingData.userId === userId) {
            return {
              bookingId: bookingDoc.id,
              reference: bookingData.reference,
              status: 'confirmed',
              alreadyConfirmed: true,
            };
          } else {
            throw new functions.https.HttpsError('aborted', 'SLOT_ALREADY_BOOKED');
          }
        }
        if (bookingData.status === 'blocked_cash') {
          throw new functions.https.HttpsError('aborted', 'SLOT_BLOCKED_BY_VENUE');
        }
      }

      // 2. Validate lock existence and ownership
      if (!lockDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'LOCK_NOT_FOUND');
      }

      const lockData = lockDoc.data();
      if (lockData.userId !== userId) {
        throw new functions.https.HttpsError('permission-denied', 'LOCK_OWNED_BY_ANOTHER_USER');
      }

      // 3. Validate lock expiration (Server-authoritative boundary: now >= expiresAt means expired)
      const nowMillis = toMillis(serverNow);
      const expiryMillis = toMillis(lockData.expiresAt);
      if (nowMillis >= expiryMillis) {
        throw new functions.https.HttpsError('aborted', 'LOCK_EXPIRED');
      }

      if (lockData.status !== 'active') {
        throw new functions.https.HttpsError('aborted', 'LOCK_NOT_ACTIVE');
      }

      // 4. Generate unique business reference
      const reference = generateBookingReference(lockData.scheduleDate);

      // 5. Commit confirmed booking atomically
      transaction.set(bookingRef, {
        bookingId: lockId,
        reference,
        userId,
        venueId: lockData.venueId,
        courtId: lockData.courtId,
        scheduleDate: lockData.scheduleDate,
        slotStart: lockData.slotStart,
        slotEnd: lockData.slotEnd,
        amount: Number(amount) || 0,
        paymentMethod: String(paymentMethod).toLowerCase(),
        status: 'confirmed',
        createdAt: serverNow,
        updatedAt: serverNow,
      });

      // 6. Mark lock as consumed to prevent reuse
      transaction.update(lockRef, {
        status: 'consumed',
        bookingReference: reference,
        consumedAt: serverNow,
      });

      return {
        bookingId: lockId,
        reference,
        status: 'confirmed',
        alreadyConfirmed: false,
      };
    });

    return confirmationResult;
  } catch (error) {
    if (error instanceof functions.https.HttpsError || error.code) {
      throw error;
    }
    console.error(`Booking confirmation failed for ${lockId}:`, error);
    throw new functions.https.HttpsError('internal', 'INTERNAL_CONFIRMATION_ERROR');
  }
}

exports.confirmBooking = functions.https.onCall(async (data, context) => {
  return confirmBookingHandler(data, context);
});

exports.confirmBookingHandler = confirmBookingHandler;
