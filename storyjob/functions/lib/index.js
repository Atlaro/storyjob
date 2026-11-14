"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onResonanceEventCreated = void 0;
const admin = require("firebase-admin");
if (!admin.apps.length) {
    admin.initializeApp();
}
var resonance_aggregator_1 = require("./resonance_aggregator");
Object.defineProperty(exports, "onResonanceEventCreated", { enumerable: true, get: function () { return resonance_aggregator_1.onResonanceEventCreated; } });
//# sourceMappingURL=index.js.map