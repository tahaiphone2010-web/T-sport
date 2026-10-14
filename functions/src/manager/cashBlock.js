const admin = require('firebase-admin');
const functions = require('firebase-functions');
const { generateSlotId, isSlotWithinOperatingHours, calculateSlotEnd, toMillis } = require('../slots/slotUtils');

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Validates if the authenticated caller is a verified manager of the venue.
 */
async function verifyManagerPermission(db, managerUid, venueId) {
  // Check venueManagers/{managerUid}/venues/{venueId}
  const managerVenueRef = db
    .collection('venueManagers')
    .doc(managerUid)
    .collection('venues')
    .doc(venueId);

  const doc = await managerVenueRef.get();
  if (doc.exists) return true;

  // Also check top-level user role if managerUid is admin
  const userDoc = await db.collection('users').doc(managerUid).get();
  if (userDoc.exists && (userDoc.data().role === 'admin' || userDoc.data().role === 'venue_manager')) {
    return true;
  }
  return false;
}

/**
 * Authoritative Manager Cash Blocking Operation
 * Blocks a slot for walk-in cash players. Cannot overwrite confirmed bookings or active player locks.
 */
async function blockCashSlotHandler(data, context, injectedDb) {
  const managerUid = context?.auth?.uid;
  if (!managerUid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHORIZED');
  }

  const { venueId, courtId, scheduleDate, slotStart, reason = 'walk_in_cash' } = data || {};
  if (!venueId || !courtId || !scheduleDate || !slotStart) {
    throw new functions.https.HttpsError('invalid-argument', 'MISSING_SLOT_ARGUMENTS');
  }

  if (!isSlotWithinOperatingHours(slotStart)) {
    throw new functions.https.HttpsError('failed-precondition', 'OUTSIDE_OPERATING_HOURS');
  }

  const db = injectedDb || admin.firestore();

  // Authorize manager
  const isAuthorized = await verifyManagerPermission(db, managerUid, String(venueId));
  if (!isAuthorized) {
    throw new functions.https.HttpsError('permission-denied', 'UNAUTHORIZED_VENUE_MANAGER');
  }

  const lockId = generateSlotId(venueId, courtId, scheduleDate, slotStart);
  const lockRef = db.collection('locks').doc(lockId);
  const bookingRef = db.collection('bookings').doc(lockId);
  const auditRef = db.collection('audit_logs').doc();

  try {
    const blockResult = await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      const lockDoc = await transaction.get(lockRef);
      const serverNow = admin.firestore.Timestamp.now();

      // 1. Conflict Check: Cannot overwrite confirmed booking
      if (bookingDoc.exists) {
        const bookingData = bookingDoc.data();
        if (bookingData.status === 'confirmed') {
          throw new functions.https.HttpsError('aborted', 'CANNOT_OVERWRITE_CONFIRMED_BOOKING');
        }
        if (bookingData.status === 'blocked_cash') {
          // Idempotent success
          return { slotId: lockId, status: 'blocked_cash', alreadyBlocked: true };
        }
      }

      // 2. Conflict Check: Cannot overwrite active player lock
      if (lockDoc.exists) {
        const lockData = lockDoc.data();
        const nowMillis = toMillis(serverNow);
        const expiryMillis = toMillis(lockData.expiresAt);
        if (expiryMillis > nowMillis && lockData.status === 'active') {
          throw new functions.https.HttpsError('aborted', 'SLOT_CURRENTLY_LOCKED_BY_PLAYER');
        }
      }

      // 3. Commit Cash Block
      transaction.set(bookingRef, {
        bookingId: lockId,
        venueId: String(venueId),
        courtId: String(courtId),
        scheduleDate: String(scheduleDate),
        slotStart: String(slotStart),
        slotEnd: calculateSlotEnd(slotStart),
        status: 'blocked_cash',
        blockedBy: managerUid,
        reason,
        createdAt: serverNow,
        updatedAt: serverNow,
      });

      // 4. Record Audit Log
      transaction.set(auditRef, {
        managerUid,
        venueId: String(venueId),
        courtId: String(courtId),
        slotId: lockId,
        action: 'BLOCK_CASH_SLOT',
        timestamp: serverNow,
        outcome: 'SUCCESS',
      });

      return { slotId: lockId, status: 'blocked_cash', alreadyBlocked: false };
    });

    return blockResult;
  } catch (error) {
    if (error instanceof functions.https.HttpsError || error.code) {
      throw error;
    }
    console.error(`Manager cash block failed for ${lockId}:`, error);
    throw new functions.https.HttpsError('internal', 'INTERNAL_BLOCK_ERROR');
  }
}

/**
 * Authoritative Manager Unblock Operation
 * Frees a previously cash-blocked slot back to availability.
 */
async function unblockCashSlotHandler(data, context, injectedDb) {
  const managerUid = context?.auth?.uid;
  if (!managerUid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHORIZED');
  }

  const { venueId, courtId, scheduleDate, slotStart } = data || {};
  if (!venueId || !courtId || !scheduleDate || !slotStart) {
    throw new functions.https.HttpsError('invalid-argument', 'MISSING_SLOT_ARGUMENTS');
  }

  const db = injectedDb || admin.firestore();

  const isAuthorized = await verifyManagerPermission(db, managerUid, String(venueId));
  if (!isAuthorized) {
    throw new functions.https.HttpsError('permission-denied', 'UNAUTHORIZED_VENUE_MANAGER');
  }

  const lockId = generateSlotId(venueId, courtId, scheduleDate, slotStart);
  const bookingRef = db.collection('bookings').doc(lockId);
  const auditRef = db.collection('audit_logs').doc();

  try {
    const unblockResult = await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      const serverNow = admin.firestore.Timestamp.now();

      if (!bookingDoc.exists) {
        return { slotId: lockId, status: 'available', message: 'SLOT_NOT_BLOCKED' };
      }

      const bookingData = bookingDoc.data();
      if (bookingData.status !== 'blocked_cash') {
        throw new functions.https.HttpsError('aborted', 'CANNOT_UNBLOCK_CONFIRMED_BOOKING');
      }

      // Delete cash-block or mark as cancelled to free slot
      transaction.delete(bookingRef);

      // Audit Log
      transaction.set(auditRef, {
        managerUid,
        venueId: String(venueId),
        courtId: String(courtId),
        slotId: lockId,
        action: 'UNBLOCK_CASH_SLOT',
        timestamp: serverNow,
        outcome: 'SUCCESS',
      });

      return { slotId: lockId, status: 'available', message: 'UNBLOCKED_SUCCESSFULLY' };
    });

    return unblockResult;
  } catch (error) {
    if (error instanceof functions.https.HttpsError || error.code) {
      throw error;
    }
    console.error(`Manager unblock failed for ${lockId}:`, error);
    throw new functions.https.HttpsError('internal', 'INTERNAL_UNBLOCK_ERROR');
  }
}

exports.blockCashSlot = functions.https.onCall(async (data, context) => {
  return blockCashSlotHandler(data, context);
});

exports.unblockCashSlot = functions.https.onCall(async (data, context) => {
  return unblockCashSlotHandler(data, context);
});

exports.blockCashSlotHandler = blockCashSlotHandler;
exports.unblockCashSlotHandler = unblockCashSlotHandler;
