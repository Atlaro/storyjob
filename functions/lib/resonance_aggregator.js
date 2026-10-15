"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onResonanceEventCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
exports.onResonanceEventCreated = (0, firestore_1.onDocumentCreated)('resonance_events/{eventId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const eventData = snap.data();
    if (!eventData)
        return;
    const actorId = eventData.actorId;
    const targetId = eventData.targetId;
    const eventType = eventData.eventType;
    const details = eventData.details || {};
    if (!actorId || !targetId) {
        console.log('Skipping event: missing actorId or targetId');
        return;
    }
    const ids = [actorId, targetId].sort();
    const pairId = ids[0] + '_' + ids[1];
    const pairRef = db.collection('resonance_pairs').doc(pairId);
    try {
        await db.runTransaction(async (transaction) => {
            const doc = await transaction.get(pairRef);
            let totalInteractions = 0;
            let voiceListenedSeconds = 0;
            let voiceExchangedCount = 0;
            let sparksCount = 0;
            let appointmentStage = 'none';
            let funnelDepth = 1;
            if (doc.exists) {
                const data = doc.data();
                totalInteractions = data.totalInteractions || 0;
                voiceListenedSeconds = data.voiceListenedSeconds || 0;
                voiceExchangedCount = data.voiceExchangedCount || 0;
                sparksCount = data.sparksCount || 0;
                appointmentStage = data.appointmentStage || 'none';
                funnelDepth = data.funnelDepth || 1;
            }
            totalInteractions += 1;
            if (eventType === 'story_voice_listened') {
                const sec = details.listenedSeconds || 0;
                voiceListenedSeconds += sec;
                if (funnelDepth < 2 && voiceListenedSeconds > 10) {
                    funnelDepth = 2;
                }
            }
            else if (eventType === 'story_spark_triggered') {
                sparksCount += 1;
                if (funnelDepth < 2)
                    funnelDepth = 2;
            }
            else if (eventType === 'dialog_voice_exchanged') {
                voiceExchangedCount += 1;
                if (funnelDepth < 3)
                    funnelDepth = 3;
            }
            else if (eventType === 'appointment_action_logged') {
                if (details.isAppointmentAction) {
                    appointmentStage = 'confirmed';
                    funnelDepth = 4;
                }
            }
            const calculatedStrength = Math.min(99, Math.round(50 +
                funnelDepth * 10 +
                Math.min(20, voiceListenedSeconds * 0.5) +
                voiceExchangedCount * 5));
            transaction.set(pairRef, {
                pairId,
                partyA: ids[0],
                partyB: ids[1],
                totalInteractions,
                voiceListenedSeconds,
                voiceExchangedCount,
                sparksCount,
                appointmentStage,
                funnelDepth,
                relationshipStrength: calculatedStrength,
                lastInteractionAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
        });
        console.log('Successfully processed event ' + event.params.eventId + ' for pair ' + pairId);
    }
    catch (error) {
        console.error('Error updating resonance pair transaction:', error);
    }
});
//# sourceMappingURL=resonance_aggregator.js.map