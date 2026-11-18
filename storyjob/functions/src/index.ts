export const respondToAccessRequest = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentifizierung erforderlich."
      );
    }

    const talentUid = context.auth.uid;
    const requestId = data?.requestId;
    const accept = data?.accept;

    if (
      typeof requestId !== "string" ||
      requestId.length === 0 ||
      requestId.includes("/") ||
      typeof accept !== "boolean"
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Eine gültige Anfrage-ID und Entscheidung sind erforderlich."
      );
    }

    const requestRef = db.collection("access_requests").doc(requestId);
    // Deterministische ID verhindert doppelte Chats für dieselbe Anfrage.
    const conversationRef = db.collection("conversations").doc(requestId);

    try {
      const result = await db.runTransaction(async (tx) => {
        const requestSnap = await tx.get(requestRef);

        if (!requestSnap.exists) {
          throw new functions.https.HttpsError(
            "not-found",
            "Anfrage nicht gefunden."
          );
        }

        const request = requestSnap.data()!;

        if (request.talentUid !== talentUid) {
          throw new functions.https.HttpsError(
            "permission-denied",
            "Keine Berechtigung, diese Anfrage zu beantworten."
          );
        }

        if (request.status !== "pending") {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Diese Anfrage wurde bereits beantwortet."
          );
        }

        const newStatus = accept ? "approved" : "rejected";

        tx.update(requestRef, {
          status: newStatus,
          respondedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (accept) {
          if (
            typeof request.companyId !== "string" ||
            typeof request.teamId !== "string"
          ) {
            throw new functions.https.HttpsError(
              "failed-precondition",
              "Der Anfrage fehlen gültige Unternehmens- oder Teamdaten."
            );
          }

          tx.create(conversationRef, {
            accessRequestId: requestId,
            talentUid,
            companyId: request.companyId,
            teamId: request.teamId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isActive: true,
          });
        }

        return newStatus;
      });

      return {
        success: true,
        status: result,
      };
    } catch (error: unknown) {
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      console.error("Fehler bei respondToAccessRequest:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Fehler beim Verarbeiten der Antwort."
      );
    }
  }
);
