import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

export { onResonanceEventCreated } from './resonance_aggregator';