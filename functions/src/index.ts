import * as admin from 'firebase-admin';
import { firestore } from 'firebase-functions/v1';

admin.initializeApp();

type MealEntryDoc = {
  mealType?: string;
  deletedAt?: unknown;
};

type TokenDoc = {
  token?: string;
};

// Usando Gen 1 (mais estável com Firestore triggers)
export const notifyCliniciansOnNewMeal = firestore
  .document('users/{patientId}/meals/{mealId}')
  .onCreate(async (snapshot, context) => {
    const db = admin.firestore();
    const patientId = context.params.patientId;
    const mealId = context.params.mealId;
    const meal = snapshot.data() as MealEntryDoc;

    console.log(`[notifyClinicians] New meal: patient=${patientId}, meal=${mealId}`);

    if (!meal || meal.deletedAt) {
      console.log('[notifyClinicians] Skipping: no data or deleted');
      return null;
    }

    try {
      // Buscar o documento do usuário para pegar o nome
      const userDoc = await db.collection('users').doc(patientId).get();
      const userData = userDoc.data();
      const userName = userData?.displayName ?? userData?.name ?? 'Paciente';
      console.log(`[notifyClinicians] Patient name: ${userName}`);

      // Buscar clínicos via users/{patientId}/connections (clinicianUid)
      const connectionsSnap = await db
        .collection('users')
        .doc(patientId)
        .collection('connections')
        .get();

      const clinicianIds: string[] = [];
      for (const connDoc of connectionsSnap.docs) {
        const data = connDoc.data();
        const cid = data?.clinicianUid as string | undefined;
        const status = data?.status;
        console.log(`[notifyClinicians] Connection ${connDoc.id}: clinicianUid=${cid}, status=${status}`);
        if (cid && status !== 'removed') {
          clinicianIds.push(cid);
        }
      }

      console.log(`[notifyClinicians] Found ${clinicianIds.length} clinicians for patient (ids: ${clinicianIds.join(', ') || 'none'})`);
      if (clinicianIds.length === 0) {
        console.log('[notifyClinicians] No clinicians with clinicianUid in connections - skipping. Check if patient has linked with clinician code.');
        return null;
      }

      for (const clinicianId of clinicianIds) {
        console.log(`[notifyClinicians] Processing clinician: ${clinicianId}`);

        // Buscar tokens do clínico
        const tokensSnap = await db
          .collection('clinicians')
          .doc(clinicianId)
          .collection('notification_tokens')
          .get();

        const tokens = tokensSnap.docs
          .map((doc) => {
            const data = doc.data() as TokenDoc;
            return data.token ?? doc.id; // doc.id = token quando persistido
          })
          .filter((t): t is string => typeof t === 'string' && t.length > 0);

        console.log(`[notifyClinicians] Clinician ${clinicianId}: ${tokensSnap.docs.length} token docs, ${tokens.length} valid tokens`);
        if (tokens.length === 0) {
          console.log(`[notifyClinicians] No tokens for clinician ${clinicianId} - ensure clinician app is logged in and has notification permission`);
          continue;
        }

        console.log(`[notifyClinicians] Sending to ${tokens.length} tokens for clinician ${clinicianId}`);

        const result = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: {
            title: 'Nova entrada no diário',
            body: `${userName} registrou uma nova refeição.`,
          },
          data: {
            patientId,
            patientName: userName,
            mealType: meal.mealType ?? '',
            eventType: 'new_meal_entry',
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
          android: {
            priority: 'high',
            notification: {
              sound: 'default',
              priority: 'high',
            },
          },
        });

        console.log(`[notifyClinicians] FCM result: ${result.successCount} ok, ${result.failureCount} fail`);
        if (result.failureCount > 0) {
          result.responses.forEach((r, i) => {
            if (!r.success && r.error) {
              console.error(`[notifyClinicians] Token ${i} fail: ${r.error.code} - ${r.error.message}`);
            }
          });
        }
      }
    } catch (error) {
      const err = error as Error & { code?: number; details?: string };
      console.error('[notifyClinicians] Error:', err.message);
      console.error('[notifyClinicians] Stack:', err.stack);
      if (err.code !== undefined) console.error('[notifyClinicians] Code:', err.code);
      if (err.details !== undefined) console.error('[notifyClinicians] Details:', err.details);
    }

    return null;
  });
