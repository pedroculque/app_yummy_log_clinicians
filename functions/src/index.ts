import * as admin from 'firebase-admin';
import { firestore } from 'firebase-functions/v1';
import type { Firestore } from 'firebase-admin/firestore';

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

async function collectClinicianTokens(
  db: Firestore,
  clinicianId: string,
): Promise<string[]> {
  const tokensSnap = await db
    .collection('clinicians')
    .doc(clinicianId)
    .collection('notification_tokens')
    .get();
  return tokensSnap.docs
    .map((doc) => {
      const data = doc.data() as TokenDoc;
      return data.token ?? doc.id;
    })
    .filter((t): t is string => typeof t === 'string' && t.length > 0);
}

async function cleanupDeadTokensAfterMulticast(
  db: Firestore,
  clinicianId: string,
  tokens: string[],
  responses: admin.messaging.SendResponse[],
): Promise<void> {
  for (let i = 0; i < responses.length; i++) {
    const r = responses[i];
    if (!r.success && r.error && FCM_TOKEN_CLEANUP_CODES.has(r.error.code)) {
      const deadToken = tokens[i];
      try {
        await db
          .collection('clinicians')
          .doc(clinicianId)
          .collection('notification_tokens')
          .doc(deadToken)
          .delete();
        console.log(
          `[FCM] Removed dead notification_tokens for clinician ${clinicianId} (${r.error.code})`,
        );
      } catch (delErr) {
        console.error('[FCM] Failed to delete dead token doc:', delErr);
      }
    }
  }
}

async function sendFcmToClinician(
  db: Firestore,
  clinicianId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  const tokens = await collectClinicianTokens(db, clinicianId);
  if (tokens.length === 0) {
    console.log(`[FCM] No tokens for clinician ${clinicianId}`);
    return;
  }

  const result = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
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

  console.log(
    `[FCM] clinician=${clinicianId} ${result.successCount} ok, ${result.failureCount} fail`,
  );
  for (let i = 0; i < result.responses.length; i++) {
    const r = result.responses[i];
    if (!r.success && r.error) {
      console.error(
        `[FCM] Token ${i} fail: ${r.error.code} - ${r.error.message}`,
      );
    }
  }
  await cleanupDeadTokensAfterMulticast(db, clinicianId, tokens, result.responses);
}

async function readNotificationPrefs(
  db: Firestore,
  clinicianId: string,
): Promise<Record<string, unknown> | undefined> {
  const prefSnap = await db
    .collection('clinicians')
    .doc(clinicianId)
    .collection('preferences')
    .doc('notification')
    .get();
  return prefSnap.data();
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
      const userDoc = await db.collection('users').doc(patientId).get();
      const userData = userDoc.data();
      const userName = userData?.displayName ?? userData?.name ?? 'Paciente';
      console.log(`[notifyClinicians] Patient name: ${userName}`);

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
        if (cid && status !== 'removed') {
          clinicianIds.push(cid);
        }
      }

      console.log(
        `[notifyClinicians] Found ${clinicianIds.length} clinicians for patient`,
      );
      if (clinicianIds.length === 0) {
        return null;
      }

      for (const clinicianId of clinicianIds) {
        const prefData = await readNotificationPrefs(db, clinicianId);
        if (prefData?.pushEnabled === false) {
          console.log(
            `[notifyClinicians] Clinician ${clinicianId} disabled push — skipping`,
          );
          continue;
        }
        const pushMode = prefData?.pushMode as string | undefined;
        if (pushMode === 'critical_only' && !isCritical) {
          console.log(
            `[notifyClinicians] Clinician ${clinicianId} wants critical_only — skipping non-critical meal`,
          );
          continue;
        }

        const title = isCritical
          ? 'Alerta: comportamento de risco'
          : 'Nova entrada no diário';
        const body = isCritical
          ? `Alerta: ${userName} registrou comportamento de risco nesta refeição.`
          : `${userName} registrou uma nova refeição.`;

        await sendFcmToClinician(db, clinicianId, title, body, {
          patientId,
          patientName: userName,
          mealType: meal.mealType ?? '',
          eventType: 'new_meal_entry',
          criticalOnly: String(isCritical),
        });
      }
    } catch (error) {
      const err = error as Error & { code?: number; details?: string };
      console.error('[notifyClinicians] Error:', err.message);
      console.error('[notifyClinicians] Stack:', err.stack);
    }

    return null;
  });

/**
 * Quando o vínculo em clinicians/{cid}/patients/{pid} é removido (clínico ou paciente),
 * apaga a conexão correspondente em users/{pid}/connections (Admin) e notifica o clínico.
 */
export const onClinicianPatientRemoved = firestore
  .document('clinicians/{clinicianId}/patients/{patientId}')
  .onDelete(async (_snap, context) => {
    const db = admin.firestore();
    const clinicianId = context.params.clinicianId as string;
    const patientId = context.params.patientId as string;

    console.log(
      `[onClinicianPatientRemoved] clinician=${clinicianId} patient=${patientId}`,
    );

    try {
      const conns = await db
        .collection('users')
        .doc(patientId)
        .collection('connections')
        .where('clinicianUid', '==', clinicianId)
        .get();

      const batch = db.batch();
      for (const d of conns.docs) {
        batch.delete(d.ref);
      }
      await batch.commit();
      console.log(
        `[onClinicianPatientRemoved] Deleted ${conns.docs.length} connection doc(s)`,
      );

      const userDoc = await db.collection('users').doc(patientId).get();
      const ud = userDoc.data();
      const patientName = ud?.displayName ?? ud?.name ?? 'Paciente';

      const prefData = await readNotificationPrefs(db, clinicianId);
      if (prefData?.pushEnabled === false) {
        console.log(
          `[onClinicianPatientRemoved] Clinician ${clinicianId} disabled push`,
        );
        return null;
      }

      await sendFcmToClinician(
        db,
        clinicianId,
        'Vínculo encerrado',
        `${patientName} não está mais conectado(a) ao seu acompanhamento.`,
        {
          patientId,
          patientName,
          eventType: 'patient_unlinked',
        },
      );
    } catch (error) {
      const err = error as Error;
      console.error('[onClinicianPatientRemoved] Error:', err.message, err.stack);
    }

    return null;
  });

/** Paciente (ou fluxo) criou o vínculo: notifica o clínico. */
export const onClinicianPatientLinked = firestore
  .document('clinicians/{clinicianId}/patients/{patientId}')
  .onCreate(async (_snap, context) => {
    const db = admin.firestore();
    const clinicianId = context.params.clinicianId as string;
    const patientId = context.params.patientId as string;

    console.log(
      `[onClinicianPatientLinked] clinician=${clinicianId} patient=${patientId}`,
    );

    try {
      const userDoc = await db.collection('users').doc(patientId).get();
      const ud = userDoc.data();
      const patientName = ud?.displayName ?? ud?.name ?? 'Paciente';

      const prefData = await readNotificationPrefs(db, clinicianId);
      if (prefData?.pushEnabled === false) {
        console.log(
          `[onClinicianPatientLinked] Clinician ${clinicianId} disabled push`,
        );
        return null;
      }

      await sendFcmToClinician(
        db,
        clinicianId,
        'Novo paciente',
        `${patientName} conectou-se ao seu acompanhamento com o código de convite.`,
        {
          patientId,
          patientName,
          eventType: 'patient_linked',
        },
      );
    } catch (error) {
      const err = error as Error;
      console.error('[onClinicianPatientLinked] Error:', err.message, err.stack);
    }

    return null;
  });
