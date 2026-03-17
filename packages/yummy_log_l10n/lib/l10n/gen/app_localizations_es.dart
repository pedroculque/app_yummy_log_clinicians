// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get diaryTitle => 'YummyLog';

  @override
  String get greeting => 'Hola';

  @override
  String get diaryEmptyTitle => 'Tu diario alimenticio';

  @override
  String get diaryEmptySubtitle => 'Ninguna comida registrada hoy.';

  @override
  String get today => 'Hoy';

  @override
  String get noMealsThisDay => 'Ninguna comida este día';

  @override
  String get addMeal => 'Añadir comida';

  @override
  String get editMeal => 'Editar comida';

  @override
  String get sectionMealTime => 'Hora de la comida';

  @override
  String get sectionWhichMeal => '¿Qué comida?';

  @override
  String get mealTypeBreakfast => 'Desayuno';

  @override
  String get mealTypeLunch => 'Almuerzo';

  @override
  String get mealTypeDinner => 'Cena';

  @override
  String get mealTypeSupper => 'Cena tardía';

  @override
  String get mealTypeMorningSnack => 'Merienda mañana';

  @override
  String get mealTypeAfternoonSnack => 'Merienda tarde';

  @override
  String get mealTypeEveningSnack => 'Merienda noche';

  @override
  String get sectionWhereAte => '¿Dónde comiste?';

  @override
  String get whereAteHome => 'Casa';

  @override
  String get whereAteWork => 'Trabajo';

  @override
  String get whereAteRestaurant => 'Restaurante';

  @override
  String get whereAteOther => 'Otro';

  @override
  String get sectionAteWithOthers => '¿Comiste acompañado?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get sectionHowMuch => '¿Cuánto comiste?';

  @override
  String get amountNothing => 'Nada';

  @override
  String get amountLittle => 'Un poco';

  @override
  String get amountHalf => 'La mitad';

  @override
  String get amountMost => 'Casi todo';

  @override
  String get amountAll => 'Todo';

  @override
  String get sectionHowFelt => '¿Cómo te sentiste?';

  @override
  String get feelingSad => 'Triste';

  @override
  String get feelingNothing => 'Nada';

  @override
  String get feelingHappy => 'Alegre';

  @override
  String get feelingProud => 'Orgulloso';

  @override
  String get feelingAngry => 'Enfadado';

  @override
  String get sectionFeelingText => 'Cuéntanos cómo te sentiste';

  @override
  String get feelingTextHint => 'Escribe cómo te sentiste durante y/o después de la comida. Ej. Náuseas después...';

  @override
  String get buttonAddMeal => 'AÑADIR COMIDA';

  @override
  String get buttonSaveChanges => 'GUARDAR CAMBIOS';

  @override
  String get saving => 'Guardando...';

  @override
  String get detailTitle => 'Detalle';

  @override
  String get whatDoYouWantToDo => '¿Qué deseas hacer?';

  @override
  String get actionEdit => 'EDITAR';

  @override
  String get actionDelete => 'BORRAR';

  @override
  String get confirmDeleteEntry => '¿Seguro que quieres borrar?';

  @override
  String get entryNotFound => 'Registro no encontrado';

  @override
  String get back => 'Volver';

  @override
  String get labelDate => 'Fecha';

  @override
  String get labelTime => 'Hora';

  @override
  String get labelMeal => 'Comida';

  @override
  String get labelFeeling => 'Sentimiento';

  @override
  String get labelAboutFeeling => 'Sobre cómo te sentiste';

  @override
  String get labelWhereAte => 'Dónde comiste';

  @override
  String get labelAteWithOthers => 'Comiste acompañado';

  @override
  String get labelHowMuch => 'Cuánto comiste';

  @override
  String characterCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get sectionMealPhoto => 'Foto de la comida';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get skipPhoto => 'Solo anotar';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get sendPhoto => 'Añadir foto';

  @override
  String get sendPhotoHint => 'Toca para fotografiar o elegir de la galería';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get sectionDescribeWhatAte => 'Describe lo que comiste';

  @override
  String get describeWhatAteHint => 'Escribe detalles sobre tu plato';

  @override
  String get questionHiddenFood => '¿Escondiste tu comida?';

  @override
  String get questionRegurgitated => '¿Regurgitaste?';

  @override
  String get questionForcedVomit => '¿Te provocaste el vómito?';

  @override
  String get questionAteInSecret => '¿Comiste a escondidas?';

  @override
  String get questionUsedLaxatives => '¿Usaste laxantes desde tu último registro?';

  @override
  String get questionDiuretics => '¿Usaste diuréticos desde tu último registro?';

  @override
  String get viewDayList => 'Ver lista del día';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'Preferencias de la aplicación';

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get accountSignInIntro => 'Inicia sesión para sincronizar y conectar con tu nutricionista.';

  @override
  String get accountProHint => 'Inicio de sesión y sincronización disponibles en el plan Pro.';

  @override
  String get viewPlans => 'Ver planes';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEn => 'English (US)';

  @override
  String get languageEs => 'Español';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get sectionAbout => 'Acerca de';

  @override
  String get versionLabel => 'Versión';

  @override
  String get standardsLabel => 'Estándares';

  @override
  String get ageRangeLabel => 'Rango de edad';

  @override
  String get ageRangeValue => '0 - 19 años';

  @override
  String get curveSourcesLabel => 'Fuentes de curvas y clasificaciones';

  @override
  String get curveSourcesValue => 'OMS (WHO)';

  @override
  String get requestAccountDeletion => 'Solicitar eliminación de cuenta y datos';

  @override
  String get privacyPolicyLink => 'Enlace a la política de privacidad';

  @override
  String get sectionSupport => 'Soporte';

  @override
  String get supportIdLabel => 'ID de Soporte';

  @override
  String get supportIdHint => 'Use este código al contactar';

  @override
  String get copySupportId => 'Copiar';

  @override
  String get rateApp => 'Valorar la app';

  @override
  String get rateAppSubtitle => 'Tu opinión nos ayuda a mejorar';

  @override
  String get loginWithGoogle => 'Entrar con Google';

  @override
  String get loginWithApple => 'Entrar con Apple';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String loggedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get connectNutritionist => 'Conectar con nutricionista';

  @override
  String get connectNutritionistHint => 'Vincúlate a tu nutricionista para que pueda seguir tu diario. Requiere inicio de sesión.';

  @override
  String get displayNameLabel => 'Nombre';

  @override
  String get setDisplayName => 'Definir nombre';

  @override
  String get displayNameHint => 'Cómo quieres que te llamemos en la bienvenida';

  @override
  String get save => 'Guardar';

  @override
  String get conectarTitle => 'Conectar';

  @override
  String get nutritionistCode => 'Código del nutricionista';

  @override
  String get nutritionistCodeHint => 'Introduce el código que te dio tu nutricionista';

  @override
  String get buttonConnect => 'Conectar';

  @override
  String get connectSuccess => '¡Clínico añadido con éxito!';

  @override
  String get connectLoginRequired => 'Inicia sesión en Ajustes para conectar con un nutricionista.';

  @override
  String get goToSettings => 'Ir a Ajustes';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get professionNutricionista => 'Nutricionista';

  @override
  String get clinicianCodeLabel => 'Introduce el código del clínico';

  @override
  String get clinicianCodeHelper => '6 caracteres: letras y números (ej.: ABC123)';

  @override
  String get clinicianCodeInvalidLength => 'El código debe tener exactamente 6 caracteres (letras y números).';

  @override
  String get buttonSend => 'Enviar';

  @override
  String get removeClinician => 'Eliminar clínico';

  @override
  String get confirmRemoveClinician => '¿Seguro que quieres eliminar?';

  @override
  String connectedSince(String date) {
    return 'desde $date';
  }

  @override
  String get myProfessionals => 'Mis Profesionales';

  @override
  String get headerSubtitle => 'Comparte tu diario con tu equipo de salud';

  @override
  String get emptyStateTitle => 'Aún no estás conectado';

  @override
  String get emptyStateSubtitle => 'Pide el código a tu profesional de salud para compartir tu diario alimenticio';

  @override
  String get addProfessional => 'Añadir profesional';

  @override
  String get healthProfessionalCode => 'Código del profesional';

  @override
  String get healthProfessionalCodeHint => 'Introduce el código de 6 dígitos';

  @override
  String get professionHealthProfessional => 'Profesional de Salud';

  @override
  String get connectHealthProfessional => 'Conéctate con profesionales de salud';

  @override
  String get yesterday => 'Ayer';

  @override
  String get mealSingular => 'comida';

  @override
  String get mealPlural => 'comidas';

  @override
  String get validationPhotoRequired => 'Añade una foto de la comida.';

  @override
  String get validationMealTypeRequired => 'Selecciona el tipo de comida.';

  @override
  String get validationWhereAteRequired => 'Indica dónde comiste.';

  @override
  String get validationAteWithOthersRequired => 'Indica si comiste acompañado.';

  @override
  String get navPatients => 'Pacientes';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsComingSoonSubtitle => 'Pronto podrás ver métricas y datos de tus pacientes aquí.';

  @override
  String get plansUnlockPro => 'Desbloquea YummyLog Pro';

  @override
  String get plansUnlockSubtitle => 'Disfruta de todas las funciones sin límites';

  @override
  String get plansComingSoon => 'Próximamente';

  @override
  String get plansComingSoonMessage => 'La suscripción Pro estará disponible pronto. ¡Mantente atento a las actualizaciones!';

  @override
  String get plansGotIt => 'Entendido';

  @override
  String get plansFeatureUnlimitedPatients => 'Pacientes ilimitados';

  @override
  String get plansFeatureFullHistory => 'Historial completo';

  @override
  String get plansFeatureExportReports => 'Exportar informes';

  @override
  String get plansFeaturePrioritySupport => 'Soporte prioritario';

  @override
  String get plansAnnual => 'Anual';

  @override
  String get plansSave40 => 'Ahorra 40%';

  @override
  String get plansMonthly => 'Mensual';

  @override
  String get plansMostPopular => 'MÁS POPULAR';

  @override
  String get plansPriceAnnual => 'R\$ 179,90';

  @override
  String get plansPriceMonthly => 'R\$ 24,90';

  @override
  String get plansPeriodYear => '/año';

  @override
  String get plansPeriodMonth => '/mes';

  @override
  String get plansSubscribeAnnual => 'Suscribir Anual';

  @override
  String get plansSubscribeMonthly => 'Suscribir Mensual';

  @override
  String get plansTrialAnnual => '7 días gratis, luego R\$ 179,90/año';

  @override
  String get plansTrialMonthly => '7 días gratis, luego R\$ 24,90/mes';

  @override
  String get plansCancelAnytime => 'Cancela cuando quieras';

  @override
  String get errorNotLoggedIn => 'No has iniciado sesión';

  @override
  String get patientsLoadError => 'Error al cargar pacientes';

  @override
  String get removePatientTitle => '¿Eliminar paciente?';

  @override
  String removePatientMessage(String name) {
    return 'Dejarás de seguir el diario de $name. El paciente puede reconectarse con un nuevo código.';
  }

  @override
  String get removePatientButton => 'ELIMINAR';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String patientRemoved(String name) {
    return '$name fue eliminado';
  }

  @override
  String get loginRequiredTitle => 'Inicio de sesión requerido';

  @override
  String get loginRequiredMessage => 'Para invitar pacientes, primero debes iniciar sesión.';

  @override
  String get limitReachedTitle => 'Límite alcanzado';

  @override
  String get limitReachedMessage => 'Has alcanzado el límite de 2 pacientes del plan gratuito. ¡Actualiza a Pro para tener pacientes ilimitados!';

  @override
  String get viewPlansButton => 'Ver planes';

  @override
  String get notNow => 'Ahora no';

  @override
  String get noPatientsConnected => 'Ningún paciente conectado';

  @override
  String get onePatientConnected => '1 paciente conectado';

  @override
  String patientsConnectedCount(int count) {
    return '$count pacientes conectados';
  }

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get somethingWentWrong => '¡Ups! Algo salió mal';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get startFollowingTitle => 'Empieza a seguir';

  @override
  String get startFollowingSubtitleLoggedOut => 'Inicia sesión e invita a tus pacientes para seguir su diario alimenticio en tiempo real.';

  @override
  String get startFollowingSubtitleLoggedIn => 'Invita a tus pacientes con el botón de abajo y sigue su evolución alimentaria.';

  @override
  String get featureViewMealsTitle => 'Ver comidas';

  @override
  String get featureViewMealsSubtitle => 'Fotos y detalles de cada comida';

  @override
  String get featureFollowFeelingsTitle => 'Seguir sentimientos';

  @override
  String get featureFollowFeelingsSubtitle => 'Entiende la relación emocional con la comida';

  @override
  String get featureRealtimeTitle => 'Tiempo real';

  @override
  String get featureRealtimeSubtitle => 'Datos sincronizados automáticamente';

  @override
  String get actionRemove => 'Eliminar';

  @override
  String linkedSinceDate(String date) {
    return 'Desde $date';
  }

  @override
  String get invitePatientButton => 'INVITAR PACIENTE';

  @override
  String get inviteCodeTitle => 'Código de invitación';

  @override
  String get inviteCodeSubtitle => 'Comparte este código con tu paciente para que pueda conectarse a tu perfil.';

  @override
  String get codeCopied => '¡Código copiado!';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareSms => 'SMS';

  @override
  String get shareEmail => 'Correo';

  @override
  String shareInviteMessage(String code) {
    return 'Usa el código $code para conectarte conmigo en YummyLog!';
  }

  @override
  String get patientDefaultName => 'Paciente';

  @override
  String get diaryLoadError => 'Error al cargar datos';

  @override
  String get patientNoMealsThisDay => 'El paciente no registró comidas este día.';

  @override
  String get rateAppStoreSoon => 'Valorar en tienda: próximamente';

  @override
  String get sectionSubscription => 'Suscripción';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get restorePurchasesSoon => 'Restaurar compras: próximamente';

  @override
  String get planPro => 'Plan Pro';

  @override
  String get planFree => 'Plan Gratuito';

  @override
  String get loading => 'Cargando...';

  @override
  String get unlimitedPatients => 'Pacientes ilimitados';

  @override
  String patientsCountOfMax(int current, int max) {
    return '$current de $max pacientes';
  }

  @override
  String get upgradeToPro => 'Actualizar a Pro';

  @override
  String get insightsDashboard => 'Dashboard';

  @override
  String get insightsActivePatients => 'Pacientes activos';

  @override
  String get insightsActivePatientsSubtitle => 'con registros en los últimos 7 días';

  @override
  String get insightsMealsThisWeek => 'Registros esta semana';

  @override
  String get insightsMealsThisWeekSubtitle => 'comidas de todos los pacientes';

  @override
  String get insightsAlerts => 'Alertas';

  @override
  String get insightsAlertsSubtitle => 'comportamientos de riesgo';

  @override
  String get insightsRecentAlerts => 'Alertas recientes';

  @override
  String get insightsNoAlerts => 'Sin alertas de riesgo en los últimos 7 días';

  @override
  String get insightsNeedsAttention => 'Necesitan atención';

  @override
  String get insightsNoAttentionNeeded => 'Todos los pacientes están bien';

  @override
  String get insightsViewDiary => 'Ver diario';

  @override
  String get insightsEmptyTitle => 'Sin datos aún';

  @override
  String get insightsEmptySubtitle => 'Invita pacientes y espera algunos días de registros para ver insights aquí.';

  @override
  String get insightsNotLoggedIn => 'Inicia sesión para ver insights de tus pacientes.';

  @override
  String get insightsAlertForcedVomit => 'Vómito forzado';

  @override
  String get insightsAlertUsedLaxatives => 'Uso de laxantes';

  @override
  String get insightsAlertDiuretics => 'Uso de diurético';

  @override
  String get insightsAlertRegurgitated => 'Regurgitación';

  @override
  String get insightsAlertHiddenFood => 'Escondió comida';

  @override
  String get insightsAlertAteInSecret => 'Comió a escondidas';

  @override
  String get insightsHighPriority => 'Alta prioridad';

  @override
  String get insightsMediumPriority => 'Media prioridad';

  @override
  String get insightsLowPriority => 'Monitorear';

  @override
  String insightsAttentionScore(int score) {
    return 'Puntuación de atención: $score';
  }

  @override
  String get insightsScoreLabel => 'Puntuación de atención';

  @override
  String get insightsScoreHelpTitle => '¿Qué es la puntuación de atención?';

  @override
  String get insightsScoreHelpBody =>
      'Es un indicador que ayuda a priorizar a los pacientes con más señales de atención en los registros recientes.';

  @override
  String get insightsScoreHelpBullets1 =>
      'Basada en la frecuencia de alertas';

  @override
  String get insightsScoreHelpBullets2 =>
      'Considera qué tan recientes son los eventos';

  @override
  String get insightsScoreHelpBullets3 =>
      'No reemplaza la evaluación clínica';

  @override
  String get insightsScoreHelpDisclaimer =>
      'Cuanto mayor sea la puntuación, mayor es la necesidad de seguimiento.';

  @override
  String get insightsScoreHelpButton => 'Entender cómo funciona';

  @override
  String get insightsScoreHelpPageTitle =>
      'Cómo funciona la puntuación de atención';

  @override
  String get insightsScoreHelpPageBody =>
      'La puntuación resume señales de atención a partir de los registros más recientes para facilitar la priorización. Combina la cantidad de alertas, el tipo de comportamiento observado y el tiempo desde el último evento.';

  @override
  String insightsMealsCount(int count) {
    return '$count comidas (7d)';
  }

  @override
  String insightsAlertsCount(int count) {
    return '$count alertas';
  }

  @override
  String insightsInactive(int days) {
    return 'Inactivo hace $days días';
  }

  @override
  String insightsLastMeal(String date) {
    return 'Última comida: $date';
  }

  @override
  String get insightsNoMeals => 'Sin registros';

  @override
  String get insightsPeriod7Days => '7 días';

  @override
  String get insightsPeriod30Days => '30 días';

  @override
  String get insightsPeriod90Days => '90 días';

  @override
  String insightsUpdatedAt(String time) {
    return 'Actualizado a las $time';
  }

  @override
  String get insightsMealsPeriod => 'Registros en el período';

  @override
  String get mealDetailTitle => 'Detalles de la comida';

  @override
  String get mealDetailWhere => 'Dónde comió';

  @override
  String get mealDetailWithOthers => 'Comió acompañado';

  @override
  String get mealDetailAmount => 'Cantidad';

  @override
  String get mealDetailFeeling => 'Sentimiento';

  @override
  String get mealDetailDescription => 'Descripción';

  @override
  String get mealDetailFeelingText => 'Sobre el sentimiento';

  @override
  String get mealDetailBehaviors => 'Comportamientos';

  @override
  String get mealDetailClose => 'Cerrar';

  @override
  String get behaviorForcedVomit => 'Vómito auto inducido';

  @override
  String get behaviorUsedLaxatives => 'Uso de laxante';

  @override
  String get behaviorRegurgitated => 'Regurgitación';

  @override
  String get behaviorHiddenFood => 'Escondió comida';

  @override
  String get behaviorAteInSecret => 'Comer escondido';

  @override
  String get behaviorDiuretics => 'Uso de diurético';

  @override
  String get behaviorOtherMedication => 'Otras medicaciones';

  @override
  String get behaviorCompensatoryExercise => 'Ejercicio físico compensatorio';

  @override
  String get behaviorChewAndSpit => 'Masticar y escupir';

  @override
  String get behaviorIntermittentFast => 'Ayuno intermitente';

  @override
  String get behaviorSkipMeal => 'Saltar comida';

  @override
  String get behaviorBingeEating => 'Atracones';

  @override
  String get behaviorGuiltAfterEating => 'Culpa después de comer';

  @override
  String get behaviorCalorieCounting => 'Conteo de calorías';

  @override
  String get behaviorBodyChecking => 'Comprobación corporal';

  @override
  String get behaviorBodyWeighing => 'Pesaje corporal';

  @override
  String get formConfigCategoryCompensatory => 'Métodos compensatorios';

  @override
  String get formConfigCategoryRestriction => 'Restricción alimentaria';

  @override
  String get formConfigCategoryBinge => 'Atracones';

  @override
  String get formConfigCategoryOther => 'Otros';

  @override
  String get formConfigTitle => 'Comportamientos para el formulario';

  @override
  String formConfigPatientSubtitle(String name) {
    return 'Paciente: $name';
  }

  @override
  String get formConfigSectionEnabled => 'Habilitar sección de comportamiento en el formulario del paciente';

  @override
  String formConfigLastUpdated(String name, String date) {
    return 'Última modificación: por $name el $date';
  }

  @override
  String get formConfigChangeLogTitle => 'Historial de cambios';

  @override
  String get formConfigButton => 'Configurar formulario';

  @override
  String get formConfigSave => 'Guardar';

  @override
  String get formConfigSaving => 'Guardando...';

  @override
  String get formConfigSaved => '¡Configuración guardada!';

  @override
  String get formConfigNoChangesYet => 'Aún no hay cambios registrados.';
}
