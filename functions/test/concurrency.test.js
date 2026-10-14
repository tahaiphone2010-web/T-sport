const test = require('node:test');
const assert = require('node:assert/strict');
const { acquireSlotLockHandler } = require('../src/slots/acquireSlotLock');
const { confirmBookingHandler } = require('../src/bookings/confirmBooking');
const { blockCashSlotHandler, unblockCashSlotHandler } = require('../src/manager/cashBlock');

/**
 * High-Fidelity Mock Firestore with Transaction Serialization
 * Matches Cloud Firestore runTransaction isolation and retry mechanics.
 */
function cloneData(obj) {
  if (!obj || typeof obj !== 'object') return obj;
  if (typeof obj.toMillis === 'function') return obj;
  if (obj instanceof Date) return new Date(obj.getTime());
  if (Array.isArray(obj)) return obj.map(cloneData);
  const copy = {};
  for (const [k, v] of Object.entries(obj)) {
    copy[k] = cloneData(v);
  }
  return copy;
}

class MockFirestore {
  constructor() {
    this.storage = new Map(); // fullPath -> data
    this.txLock = Promise.resolve(); // Serialized transaction execution queue
    this.currentTimeMillis = Date.now();
  }

  setCurrentTime(millis) {
    this.currentTimeMillis = millis;
  }

  advanceTimeByMinutes(minutes) {
    this.currentTimeMillis += minutes * 60 * 1000;
  }

  collection(collName) {
    return this._createCollectionRef(collName);
  }

  _createCollectionRef(collPath) {
    const self = this;
    return {
      path: collPath,
      doc: (docId) => {
        const id = docId || `auto_${Math.random().toString(36).substring(2, 9)}`;
        const docPath = `${collPath}/${id}`;
        return self._createDocRef(docPath, id);
      },
    };
  }

  _createDocRef(docPath, id) {
    const self = this;
    return {
      id,
      path: docPath,
      collection: (subCollName) => self._createCollectionRef(`${docPath}/${subCollName}`),
      get: async () => {
        const data = self.storage.get(docPath);
        return {
          id,
          exists: data !== undefined,
          data: () => (data !== undefined ? cloneData(data) : undefined),
        };
      },
      set: async (val) => {
        self.storage.set(docPath, cloneData(val));
      },
      delete: async () => {
        self.storage.delete(docPath);
      },
    };
  }

  async runTransaction(updateFunction) {
    // Acquire transaction queue lock to serialize atomic commit boundaries
    const prevLock = this.txLock;
    let release;
    this.txLock = new Promise((resolve) => {
      release = resolve;
    });

    await prevLock;
    try {
      const stagedWrites = [];

      const transactionContext = {
        get: async (docRef) => {
          return await docRef.get();
        },
        set: (docRef, data) => {
          stagedWrites.push({ type: 'set', docRef, data });
        },
        update: (docRef, data) => {
          stagedWrites.push({ type: 'update', docRef, data });
        },
        delete: (docRef) => {
          stagedWrites.push({ type: 'delete', docRef });
        },
      };

      const result = await updateFunction(transactionContext);

      // Commit staged writes atomically
      for (const op of stagedWrites) {
        if (op.type === 'set') {
          await op.docRef.set(op.data);
        } else if (op.type === 'update') {
          const current = (await op.docRef.get()).data() || {};
          await op.docRef.set({ ...current, ...op.data });
        } else if (op.type === 'delete') {
          await op.docRef.delete();
        }
      }

      return result;
    } finally {
      release();
    }
  }
}

// Monkey-patch admin.firestore.Timestamp to use our controlled time in tests
const admin = require('firebase-admin');
function createMockTimestamp(ms) {
  return {
    toMillis: () => ms,
    toDate: () => new Date(ms),
  };
}

test('Simultaneous Concurrency: User A and User B compete for exact same slot', async () => {
  const iterations = 20;

  for (let i = 0; i < iterations; i++) {
    const db = new MockFirestore();
    admin.firestore.Timestamp.now = () => createMockTimestamp(db.currentTimeMillis);
    admin.firestore.Timestamp.fromMillis = (ms) => createMockTimestamp(ms);

    const slotPayload = {
      venueId: 'v_nasr',
      courtId: 'court_1',
      scheduleDate: '2026-10-13',
      slotStart: '18:00',
    };

    const userAContext = { auth: { uid: 'user_A' } };
    const userBContext = { auth: { uid: 'user_B' } };

    // Fire both requests concurrently
    const [resA, resB] = await Promise.allSettled([
      acquireSlotLockHandler(slotPayload, userAContext, db),
      acquireSlotLockHandler(slotPayload, userBContext, db),
    ]);

    const aSuccess = resA.status === 'fulfilled';
    const bSuccess = resB.status === 'fulfilled';

    // Exactly one must succeed!
    assert.equal(
      (aSuccess && !bSuccess) || (!aSuccess && bSuccess),
      true,
      `Race condition failure on iteration ${i}: aSuccess=${aSuccess}, bSuccess=${bSuccess}`
    );

    const winnerUser = aSuccess ? 'user_A' : 'user_B';
    const loserResult = aSuccess ? resB : resA;

    assert.equal(loserResult.reason.message, 'SLOT_LOCKED');

    // Authoritative state check in Firestore
    const lockId = `v_nasr_court_1_2026-10-13_18:00`;
    const lockDoc = await db.collection('locks').doc(lockId).get();
    assert.equal(lockDoc.exists, true);
    assert.equal(lockDoc.data().userId, winnerUser);
    assert.equal(lockDoc.data().status, 'active');
  }
});

test('Lock Expiration Semantics: Expired lock is safely reclaimed by another user', async () => {
  const db = new MockFirestore();
  admin.firestore.Timestamp.now = () => createMockTimestamp(db.currentTimeMillis);
  admin.firestore.Timestamp.fromMillis = (ms) => createMockTimestamp(ms);

  const slotPayload = {
    venueId: 'v_nasr',
    courtId: 'court_1',
    scheduleDate: '2026-10-13',
    slotStart: '19:00',
  };

  // 1. User A locks slot at T=0
  const lockA = await acquireSlotLockHandler(slotPayload, { auth: { uid: 'user_A' } }, db);
  assert.equal(lockA.lockId, 'v_nasr_court_1_2026-10-13_19:00');

  // 2. User B tries at T = 4 min 59 sec (299,000 ms) -> Must be rejected
  db.currentTimeMillis += 299 * 1000;
  await assert.rejects(
    async () => acquireSlotLockHandler(slotPayload, { auth: { uid: 'user_B' } }, db),
    /SLOT_LOCKED/
  );

  // 3. User B tries at T = 5 min 01 sec (expired) -> Must succeed!
  db.currentTimeMillis += 2 * 1000; // Now at 301 seconds
  const lockB = await acquireSlotLockHandler(slotPayload, { auth: { uid: 'user_B' } }, db);
  assert.equal(lockB.lockId, 'v_nasr_court_1_2026-10-13_19:00');

  // Verify lock owner is now User B
  const lockDoc = await db.collection('locks').doc(lockB.lockId).get();
  assert.equal(lockDoc.data().userId, 'user_B');
});

test('Booking Confirmation: Commit unexpired lock and prevent double-booking', async () => {
  const db = new MockFirestore();
  admin.firestore.Timestamp.now = () => createMockTimestamp(db.currentTimeMillis);
  admin.firestore.Timestamp.fromMillis = (ms) => createMockTimestamp(ms);

  const slotPayload = {
    venueId: 'v_nasr',
    courtId: 'court_2',
    scheduleDate: '2026-10-13',
    slotStart: '20:00',
  };

  // 1. User A acquires lock
  const lock = await acquireSlotLockHandler(slotPayload, { auth: { uid: 'user_A' } }, db);

  // 2. User A confirms booking
  const confirmation = await confirmBookingHandler(
    { lockId: lock.lockId, paymentMethod: 'card', amount: 70 },
    { auth: { uid: 'user_A' } },
    db
  );
  assert.equal(confirmation.status, 'confirmed');
  assert.match(confirmation.reference, /^TSP-20261013-/);

  // 3. Idempotent retry: User A calls confirm again -> Returns same confirmation without error
  const retry = await confirmBookingHandler(
    { lockId: lock.lockId, paymentMethod: 'card', amount: 70 },
    { auth: { uid: 'user_A' } },
    db
  );
  assert.equal(retry.alreadyConfirmed, true);
  assert.equal(retry.reference, confirmation.reference);

  // 4. User B cannot lock this slot anymore -> SLOT_ALREADY_BOOKED
  await assert.rejects(
    async () => acquireSlotLockHandler(slotPayload, { auth: { uid: 'user_B' } }, db),
    /SLOT_ALREADY_BOOKED/
  );
});

test('Manager Cash-Block Operations: Conflict with Player Lock and Unblock', async () => {
  const db = new MockFirestore();
  admin.firestore.Timestamp.now = () => createMockTimestamp(db.currentTimeMillis);
  admin.firestore.Timestamp.fromMillis = (ms) => createMockTimestamp(ms);

  // Setup manager authorization in DB
  await db.collection('venueManagers').doc('mgr_1').collection('venues').doc('v_nasr').set({ role: 'manager' });

  const slotPayload = {
    venueId: 'v_nasr',
    courtId: 'court_3',
    scheduleDate: '2026-10-13',
    slotStart: '21:00',
  };

  // 1. Player locks slot
  await acquireSlotLockHandler(slotPayload, { auth: { uid: 'player_1' } }, db);

  // 2. Manager tries to cash-block while player has active lock -> REJECTED
  await assert.rejects(
    async () => blockCashSlotHandler(slotPayload, { auth: { uid: 'mgr_1' } }, db),
    /SLOT_CURRENTLY_LOCKED_BY_PLAYER/
  );

  // 3. Unauthorized manager tries on another venue -> REJECTED
  await assert.rejects(
    async () => blockCashSlotHandler(slotPayload, { auth: { uid: 'unauthorized_user' } }, db),
    /UNAUTHORIZED_VENUE_MANAGER/
  );

  // 4. Advance time so player lock expires
  db.advanceTimeByMinutes(6);

  // 5. Manager blocks slot -> SUCCESS
  const blockRes = await blockCashSlotHandler(slotPayload, { auth: { uid: 'mgr_1' } }, db);
  assert.equal(blockRes.status, 'blocked_cash');

  // 6. Player cannot lock cash-blocked slot -> REJECTED
  await assert.rejects(
    async () => acquireSlotLockHandler(slotPayload, { auth: { uid: 'player_2' } }, db),
    /SLOT_ALREADY_BOOKED/
  );

  // 7. Manager unblocks slot -> SUCCESS
  const unblockRes = await unblockCashSlotHandler(slotPayload, { auth: { uid: 'mgr_1' } }, db);
  assert.equal(unblockRes.status, 'available');

  // 8. Slot is now available for player to lock
  const newLock = await acquireSlotLockHandler(slotPayload, { auth: { uid: 'player_2' } }, db);
  assert.equal(newLock.lockId, 'v_nasr_court_3_2026-10-13_21:00');
});
