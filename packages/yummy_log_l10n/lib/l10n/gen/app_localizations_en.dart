// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get diaryTitle => 'YummyLog';

  @override
  String get greeting => 'Hello';

  @override
  String get diaryEmptyTitle => 'Your food diary';

  @override
  String get diaryEmptySubtitle => 'No meals logged today.';

  @override
  String get today => 'Today';

  @override
  String get noMealsThisDay => 'No meals on this day';

  @override
  String get addMeal => 'Add meal';

  @override
  String get editMeal => 'Edit meal';

  @override
  String get sectionMealTime => 'Meal time';

  @override
  String get sectionWhichMeal => 'Which meal?';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSupper => 'Supper';

  @override
  String get mealTypeMorningSnack => 'Morning snack';

  @override
  String get mealTypeAfternoonSnack => 'Afternoon snack';

  @override
  String get mealTypeEveningSnack => 'Evening snack';

  @override
  String get sectionWhereAte => 'Where did you eat?';

  @override
  String get whereAteHome => 'Home';

  @override
  String get whereAteWork => 'Work';

  @override
  String get whereAteRestaurant => 'Restaurant';

  @override
  String get whereAteOther => 'Other';

  @override
  String get sectionAteWithOthers => 'Did you eat with others?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get sectionHowMuch => 'How much did you eat?';

  @override
  String get amountNothing => 'Nothing';

  @override
  String get amountLittle => 'A little';

  @override
  String get amountHalf => 'Half';

  @override
  String get amountMost => 'Most of it';

  @override
  String get amountAll => 'All';

  @override
  String get sectionHowFelt => 'How did you feel?';

  @override
  String get feelingSad => 'Sad';

  @override
  String get feelingNothing => 'Nothing';

  @override
  String get feelingHappy => 'Happy';

  @override
  String get feelingProud => 'Proud';

  @override
  String get feelingAngry => 'Angry';

  @override
  String get sectionFeelingText => 'Tell us about how you felt';

  @override
  String get feelingTextHint => 'Write about how you felt during and/or after the meal. E.g. Nausea after eating...';

  @override
  String get buttonAddMeal => 'ADD MEAL';

  @override
  String get buttonSaveChanges => 'SAVE CHANGES';

  @override
  String get saving => 'Saving...';

  @override
  String get detailTitle => 'Detail';

  @override
  String get whatDoYouWantToDo => 'What do you want to do?';

  @override
  String get actionEdit => 'EDIT';

  @override
  String get actionDelete => 'DELETE';

  @override
  String get confirmDeleteEntry => 'Do you really want to delete?';

  @override
  String get entryNotFound => 'Entry not found';

  @override
  String get back => 'Back';

  @override
  String get labelDate => 'Date';

  @override
  String get labelTime => 'Time';

  @override
  String get labelMeal => 'Meal';

  @override
  String get labelFeeling => 'Feeling';

  @override
  String get labelAboutFeeling => 'About how you felt';

  @override
  String get labelWhereAte => 'Where you ate';

  @override
  String get labelAteWithOthers => 'Ate with others';

  @override
  String get labelHowMuch => 'How much you ate';

  @override
  String characterCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get sectionMealPhoto => 'Meal photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get skipPhoto => 'Just note';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get sendPhoto => 'Add photo';

  @override
  String get sendPhotoHint => 'Tap to take a photo or choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get sectionDescribeWhatAte => 'Describe what you ate';

  @override
  String get describeWhatAteHint => 'Write details about your plate';

  @override
  String get questionHiddenFood => 'Did you hide your food?';

  @override
  String get questionRegurgitated => 'Did you regurgitate?';

  @override
  String get questionForcedVomit => 'Did you force yourself to vomit?';

  @override
  String get questionAteInSecret => 'Did you eat in secret?';

  @override
  String get questionUsedLaxatives => 'Did you use laxatives or diuretics since your last entry?';

  @override
  String get viewDayList => 'View day list';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'App preferences';

  @override
  String get sectionAccount => 'Account';

  @override
  String get accountSignInIntro => 'Sign in to sync your data and connect with your nutritionist.';

  @override
  String get accountProHint => 'Sign in and sync available on Pro plan.';

  @override
  String get viewPlans => 'View plans';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEn => 'English (US)';

  @override
  String get languageEs => 'Español';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get sectionAbout => 'About';

  @override
  String get versionLabel => 'Version';

  @override
  String get standardsLabel => 'Standards';

  @override
  String get ageRangeLabel => 'Age range';

  @override
  String get ageRangeValue => '0 - 19 years';

  @override
  String get curveSourcesLabel => 'Curve and classification sources';

  @override
  String get curveSourcesValue => 'WHO';

  @override
  String get requestAccountDeletion => 'Request account and data deletion';

  @override
  String get privacyPolicyLink => 'Link to privacy policy';

  @override
  String get sectionSupport => 'Support';

  @override
  String get supportIdLabel => 'Support ID';

  @override
  String get supportIdHint => 'Use this code when contacting support';

  @override
  String get copySupportId => 'Copy';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get rateAppSubtitle => 'Your feedback helps us improve';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get logout => 'Sign out';

  @override
  String loggedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get connectNutritionist => 'Connect with nutritionist';

  @override
  String get connectNutritionistHint => 'Link to your nutritionist so they can follow your diary. Requires sign in.';

  @override
  String get displayNameLabel => 'Name';

  @override
  String get setDisplayName => 'Set name';

  @override
  String get displayNameHint => 'What should we call you in the greeting';

  @override
  String get save => 'Save';

  @override
  String get conectarTitle => 'Connect';

  @override
  String get nutritionistCode => 'Nutritionist code';

  @override
  String get nutritionistCodeHint => 'Enter the code provided by your nutritionist';

  @override
  String get buttonConnect => 'Connect';

  @override
  String get connectSuccess => 'Clinician added successfully!';

  @override
  String get connectLoginRequired => 'Sign in under Settings to connect with a nutritionist.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get viewProfile => 'View profile';

  @override
  String get professionNutricionista => 'Nutritionist';

  @override
  String get clinicianCodeLabel => 'Enter clinician code';

  @override
  String get clinicianCodeHelper => '6 characters: letters and numbers (e.g. ABC123)';

  @override
  String get clinicianCodeInvalidLength => 'Code must be exactly 6 characters (letters and numbers).';

  @override
  String get buttonSend => 'Send';

  @override
  String get removeClinician => 'Remove clinician';

  @override
  String get confirmRemoveClinician => 'Do you really want to remove?';

  @override
  String connectedSince(String date) {
    return 'since $date';
  }

  @override
  String get myProfessionals => 'My Professionals';

  @override
  String get headerSubtitle => 'Share your diary with your health team';

  @override
  String get emptyStateTitle => 'You\'re not connected yet';

  @override
  String get emptyStateSubtitle => 'Ask your health professional for their code to share your food diary';

  @override
  String get addProfessional => 'Add professional';

  @override
  String get healthProfessionalCode => 'Professional code';

  @override
  String get healthProfessionalCodeHint => 'Enter the 6-digit code';

  @override
  String get professionHealthProfessional => 'Health Professional';

  @override
  String get connectHealthProfessional => 'Connect with health professionals';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get mealSingular => 'meal';

  @override
  String get mealPlural => 'meals';

  @override
  String get validationPhotoRequired => 'Add a photo of the meal.';

  @override
  String get validationMealTypeRequired => 'Select the meal type.';

  @override
  String get validationWhereAteRequired => 'Select where you ate.';

  @override
  String get validationAteWithOthersRequired => 'Indicate whether you ate with others.';

  @override
  String get navPatients => 'Patients';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Settings';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsComingSoonSubtitle => 'Soon you will be able to view metrics and data from your patients here.';

  @override
  String get plansUnlockPro => 'Unlock YummyLog Pro';

  @override
  String get plansUnlockSubtitle => 'Enjoy all features with no limits';

  @override
  String get plansComingSoon => 'Coming soon';

  @override
  String get plansComingSoonMessage => 'Pro subscription will be available soon. Stay tuned for updates!';

  @override
  String get plansGotIt => 'Got it';

  @override
  String get plansFeatureUnlimitedPatients => 'Unlimited patients';

  @override
  String get plansFeatureFullHistory => 'Full history';

  @override
  String get plansFeatureExportReports => 'Export reports';

  @override
  String get plansFeaturePrioritySupport => 'Priority support';

  @override
  String get plansAnnual => 'Annual';

  @override
  String get plansSave37 => 'Save 37%';

  @override
  String get plansMonthly => 'Monthly';

  @override
  String get plansMostPopular => 'MOST POPULAR';

  @override
  String get plansPriceAnnual => 'R\$ 149.90';

  @override
  String get plansPriceMonthly => 'R\$ 19.90';

  @override
  String get plansPeriodYear => '/year';

  @override
  String get plansPeriodMonth => '/month';

  @override
  String get plansSubscribeAnnual => 'Subscribe Annual';

  @override
  String get plansSubscribeMonthly => 'Subscribe Monthly';

  @override
  String get plansTrialAnnual => '7-day free trial, then R\$ 149.90';

  @override
  String get plansTrialMonthly => '7-day free trial, then R\$ 19.90';

  @override
  String get plansCancelAnytime => 'Cancel anytime';

  @override
  String get errorNotLoggedIn => 'Not logged in';

  @override
  String get patientsLoadError => 'Error loading patients';

  @override
  String get removePatientTitle => 'Remove patient?';

  @override
  String removePatientMessage(String name) {
    return 'You will no longer follow $name\'s diary. The patient can reconnect using a new code.';
  }

  @override
  String get removePatientButton => 'REMOVE';

  @override
  String get cancelButton => 'Cancel';

  @override
  String patientRemoved(String name) {
    return '$name was removed';
  }

  @override
  String get loginRequiredTitle => 'Login required';

  @override
  String get loginRequiredMessage => 'To invite patients, you need to sign in first.';

  @override
  String get limitReachedTitle => 'Limit reached';

  @override
  String get limitReachedMessage => 'You have reached the limit of 2 patients on the free plan. Upgrade to Pro for unlimited patients!';

  @override
  String get viewPlansButton => 'View plans';

  @override
  String get notNow => 'Not now';

  @override
  String get noPatientsConnected => 'No patients connected';

  @override
  String get onePatientConnected => '1 patient connected';

  @override
  String patientsConnectedCount(int count) {
    return '$count patients connected';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get somethingWentWrong => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get startFollowingTitle => 'Start following';

  @override
  String get startFollowingSubtitleLoggedOut => 'Sign in and invite your patients to follow their food diary in real time.';

  @override
  String get startFollowingSubtitleLoggedIn => 'Invite your patients using the button below and follow their food journey.';

  @override
  String get featureViewMealsTitle => 'View meals';

  @override
  String get featureViewMealsSubtitle => 'Photos and details of each meal';

  @override
  String get featureFollowFeelingsTitle => 'Follow feelings';

  @override
  String get featureFollowFeelingsSubtitle => 'Understand the emotional relationship with food';

  @override
  String get featureRealtimeTitle => 'Real time';

  @override
  String get featureRealtimeSubtitle => 'Data synced automatically';

  @override
  String get actionRemove => 'Remove';

  @override
  String linkedSinceDate(String date) {
    return 'Since $date';
  }

  @override
  String get invitePatientButton => 'INVITE PATIENT';

  @override
  String get inviteCodeTitle => 'Invite code';

  @override
  String get inviteCodeSubtitle => 'Share this code with your patient so they can connect to your profile.';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareSms => 'SMS';

  @override
  String get shareEmail => 'Email';

  @override
  String shareInviteMessage(String code) {
    return 'Use code $code to connect with me on YummyLog!';
  }

  @override
  String get patientDefaultName => 'Patient';

  @override
  String get diaryLoadError => 'Error loading data';

  @override
  String get patientNoMealsThisDay => 'The patient did not log any meals on this day.';

  @override
  String get rateAppStoreSoon => 'Rate in store: coming soon';

  @override
  String get sectionSubscription => 'Subscription';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restorePurchasesSoon => 'Restore purchases: coming soon';

  @override
  String get planPro => 'Pro plan';

  @override
  String get planFree => 'Free plan';

  @override
  String get loading => 'Loading...';

  @override
  String get unlimitedPatients => 'Unlimited patients';

  @override
  String patientsCountOfMax(int current, int max) {
    return '$current of $max patients';
  }

  @override
  String get upgradeToPro => 'Upgrade to Pro';
}
