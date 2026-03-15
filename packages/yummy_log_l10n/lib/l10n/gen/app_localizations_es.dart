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
  String get questionUsedLaxatives => '¿Usaste laxantes o diuréticos desde tu último registro?';

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
}
