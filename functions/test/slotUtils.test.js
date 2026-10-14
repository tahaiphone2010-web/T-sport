const test = require('node:test');
const assert = require('node:assert/strict');
const {
  VALID_SLOT_STARTS,
  isValidTimeFormat,
  isValidDateFormat,
  calculateSlotEnd,
  generateSlotId,
  isSlotWithinOperatingHours,
  generateBookingReference,
} = require('../src/slots/slotUtils');

test('Operating hours - Tripoli 17:00 to 02:00 session validation', () => {
  // Valid starts
  assert.equal(isSlotWithinOperatingHours('17:00'), true);
  assert.equal(isSlotWithinOperatingHours('23:00'), true);
  assert.equal(isSlotWithinOperatingHours('00:00'), true, 'Midnight must belong to session');
  assert.equal(isSlotWithinOperatingHours('01:00'), true, '01:00 must belong to session');

  // Boundary and invalid hours
  assert.equal(isSlotWithinOperatingHours('02:00'), false, '02:00 is closing boundary, not a start slot');
  assert.equal(isSlotWithinOperatingHours('03:00'), false);
  assert.equal(isSlotWithinOperatingHours('12:00'), false);
  assert.equal(isSlotWithinOperatingHours('16:00'), false);
});

test('calculateSlotEnd handles midnight and morning wrap', () => {
  assert.equal(calculateSlotEnd('17:00'), '18:00');
  assert.equal(calculateSlotEnd('23:00'), '00:00');
  assert.equal(calculateSlotEnd('00:00'), '01:00');
  assert.equal(calculateSlotEnd('01:00'), '02:00');
});

test('generateSlotId creates canonical, deterministic keys', () => {
  const slotId1 = generateSlotId('venue1', 'court2', '2026-10-13', '18:00');
  const slotId2 = generateSlotId('venue1', 'court2', '2026-10-13', '18:00');
  assert.equal(slotId1, 'venue1_court2_2026-10-13_18:00');
  assert.equal(slotId1, slotId2);

  // Different court yields different slot ID
  const slotIdCourt3 = generateSlotId('venue1', 'court3', '2026-10-13', '18:00');
  assert.notEqual(slotId1, slotIdCourt3);

  // Throws on invalid date or time
  assert.throws(() => generateSlotId('v', 'c', 'bad-date', '18:00'), /INVALID_DATE_FORMAT/);
  assert.throws(() => generateSlotId('v', 'c', '2026-10-13', '18:30'), /INVALID_TIME_FORMAT/);
});

test('generateBookingReference creates unique formatted references', () => {
  const ref1 = generateBookingReference('2026-10-13', 'ABCD');
  assert.equal(ref1, 'TSP-20261013-ABCD');

  const refAuto = generateBookingReference('2026-10-13');
  assert.match(refAuto, /^TSP-20261013-[A-Z0-9]{4}$/);
});
