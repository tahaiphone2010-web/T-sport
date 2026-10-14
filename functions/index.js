const { acquireSlotLock } = require('./src/slots/acquireSlotLock');
const { confirmBooking } = require('./src/bookings/confirmBooking');
const { blockCashSlot, unblockCashSlot } = require('./src/manager/cashBlock');

exports.acquireSlotLock = acquireSlotLock;
exports.confirmBooking = confirmBooking;
exports.blockCashSlot = blockCashSlot;
exports.unblockCashSlot = unblockCashSlot;
