/**
 * T-Sport Canonical Slot and Session Utilities
 * Operating Timezone: Africa/Tripoli (UTC+2, no DST changes)
 */

const VALID_SLOT_STARTS = [
  '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '00:00', '01:00'
];

const LOCK_DURATION_MS = 5 * 60 * 1000; // 5 minutes authoritative lock

/**
 * Validates whether a time string is in HH:mm format.
 */
function isValidTimeFormat(timeStr) {
  return /^([01]\d|2[0-3]):00$/.test(timeStr);
}

/**
 * Validates whether a schedule date is in YYYY-MM-DD format.
 */
function isValidDateFormat(dateStr) {
  return /^\d{4}-\d{2}-\d{2}$/.test(dateStr);
}

/**
 * Calculates slot end time given start time (+1 hour in operating session).
 */
function calculateSlotEnd(slotStart) {
  const [hourStr] = slotStart.split(':');
  const hour = parseInt(hourStr, 10);
  const nextHour = (hour + 1) % 24;
  return `${String(nextHour).padStart(2, '0')}:00`;
}

/**
 * Generates canonical deterministic slot ID.
 * Example: venue1_court1_2026-10-13_18:00
 */
function generateSlotId(venueId, courtId, scheduleDate, slotStart) {
  if (!venueId || !courtId || !scheduleDate || !slotStart) {
    throw new Error('MISSING_SLOT_IDENTIFIER_FIELDS');
  }
  const cleanVenue = String(venueId).trim();
  const cleanCourt = String(courtId).trim();
  const cleanDate = String(scheduleDate).trim();
  const cleanTime = String(slotStart).trim();

  if (!isValidDateFormat(cleanDate)) {
    throw new Error('INVALID_DATE_FORMAT');
  }
  if (!isValidTimeFormat(cleanTime)) {
    throw new Error('INVALID_TIME_FORMAT');
  }
  return `${cleanVenue}_${cleanCourt}_${cleanDate}_${cleanTime}`;
}

/**
 * Validates whether a slotStart belongs to the valid 17:00 -> 02:00 Tripoli session.
 */
function isSlotWithinOperatingHours(slotStart) {
  return VALID_SLOT_STARTS.includes(slotStart);
}

/**
 * Generates a unique, audit-compliant booking reference.
 * Example: TSP-20261013-A8F2
 */
function generateBookingReference(scheduleDate, randomSuffix) {
  const dateCompact = scheduleDate ? scheduleDate.replace(/-/g, '') : new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const suffix = randomSuffix || Math.random().toString(36).substring(2, 6).toUpperCase();
  return `TSP-${dateCompact}-${suffix}`;
}

/**
 * Safely extracts milliseconds from Firestore Timestamp, Date, string, or number.
 */
function toMillis(ts) {
  if (!ts) return 0;
  if (typeof ts.toMillis === 'function') return ts.toMillis();
  if (typeof ts.getTime === 'function') return ts.getTime();
  if (typeof ts === 'number') return ts;
  if (typeof ts === 'string') return new Date(ts).getTime();
  if (ts._seconds !== undefined) return ts._seconds * 1000 + (ts._nanoseconds || 0) / 1000000;
  return 0;
}

module.exports = {
  VALID_SLOT_STARTS,
  LOCK_DURATION_MS,
  isValidTimeFormat,
  isValidDateFormat,
  calculateSlotEnd,
  generateSlotId,
  isSlotWithinOperatingHours,
  generateBookingReference,
  toMillis,
};
