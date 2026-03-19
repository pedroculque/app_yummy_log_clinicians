import * as admin from 'firebase-admin';
import { firestore } from 'firebase-functions/v1';

admin.initializeApp();

type MealEntryDoc = {
  mealType?: string;
  deletedAt?: unknown;
  hiddenFood?: unknown;
  regurgitated?: unknown;
  forcedVomit?: unknown;
  ateInSecret?: unknown;
  usedLaxatives?: unknown;
  diuretics?: unknown;
  otherMedication?: unknown;
  compensatoryExercise?: unknown;
  chewAndSpit?: unknown;
  intermittentFast?: unknown;
  skipMeal?: unknown;
  bingeEating?: unknown;
  guiltAfterEating?: unknown;
  calorieCounting?: unknown;
  bodyChecking?: unknown;
  bodyWeighing?: unknown;
  behaviorFlags?: Record<string, unknown>;
};

type TokenDoc = {
  token?: string;
};

const TOP_LEVEL_BEHAVIORS = [
  'hiddenFood',
  'regurgitated',
  'forcedVomit',
  'ateInSecret',
  'usedLaxatives',
  'diuretics',
  'otherMedication',
  'compensatoryExercise',
  'chewAndSpit',
  'intermittentFast',
  'skipMeal',
  'bingeEating',
  'guiltAfterEating',
  'calorieCounting',
  'bodyChecking',
  'bodyWeighing',
] as const;

/** FCM indica token inválido ou expirado — remover doc em notification_tokens. */
const FCM_TOKEN_CLEANUP_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/** Alinhado ao catálogo de comportamentos / alertas de risco no app clínico. */
function mealHasCriticalBehavior(meal: MealEntryDoc): boolean {
  for (const k of TOP_LEVEL_BEHAVIORS) {
    if (meal[k] === true) return true;
  }
  const bf = meal.behaviorFlags;
  if (bf && typeof bf === 'object') {
    for (const v of Object.values(bf)) {
      if (v === true) return true;
    }
  }
  return false;
}

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

    const isCritical = mealHasCriticalBehavior(meal);
    console.log(`[notifyClinicians] Meal has critical behavior: ${isCritical}`);

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

        const prefSnap = await db
          .collection('clinicians')
          .doc(clinicianId)
          .collection('preferences')
          .doc('notification')
          .get();
        const prefData = prefSnap.data();
        if (prefData?.pushEnabled === false) {
          console.log(`[notifyClinicians] Clinician ${clinicianId} disabled push — skipping`);
          continue;
        }
        const pushMode = prefData?.pushMode as string | undefined;
        if (pushMode === 'critical_only' && !isCritical) {
          console.log(`[notifyClinicians] Clinician ${clinicianId} wants critical_only — skipping non-critical meal`);
          continue;
        }

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

        // Entrada crítica: mensagem de alerta (modo "todas" ou "só risco").
        const title = isCritical
          ? 'Alerta: comportamento de risco'
          : 'Nova entrada no diário';
        const body = isCritical
          ? `Alerta: ${userName} registrou comportamento de risco nesta refeição.`
          : `${userName} registrou uma nova refeição.`;

        console.log(`[notifyClinicians] Sending to ${tokens.length} tokens for clinician ${clinicianId}`);

        const result = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: {
            title,
            body,
          },
          data: {
            patientId,
            patientName: userName,
            mealType: meal.mealType ?? '',
            eventType: 'new_meal_entry',
            criticalOnly: String(isCritical),
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
        for (let i = 0; i < result.responses.length; i++) {
          const r = result.responses[i];
          if (!r.success && r.error) {
            console.error(
              `[notifyClinicians] Token ${i} fail: ${r.error.code} - ${r.error.message}`,
            );
            if (FCM_TOKEN_CLEANUP_CODES.has(r.error.code)) {
              const deadToken = tokens[i];
              try {
                await db
                  .collection('clinicians')
                  .doc(clinicianId)
                  .collection('notification_tokens')
                  .doc(deadToken)
                  .delete();
                console.log(
                  `[notifyClinicians] Removed dead notification_tokens doc for clinician ${clinicianId} (${r.error.code})`,
                );
              } catch (delErr) {
                console.error(
                  '[notifyClinicians] Failed to delete dead token doc:',
                  delErr,
                );
              }
            }
          }
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
