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
  String get diaryTitle => 'Diary';

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
  String get profilePhotoSheetTitle => 'Profile photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoNeedSignIn => 'Sign in again to update your photo.';

  @override
  String get profilePhotoWrongAccount => 'Different account from the one logged in.';

  @override
  String get profilePhotoTokenFailed => 'Authentication error. Try signing in again.';

  @override
  String get profilePhotoUploadFailed => 'Failed to upload photo.';

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
  String get questionUsedLaxatives => 'Did you use laxatives since your last entry?';

  @override
  String get questionDiuretics => 'Did you use diuretics since your last entry?';

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
  String get plansSave40 => 'Save 40%';

  @override
  String get plansMonthly => 'Monthly';

  @override
  String get plansMostPopular => 'MOST POPULAR';

  @override
  String get plansPriceAnnual => 'R\$ 179.90';

  @override
  String get plansPriceMonthly => 'R\$ 24.90';

  @override
  String get plansPeriodYear => '/year';

  @override
  String get plansPeriodMonth => '/month';

  @override
  String get plansSubscribeAnnual => 'Subscribe Annual';

  @override
  String get plansSubscribeMonthly => 'Subscribe Monthly';

  @override
  String get plansTrialAnnual => '7-day free trial, then R\$ 179.90/year';

  @override
  String get plansTrialMonthly => '7-day free trial, then R\$ 24.90/month';

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
  String get sectionNotificationsPush => 'Alerts';

  @override
  String get notificationPushMasterTitle => 'New diary entries';

  @override
  String get notificationPushMasterSubtitle => 'Get notified when your patients log meals.';

  @override
  String get notificationPushCustomizeHint => 'Choose the type of alert below';

  @override
  String get notificationPushAllEntries => 'All new entries';

  @override
  String get notificationPushAllEntriesRowSubtitle => 'Every meal your patient logs.';

  @override
  String get notificationPushCriticalOnly => 'Risk behaviors only';

  @override
  String get notificationPushCriticalOnlyRowSubtitle => 'Vomiting, laxatives, regurgitation, secret eating, etc.';

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

  @override
  String get insightsDashboard => 'Dashboard';

  @override
  String get insightsActivePatients => 'Active patients';

  @override
  String get insightsActivePatientsSubtitle => 'with records in the last 7 days';

  @override
  String get insightsMealsThisWeek => 'Records this week';

  @override
  String get insightsMealsThisWeekSubtitle => 'meals from all patients';

  @override
  String get insightsAlerts => 'Alerts';

  @override
  String get insightsAlertsSubtitle => 'risk behaviors';

  @override
  String get insightsRecentAlerts => 'Recent alerts';

  @override
  String get insightsNoAlerts => 'No risk alerts in the last 7 days';

  @override
  String get insightsNeedsAttention => 'Need attention';

  @override
  String get insightsNoAttentionNeeded => 'All patients are doing well';

  @override
  String get insightsViewDiary => 'View diary';

  @override
  String get insightsEmptyTitle => 'No data yet';

  @override
  String get insightsEmptySubtitle => 'Invite patients and wait a few days of records to see insights here.';

  @override
  String get insightsNotLoggedIn => 'Sign in to see insights from your patients.';

  @override
  String get insightsAlertForcedVomit => 'Forced vomiting';

  @override
  String get insightsAlertUsedLaxatives => 'Laxative use';

  @override
  String get insightsAlertDiuretics => 'Diuretic use';

  @override
  String get insightsAlertRegurgitated => 'Regurgitation';

  @override
  String get insightsAlertHiddenFood => 'Hidden food';

  @override
  String get insightsAlertAteInSecret => 'Ate in secret';

  @override
  String get insightsHighPriority => 'High priority';

  @override
  String get insightsMediumPriority => 'Medium priority';

  @override
  String get insightsLowPriority => 'Monitor';

  @override
  String insightsAttentionScore(int score) {
    return 'Attention score: $score';
  }

  @override
  String get insightsScoreLabel => 'Attention score';

  @override
  String get insightsScoreHelpTitle => 'What is the attention score?';

  @override
  String get insightsScoreHelpBody => 'It is an indicator that helps prioritize patients with more attention signals in recent records.';

  @override
  String get insightsScoreHelpBullets1 => 'Based on alert frequency';

  @override
  String get insightsScoreHelpBullets2 => 'Considers how recent the events are';

  @override
  String get insightsScoreHelpBullets3 => 'Does not replace clinical assessment';

  @override
  String get insightsScoreHelpDisclaimer => 'The higher the score, the greater the need for follow-up.';

  @override
  String get insightsScoreHelpButton => 'Learn how it works';

  @override
  String get insightsScoreHelpPageTitle => 'How the attention score works';

  @override
  String get insightsScoreHelpPageBody => 'The score summarizes attention signals from recent records to make triage easier. It combines the number of alerts, the type of behavior observed, and how long it has been since the last event.';

  @override
  String get insightsClinicalPriorityTitle => 'Clinical priority';

  @override
  String get insightsClinicalPrioritySubtitle => 'Quick summary to decide where to look first';

  @override
  String insightsPatientsNeedAttention(int count) {
    return '$count patients need attention';
  }

  @override
  String insightsHighPriorityAlertsCount(int count) {
    return '$count high-priority alerts';
  }

  @override
  String insightsActiveRate(String percent) {
    return '$percent% of patients active';
  }

  @override
  String get insightsClinicalActionNeeded => 'Action recommended today';

  @override
  String get insightsClinicalPriorityWithAlerts => 'There are recent critical alerts. Review the patients with the highest ranking and the high-priority events first.';

  @override
  String get insightsClinicalPriorityNoAlerts => 'No recent critical alerts. Use the ranking to review patients with the highest score and inactivity.';

  @override
  String get insightsPatientAnalyticsTitle => 'Patient analysis';

  @override
  String get insightsPatientAnalyticsSubtitle => 'Top cases that deserve a quick read';

  @override
  String get insightsPatientAnalyticsEmpty => 'There are not enough patients yet to compare individual analysis.';

  @override
  String insightsTrendComparison(int current, int previous, String trend) {
    return '$current meals in the last week vs $previous in the previous week, $trend';
  }

  @override
  String insightsScoreValue(int score) {
    return 'Score $score';
  }

  @override
  String insightsMealsTrend(int current, int previous) {
    return '$current meals in 7d vs $previous in 30d';
  }

  @override
  String insightsNegativeFeelings(String percent) {
    return '$percent% negative feelings';
  }

  @override
  String insightsRestrictionRate(String percent) {
    return '$percent% low intake';
  }

  @override
  String get insightsHighPriorityAlerts => 'critical alerts';

  @override
  String get insightsTrendStable => 'Stable';

  @override
  String get insightsTrendModerate => 'Watch';

  @override
  String get insightsTrendLow => 'Low activity';

  @override
  String get insightsTrendNoData => 'No history';

  @override
  String get insightsTrendUp => 'going up';

  @override
  String get insightsTrendDown => 'going down';

  @override
  String get insightsTrendFlat => 'flat';

  @override
  String get insightsActionReviewToday => 'Review today';

  @override
  String get insightsActionReviewSoon => 'Review soon';

  @override
  String get insightsActionStable => 'Stable case';

  @override
  String get insightsActionWorsening => 'Getting worse';

  @override
  String get insightsActionImproving => 'Improving';

  @override
  String get insightsActionLabel => 'Action';

  @override
  String insightsActionSummary(int today, int soon, int stable) {
    return '$today today, $soon soon and $stable stable';
  }

  @override
  String get insightsClinicalSignalsTitle => 'Clinical signals';

  @override
  String get insightsClinicalSignalsSubtitle => 'Who worsened, who improved and who needs attention';

  @override
  String get insightsClinicalWhyHere => 'Why this patient is here';

  @override
  String get insightsClinicalWhyHereHighRisk => 'There is a recent critical alert and the score is high.';

  @override
  String get insightsClinicalWhyHereWorsening => 'The pattern worsened in the latest comparison.';

  @override
  String get insightsClinicalWhyHereBalanced => 'The signals are balanced, but the evolution is worth following.';

  @override
  String get insightsTrendMealsLabel => 'Adherence';

  @override
  String get insightsTrendAlertsLabel => 'Alerts';

  @override
  String get insightsTrendWorse => 'worse';

  @override
  String get insightsTrendBetter => 'better';

  @override
  String get insightsTrendSame => 'stable';

  @override
  String get insightsTrendActionWorse => 'Needs earlier review';

  @override
  String get insightsTrendActionBetter => 'Can be reviewed later';

  @override
  String insightsPatientPriorityToday(int count) {
    return '$count to review today';
  }

  @override
  String insightsPatientPrioritySoon(int count) {
    return '$count to review soon';
  }

  @override
  String insightsPatientPriorityStable(int count) {
    return '$count stable';
  }

  @override
  String insightsPatientPriorityWorsening(int count) {
    return '$count worsening';
  }

  @override
  String insightsPatientPriorityImproving(int count) {
    return '$count improving';
  }

  @override
  String get insightsDashboardOperationalTitle => 'Operational summary';

  @override
  String get insightsDashboardOperationalSubtitle => 'Case status to prioritize the schedule';

  @override
  String insightsPatientNarrativeInactive(int days) {
    return 'This patient has gone $days days without a recorded meal and needs review.';
  }

  @override
  String get insightsPatientNarrativeHighAlert => 'There are recent critical signs. It is worth reviewing the events in detail first.';

  @override
  String get insightsPatientNarrativeBalanced => 'The signals are more balanced, so this patient can come after the priority cases.';

  @override
  String get insightsPatientDetailTitle => 'Patient detail';

  @override
  String get insightsPatientDetailSubtitle => 'Quick clinical summary with signals and trend';

  @override
  String get insightsPatientDetailSignalsTitle => 'Main signals';

  @override
  String get insightsPatientDetailAlertCount => 'Recent alerts';

  @override
  String get insightsPatientDetailInactive => 'Days without meals';

  @override
  String get insightsPatientDetailNarrativeTitle => 'Clinical reading';

  @override
  String get insightsPatientDetailRecentAlerts => 'Recent alerts';

  @override
  String get insightsPatientDetailNoAlerts => 'No recent alerts in this period.';

  @override
  String get insightsPatientDetailNotFound => 'This patient could not be opened.';

  @override
  String get insightsTrendLabel => 'Trend';

  @override
  String insightsMealsCount(int count) {
    return '$count meals (7d)';
  }

  @override
  String insightsAlertsCount(int count) {
    return '$count alerts';
  }

  @override
  String insightsInactive(int days) {
    return 'Inactive for $days days';
  }

  @override
  String insightsLastMeal(String date) {
    return 'Last meal: $date';
  }

  @override
  String get insightsNoMeals => 'No records';

  @override
  String get insightsPeriod7Days => '7 days';

  @override
  String get insightsPeriod30Days => '30 days';

  @override
  String get insightsPeriod90Days => '90 days';

  @override
  String insightsUpdatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String get insightsMealsPeriod => 'Records in period';

  @override
  String get mealDetailTitle => 'Meal details';

  @override
  String get mealDetailWhere => 'Where ate';

  @override
  String get mealDetailWithOthers => 'Ate with others';

  @override
  String get mealDetailAmount => 'Amount';

  @override
  String get mealDetailFeeling => 'Feeling';

  @override
  String get mealDetailDescription => 'Description';

  @override
  String get mealDetailFeelingText => 'About the feeling';

  @override
  String get mealDetailBehaviors => 'Behaviors';

  @override
  String get mealDetailClose => 'Close';

  @override
  String get behaviorForcedVomit => 'Self-induced vomiting';

  @override
  String get behaviorUsedLaxatives => 'Laxative use';

  @override
  String get behaviorRegurgitated => 'Regurgitation';

  @override
  String get behaviorHiddenFood => 'Hidden food';

  @override
  String get behaviorAteInSecret => 'Ate in secret';

  @override
  String get behaviorDiuretics => 'Diuretic use';

  @override
  String get behaviorOtherMedication => 'Other medications';

  @override
  String get behaviorCompensatoryExercise => 'Compensatory exercise';

  @override
  String get behaviorChewAndSpit => 'Chew and spit';

  @override
  String get behaviorIntermittentFast => 'Intermittent fasting';

  @override
  String get behaviorSkipMeal => 'Skipped meal';

  @override
  String get behaviorBingeEating => 'Binge eating';

  @override
  String get behaviorGuiltAfterEating => 'Guilt after eating';

  @override
  String get behaviorCalorieCounting => 'Calorie counting';

  @override
  String get behaviorBodyChecking => 'Body checking';

  @override
  String get behaviorBodyWeighing => 'Body weighing';

  @override
  String get formConfigCategoryCompensatory => 'Compensatory methods';

  @override
  String get formConfigCategoryRestriction => 'Dietary restriction';

  @override
  String get formConfigCategoryBinge => 'Binge eating';

  @override
  String get formConfigCategoryOther => 'Other';

  @override
  String get formConfigTitle => 'Behaviors for the form';

  @override
  String formConfigPatientSubtitle(String name) {
    return 'Patient: $name';
  }

  @override
  String get formConfigSectionEnabled => 'Enable behavior section in patient form';

  @override
  String formConfigLastUpdated(String name, String date) {
    return 'Last updated: by $name on $date';
  }

  @override
  String get formConfigChangeLogTitle => 'Change history';

  @override
  String get formConfigButton => 'Configure form';

  @override
  String get formConfigSave => 'Save';

  @override
  String get formConfigSaving => 'Saving...';

  @override
  String get formConfigSaved => 'Configuration saved!';

  @override
  String get formConfigNoChangesYet => 'No changes recorded yet.';

  @override
  String get settingsDebugApnsTitle => 'APNS token (debug)';

  @override
  String get settingsDebugApnsSubtitle => 'Temporary — iOS push diagnostics';

  @override
  String get settingsDebugApnsShow => 'Show APNS token';

  @override
  String get settingsDebugApnsCopy => 'Copy';

  @override
  String get settingsDebugApnsUnavailable => 'APNS token not available yet. Reopen the app or wait a few seconds.';

  @override
  String get settingsDebugApnsCopied => 'APNS token copied';

  @override
  String get settingsDebugApnsRefresh => 'Refresh';

  @override
  String get settingsDebugFcmTitle => 'FCM token (debug)';

  @override
  String get settingsDebugFcmSubtitle => 'Same value stored in Firestore for push';

  @override
  String get settingsDebugFcmShow => 'Show FCM token';

  @override
  String get settingsDebugFcmCopy => 'Copy';

  @override
  String get settingsDebugFcmUnavailable => 'FCM token unavailable. Check notification permission and network.';

  @override
  String get settingsDebugFcmCopied => 'FCM token copied';
}
