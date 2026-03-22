// dart format off
// coverage:ignore-file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryTitle;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greeting;

  /// No description provided for @diaryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your food diary'**
  String get diaryEmptyTitle;

  /// No description provided for @diaryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No meals logged today.'**
  String get diaryEmptySubtitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noMealsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No meals on this day'**
  String get noMealsThisDay;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMeal;

  /// No description provided for @sectionMealTime.
  ///
  /// In en, this message translates to:
  /// **'Meal time'**
  String get sectionMealTime;

  /// No description provided for @sectionWhichMeal.
  ///
  /// In en, this message translates to:
  /// **'Which meal?'**
  String get sectionWhichMeal;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSupper.
  ///
  /// In en, this message translates to:
  /// **'Supper'**
  String get mealTypeSupper;

  /// No description provided for @mealTypeMorningSnack.
  ///
  /// In en, this message translates to:
  /// **'Morning snack'**
  String get mealTypeMorningSnack;

  /// No description provided for @mealTypeAfternoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Afternoon snack'**
  String get mealTypeAfternoonSnack;

  /// No description provided for @mealTypeEveningSnack.
  ///
  /// In en, this message translates to:
  /// **'Evening snack'**
  String get mealTypeEveningSnack;

  /// No description provided for @sectionWhereAte.
  ///
  /// In en, this message translates to:
  /// **'Where did you eat?'**
  String get sectionWhereAte;

  /// No description provided for @whereAteHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get whereAteHome;

  /// No description provided for @whereAteWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get whereAteWork;

  /// No description provided for @whereAteRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get whereAteRestaurant;

  /// No description provided for @whereAteOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get whereAteOther;

  /// No description provided for @sectionAteWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Did you eat with others?'**
  String get sectionAteWithOthers;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @sectionHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much did you eat?'**
  String get sectionHowMuch;

  /// No description provided for @amountNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get amountNothing;

  /// No description provided for @amountLittle.
  ///
  /// In en, this message translates to:
  /// **'A little'**
  String get amountLittle;

  /// No description provided for @amountHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get amountHalf;

  /// No description provided for @amountMost.
  ///
  /// In en, this message translates to:
  /// **'Most of it'**
  String get amountMost;

  /// No description provided for @amountAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get amountAll;

  /// No description provided for @sectionHowFelt.
  ///
  /// In en, this message translates to:
  /// **'How did you feel?'**
  String get sectionHowFelt;

  /// No description provided for @feelingSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get feelingSad;

  /// No description provided for @feelingNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get feelingNothing;

  /// No description provided for @feelingHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get feelingHappy;

  /// No description provided for @feelingProud.
  ///
  /// In en, this message translates to:
  /// **'Proud'**
  String get feelingProud;

  /// No description provided for @feelingAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get feelingAngry;

  /// No description provided for @sectionFeelingText.
  ///
  /// In en, this message translates to:
  /// **'Tell us about how you felt'**
  String get sectionFeelingText;

  /// No description provided for @feelingTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write about how you felt during and/or after the meal. E.g. Nausea after eating...'**
  String get feelingTextHint;

  /// No description provided for @buttonAddMeal.
  ///
  /// In en, this message translates to:
  /// **'ADD MEAL'**
  String get buttonAddMeal;

  /// No description provided for @buttonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get buttonSaveChanges;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailTitle;

  /// No description provided for @whatDoYouWantToDo.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get whatDoYouWantToDo;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get actionDelete;

  /// No description provided for @confirmDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete?'**
  String get confirmDeleteEntry;

  /// No description provided for @entryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get entryNotFound;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labelTime;

  /// No description provided for @labelMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get labelMeal;

  /// No description provided for @labelFeeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get labelFeeling;

  /// No description provided for @labelAboutFeeling.
  ///
  /// In en, this message translates to:
  /// **'About how you felt'**
  String get labelAboutFeeling;

  /// No description provided for @labelWhereAte.
  ///
  /// In en, this message translates to:
  /// **'Where you ate'**
  String get labelWhereAte;

  /// No description provided for @labelAteWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Ate with others'**
  String get labelAteWithOthers;

  /// No description provided for @labelHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much you ate'**
  String get labelHowMuch;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String characterCount(int count, int max);

  /// No description provided for @sectionMealPhoto.
  ///
  /// In en, this message translates to:
  /// **'Meal photo'**
  String get sectionMealPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @profilePhotoSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoSheetTitle;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoNeedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to update your photo.'**
  String get profilePhotoNeedSignIn;

  /// No description provided for @profilePhotoWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'Different account from the one logged in.'**
  String get profilePhotoWrongAccount;

  /// No description provided for @profilePhotoTokenFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Try signing in again.'**
  String get profilePhotoTokenFailed;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @skipPhoto.
  ///
  /// In en, this message translates to:
  /// **'Just note'**
  String get skipPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @sendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get sendPhoto;

  /// No description provided for @sendPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to take a photo or choose from gallery'**
  String get sendPhotoHint;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @sectionDescribeWhatAte.
  ///
  /// In en, this message translates to:
  /// **'Describe what you ate'**
  String get sectionDescribeWhatAte;

  /// No description provided for @describeWhatAteHint.
  ///
  /// In en, this message translates to:
  /// **'Write details about your plate'**
  String get describeWhatAteHint;

  /// No description provided for @questionHiddenFood.
  ///
  /// In en, this message translates to:
  /// **'Did you hide your food?'**
  String get questionHiddenFood;

  /// No description provided for @questionRegurgitated.
  ///
  /// In en, this message translates to:
  /// **'Did you regurgitate?'**
  String get questionRegurgitated;

  /// No description provided for @questionForcedVomit.
  ///
  /// In en, this message translates to:
  /// **'Did you force yourself to vomit?'**
  String get questionForcedVomit;

  /// No description provided for @questionAteInSecret.
  ///
  /// In en, this message translates to:
  /// **'Did you eat in secret?'**
  String get questionAteInSecret;

  /// No description provided for @questionUsedLaxatives.
  ///
  /// In en, this message translates to:
  /// **'Did you use laxatives since your last entry?'**
  String get questionUsedLaxatives;

  /// No description provided for @questionDiuretics.
  ///
  /// In en, this message translates to:
  /// **'Did you use diuretics since your last entry?'**
  String get questionDiuretics;

  /// No description provided for @viewDayList.
  ///
  /// In en, this message translates to:
  /// **'View day list'**
  String get viewDayList;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsSubtitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @accountSignInIntro.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data and connect with your nutritionist.'**
  String get accountSignInIntro;

  /// No description provided for @accountProHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in and sync available on the Clinicians plan.'**
  String get accountProHint;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get viewPlans;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languagePt.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePt;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @standardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Standards'**
  String get standardsLabel;

  /// No description provided for @ageRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRangeLabel;

  /// No description provided for @ageRangeValue.
  ///
  /// In en, this message translates to:
  /// **'0 - 19 years'**
  String get ageRangeValue;

  /// No description provided for @curveSourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Curve and classification sources'**
  String get curveSourcesLabel;

  /// No description provided for @curveSourcesValue.
  ///
  /// In en, this message translates to:
  /// **'WHO'**
  String get curveSourcesValue;

  /// No description provided for @requestAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Request account and data deletion'**
  String get requestAccountDeletion;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Link to privacy policy'**
  String get privacyPolicyLink;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @supportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Support ID'**
  String get supportIdLabel;

  /// No description provided for @supportIdHint.
  ///
  /// In en, this message translates to:
  /// **'Use this code when contacting support'**
  String get supportIdHint;

  /// No description provided for @copySupportId.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copySupportId;

  /// No description provided for @supportIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Support ID copied to clipboard.'**
  String get supportIdCopied;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve'**
  String get rateAppSubtitle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get loginWithApple;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your clinician data in this app (links, invite code, preferences, and subscription) will be removed. Patients\' diary entries in their app are not deleted by this action. This cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteAccountConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirmCta;

  /// No description provided for @deleteAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountCancel;

  /// No description provided for @deleteAccountRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign out, sign in again, then try deleting your account again.'**
  String get deleteAccountRequiresRecentLogin;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account. Try again or contact support.'**
  String get deleteAccountFailed;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String loggedInAs(String email);

  /// No description provided for @connectNutritionist.
  ///
  /// In en, this message translates to:
  /// **'Connect with nutritionist'**
  String get connectNutritionist;

  /// No description provided for @connectNutritionistHint.
  ///
  /// In en, this message translates to:
  /// **'Link to your nutritionist so they can follow your diary. Requires sign in.'**
  String get connectNutritionistHint;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayNameLabel;

  /// No description provided for @setDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Set name'**
  String get setDisplayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'What should we call you in the greeting'**
  String get displayNameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @conectarTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get conectarTitle;

  /// No description provided for @nutritionistCode.
  ///
  /// In en, this message translates to:
  /// **'Nutritionist code'**
  String get nutritionistCode;

  /// No description provided for @nutritionistCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code provided by your nutritionist'**
  String get nutritionistCodeHint;

  /// No description provided for @buttonConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get buttonConnect;

  /// No description provided for @connectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clinician added successfully!'**
  String get connectSuccess;

  /// No description provided for @connectLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in under Settings to connect with a nutritionist.'**
  String get connectLoginRequired;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @professionNutricionista.
  ///
  /// In en, this message translates to:
  /// **'Nutritionist'**
  String get professionNutricionista;

  /// No description provided for @clinicianCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter clinician code'**
  String get clinicianCodeLabel;

  /// No description provided for @clinicianCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'6 characters: letters and numbers (e.g. ABC123)'**
  String get clinicianCodeHelper;

  /// No description provided for @clinicianCodeInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be exactly 6 characters (letters and numbers).'**
  String get clinicianCodeInvalidLength;

  /// No description provided for @buttonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get buttonSend;

  /// No description provided for @removeClinician.
  ///
  /// In en, this message translates to:
  /// **'Remove clinician'**
  String get removeClinician;

  /// No description provided for @confirmRemoveClinician.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove?'**
  String get confirmRemoveClinician;

  /// No description provided for @connectedSince.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String connectedSince(String date);

  /// No description provided for @myProfessionals.
  ///
  /// In en, this message translates to:
  /// **'My Professionals'**
  String get myProfessionals;

  /// No description provided for @headerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your diary with your health team'**
  String get headerSubtitle;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re not connected yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your health professional for their code to share your food diary'**
  String get emptyStateSubtitle;

  /// No description provided for @addProfessional.
  ///
  /// In en, this message translates to:
  /// **'Add professional'**
  String get addProfessional;

  /// No description provided for @healthProfessionalCode.
  ///
  /// In en, this message translates to:
  /// **'Professional code'**
  String get healthProfessionalCode;

  /// No description provided for @healthProfessionalCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get healthProfessionalCodeHint;

  /// No description provided for @professionHealthProfessional.
  ///
  /// In en, this message translates to:
  /// **'Health Professional'**
  String get professionHealthProfessional;

  /// No description provided for @connectHealthProfessional.
  ///
  /// In en, this message translates to:
  /// **'Connect with health professionals'**
  String get connectHealthProfessional;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @mealSingular.
  ///
  /// In en, this message translates to:
  /// **'meal'**
  String get mealSingular;

  /// No description provided for @mealPlural.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get mealPlural;

  /// No description provided for @validationPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of the meal.'**
  String get validationPhotoRequired;

  /// No description provided for @validationMealTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the meal type.'**
  String get validationMealTypeRequired;

  /// No description provided for @validationWhereAteRequired.
  ///
  /// In en, this message translates to:
  /// **'Select where you ate.'**
  String get validationWhereAteRequired;

  /// No description provided for @validationAteWithOthersRequired.
  ///
  /// In en, this message translates to:
  /// **'Indicate whether you ate with others.'**
  String get validationAteWithOthersRequired;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soon you will be able to view metrics and data from your patients here.'**
  String get insightsComingSoonSubtitle;

  /// No description provided for @plansUnlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock YummyLog Clinicians'**
  String get plansUnlockPro;

  /// No description provided for @plansUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all features with no limits'**
  String get plansUnlockSubtitle;

  /// No description provided for @plansComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get plansComingSoon;

  /// No description provided for @plansComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'The YummyLog Clinicians subscription will be available soon. Stay tuned for updates!'**
  String get plansComingSoonMessage;

  /// No description provided for @plansGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get plansGotIt;

  /// No description provided for @plansFeatureUnlimitedPatients.
  ///
  /// In en, this message translates to:
  /// **'Unlimited patients in your practice'**
  String get plansFeatureUnlimitedPatients;

  /// No description provided for @plansFeatureFullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get plansFeatureFullHistory;

  /// No description provided for @plansFeatureExportReports.
  ///
  /// In en, this message translates to:
  /// **'Export reports'**
  String get plansFeatureExportReports;

  /// No description provided for @plansFeaturePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get plansFeaturePrioritySupport;

  /// No description provided for @plansFeatureMealPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Real-time alerts when patients log meals'**
  String get plansFeatureMealPushNotifications;

  /// No description provided for @plansFeatureClinicalDashboard.
  ///
  /// In en, this message translates to:
  /// **'Full insights dashboard: 30- and 90-day views, operational summary, clinical priority, detailed risk alerts, and patient ranking'**
  String get plansFeatureClinicalDashboard;

  /// No description provided for @plansFeatureInsightsPerPatientDeepDive.
  ///
  /// In en, this message translates to:
  /// **'Advanced per-patient analysis: trends, feelings, comparisons, and deeper clinical view'**
  String get plansFeatureInsightsPerPatientDeepDive;

  /// No description provided for @plansProActiveInsightsIncluded.
  ///
  /// In en, this message translates to:
  /// **'Includes the full insights dashboard (longer periods, alerts, prioritization, and per-patient analysis).'**
  String get plansProActiveInsightsIncluded;

  /// No description provided for @plansAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get plansAnnual;

  /// No description provided for @plansSave40.
  ///
  /// In en, this message translates to:
  /// **'Save 40%'**
  String get plansSave40;

  /// No description provided for @plansMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get plansMonthly;

  /// No description provided for @plansMostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get plansMostPopular;

  /// No description provided for @plansPriceAnnual.
  ///
  /// In en, this message translates to:
  /// **'R\$ 179.90'**
  String get plansPriceAnnual;

  /// No description provided for @plansPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'R\$ 24.90'**
  String get plansPriceMonthly;

  /// No description provided for @plansPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get plansPeriodYear;

  /// No description provided for @plansPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get plansPeriodMonth;

  /// No description provided for @plansSubscribeAnnual.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Annual'**
  String get plansSubscribeAnnual;

  /// No description provided for @plansSubscribeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Monthly'**
  String get plansSubscribeMonthly;

  /// No description provided for @plansTrialAnnual.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial, then R\$ 179.90/year'**
  String get plansTrialAnnual;

  /// No description provided for @plansTrialMonthly.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial, then R\$ 24.90/month'**
  String get plansTrialMonthly;

  /// No description provided for @plansCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get plansCancelAnytime;

  /// No description provided for @errorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get errorNotLoggedIn;

  /// No description provided for @patientsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading patients'**
  String get patientsLoadError;

  /// No description provided for @removePatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove patient?'**
  String get removePatientTitle;

  /// No description provided for @removePatientMessage.
  ///
  /// In en, this message translates to:
  /// **'You will no longer follow {name}\'s diary. The patient can reconnect using a new code.'**
  String removePatientMessage(String name);

  /// No description provided for @removePatientButton.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get removePatientButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @patientRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed'**
  String patientRemoved(String name);

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'To invite patients, you need to sign in first.'**
  String get loginRequiredMessage;

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get limitReachedTitle;

  /// No description provided for @limitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of 2 patients on the free plan. Upgrade to YummyLog Clinicians for unlimited patients!'**
  String get limitReachedMessage;

  /// No description provided for @viewPlansButton.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get viewPlansButton;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @noPatientsConnected.
  ///
  /// In en, this message translates to:
  /// **'No patients connected'**
  String get noPatientsConnected;

  /// No description provided for @onePatientConnected.
  ///
  /// In en, this message translates to:
  /// **'1 patient connected'**
  String get onePatientConnected;

  /// No description provided for @patientsConnectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} patients connected'**
  String patientsConnectedCount(int count);

  /// No description provided for @patientsHeaderYummyLogHint.
  ///
  /// In en, this message translates to:
  /// **'Connected via the patient\'s YummyLog app'**
  String get patientsHeaderYummyLogHint;

  /// No description provided for @inviteRequiresYummyLogApp.
  ///
  /// In en, this message translates to:
  /// **'The patient needs the YummyLog app to accept the invite.'**
  String get inviteRequiresYummyLogApp;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @startFollowingTitle.
  ///
  /// In en, this message translates to:
  /// **'Start following'**
  String get startFollowingTitle;

  /// No description provided for @startFollowingSubtitleLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in and invite your patients to follow their food diary in real time.'**
  String get startFollowingSubtitleLoggedOut;

  /// No description provided for @startFollowingSubtitleLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Invite your patients using the button below and follow their food journey.'**
  String get startFollowingSubtitleLoggedIn;

  /// No description provided for @featureViewMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'View meals'**
  String get featureViewMealsTitle;

  /// No description provided for @featureViewMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and details of each meal'**
  String get featureViewMealsSubtitle;

  /// No description provided for @featureFollowFeelingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow feelings'**
  String get featureFollowFeelingsTitle;

  /// No description provided for @featureFollowFeelingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand the emotional relationship with food'**
  String get featureFollowFeelingsSubtitle;

  /// No description provided for @featureRealtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Real time'**
  String get featureRealtimeTitle;

  /// No description provided for @featureRealtimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data synced automatically'**
  String get featureRealtimeSubtitle;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @linkedSinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String linkedSinceDate(String date);

  /// No description provided for @invitePatientButton.
  ///
  /// In en, this message translates to:
  /// **'INVITE PATIENT'**
  String get invitePatientButton;

  /// No description provided for @inviteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeTitle;

  /// No description provided for @inviteCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your patient so they can connect to your profile.'**
  String get inviteCodeSubtitle;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @shareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get shareSms;

  /// No description provided for @shareEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get shareEmail;

  /// No description provided for @shareInviteEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'YummyLog invite — connection code'**
  String get shareInviteEmailSubject;

  /// No description provided for @inviteShareNeedValidCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a valid invite code before sharing.'**
  String get inviteShareNeedValidCode;

  /// No description provided for @shareInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Use code {code} to connect with me on YummyLog!'**
  String shareInviteMessage(String code);

  /// No description provided for @patientDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientDefaultName;

  /// No description provided for @diaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get diaryLoadError;

  /// No description provided for @patientNoMealsThisDay.
  ///
  /// In en, this message translates to:
  /// **'The patient did not log any meals on this day.'**
  String get patientNoMealsThisDay;

  /// No description provided for @rateAppStoreSoon.
  ///
  /// In en, this message translates to:
  /// **'Rate in store: coming soon'**
  String get rateAppStoreSoon;

  /// No description provided for @sectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get sectionSubscription;

  /// No description provided for @sectionNotificationsPush.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get sectionNotificationsPush;

  /// No description provided for @notificationPushMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'New diary entries'**
  String get notificationPushMasterTitle;

  /// No description provided for @notificationPushMasterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when your patients log meals.'**
  String get notificationPushMasterSubtitle;

  /// No description provided for @notificationPushCustomizeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of alert below'**
  String get notificationPushCustomizeHint;

  /// No description provided for @notificationPushAllEntries.
  ///
  /// In en, this message translates to:
  /// **'All new entries'**
  String get notificationPushAllEntries;

  /// No description provided for @notificationPushAllEntriesRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every meal your patient logs.'**
  String get notificationPushAllEntriesRowSubtitle;

  /// No description provided for @notificationPushCriticalOnly.
  ///
  /// In en, this message translates to:
  /// **'Risk behaviors only'**
  String get notificationPushCriticalOnly;

  /// No description provided for @notificationPushCriticalOnlyRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vomiting, laxatives, regurgitation, secret eating, etc.'**
  String get notificationPushCriticalOnlyRowSubtitle;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @restorePurchasesSoon.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases: coming soon'**
  String get restorePurchasesSoon;

  /// No description provided for @purchasesNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not configured in this build. Set RevenueCat API keys.'**
  String get purchasesNotConfigured;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated.'**
  String get purchaseSuccess;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get purchaseCancelled;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the purchase. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @purchaseOfferingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Plans are unavailable right now. Please try again later.'**
  String get purchaseOfferingsUnavailable;

  /// No description provided for @purchasesRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription restored successfully.'**
  String get purchasesRestoreSuccess;

  /// No description provided for @purchasesRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subscription found for this account.'**
  String get purchasesRestoreEmpty;

  /// No description provided for @purchasesRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases.'**
  String get purchasesRestoreFailed;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Clinicians plan'**
  String get planPro;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get planFree;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @unlimitedPatients.
  ///
  /// In en, this message translates to:
  /// **'Unlimited patients'**
  String get unlimitedPatients;

  /// No description provided for @patientsCountOfMax.
  ///
  /// In en, this message translates to:
  /// **'{current} of {max} patients'**
  String patientsCountOfMax(int current, int max);

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Clinicians'**
  String get upgradeToPro;

  /// No description provided for @insightsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get insightsDashboard;

  /// No description provided for @insightsActivePatients.
  ///
  /// In en, this message translates to:
  /// **'Active patients'**
  String get insightsActivePatients;

  /// No description provided for @insightsActivePatientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'with records in the last 7 days'**
  String get insightsActivePatientsSubtitle;

  /// No description provided for @insightsMealsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Records this week'**
  String get insightsMealsThisWeek;

  /// No description provided for @insightsMealsThisWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'meals from all patients'**
  String get insightsMealsThisWeekSubtitle;

  /// No description provided for @insightsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get insightsAlerts;

  /// No description provided for @insightsAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'risk behaviors'**
  String get insightsAlertsSubtitle;

  /// No description provided for @insightsRecentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get insightsRecentAlerts;

  /// No description provided for @insightsNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No risk alerts in the last 7 days'**
  String get insightsNoAlerts;

  /// No description provided for @insightsNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Need attention'**
  String get insightsNeedsAttention;

  /// No description provided for @insightsNoAttentionNeeded.
  ///
  /// In en, this message translates to:
  /// **'All patients are doing well'**
  String get insightsNoAttentionNeeded;

  /// No description provided for @insightsViewDiary.
  ///
  /// In en, this message translates to:
  /// **'View diary'**
  String get insightsViewDiary;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite patients and wait a few days of records to see insights here.'**
  String get insightsEmptySubtitle;

  /// No description provided for @insightsNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see insights from your patients.'**
  String get insightsNotLoggedIn;

  /// No description provided for @insightsFreeTeaserPeriodBadge.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get insightsFreeTeaserPeriodBadge;

  /// No description provided for @insightsFreeTeaserPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'On the free plan the dashboard only uses the last 7 days.'**
  String get insightsFreeTeaserPeriodHint;

  /// No description provided for @insightsFreeTeaserTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard preview'**
  String get insightsFreeTeaserTitle;

  /// No description provided for @insightsFreeTeaserBody.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts, attention ranking, and per-patient deep dives (30- and 90-day windows) are part of the Clinicians plan.'**
  String get insightsFreeTeaserBody;

  /// No description provided for @insightsProLockedAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get insightsProLockedAttentionTitle;

  /// No description provided for @insightsProLockedAttentionBody.
  ///
  /// In en, this message translates to:
  /// **'Clinical prioritization and patient lists are available on the Clinicians plan.'**
  String get insightsProLockedAttentionBody;

  /// No description provided for @insightsProLockedAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Per-patient analysis'**
  String get insightsProLockedAnalyticsTitle;

  /// No description provided for @insightsProLockedAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'Charts, trends, and per-patient detail are on the Clinicians plan.'**
  String get insightsProLockedAnalyticsBody;

  /// No description provided for @insightsProUpsellTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinicians plan feature'**
  String get insightsProUpsellTitle;

  /// No description provided for @insightsProUpsellBody.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock this insight and the full dashboard.'**
  String get insightsProUpsellBody;

  /// No description provided for @insightsAlertForcedVomit.
  ///
  /// In en, this message translates to:
  /// **'Forced vomiting'**
  String get insightsAlertForcedVomit;

  /// No description provided for @insightsAlertUsedLaxatives.
  ///
  /// In en, this message translates to:
  /// **'Laxative use'**
  String get insightsAlertUsedLaxatives;

  /// No description provided for @insightsAlertDiuretics.
  ///
  /// In en, this message translates to:
  /// **'Diuretic use'**
  String get insightsAlertDiuretics;

  /// No description provided for @insightsAlertRegurgitated.
  ///
  /// In en, this message translates to:
  /// **'Regurgitation'**
  String get insightsAlertRegurgitated;

  /// No description provided for @insightsAlertHiddenFood.
  ///
  /// In en, this message translates to:
  /// **'Hidden food'**
  String get insightsAlertHiddenFood;

  /// No description provided for @insightsAlertAteInSecret.
  ///
  /// In en, this message translates to:
  /// **'Ate in secret'**
  String get insightsAlertAteInSecret;

  /// No description provided for @insightsHighPriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get insightsHighPriority;

  /// No description provided for @insightsMediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get insightsMediumPriority;

  /// No description provided for @insightsLowPriority.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get insightsLowPriority;

  /// No description provided for @insightsAttentionScore.
  ///
  /// In en, this message translates to:
  /// **'Attention score: {score}'**
  String insightsAttentionScore(int score);

  /// No description provided for @insightsScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Attention score'**
  String get insightsScoreLabel;

  /// No description provided for @insightsScoreHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'What is the attention score?'**
  String get insightsScoreHelpTitle;

  /// No description provided for @insightsScoreHelpBody.
  ///
  /// In en, this message translates to:
  /// **'It is an indicator that helps prioritize patients with more attention signals in recent records.'**
  String get insightsScoreHelpBody;

  /// No description provided for @insightsScoreHelpBullets1.
  ///
  /// In en, this message translates to:
  /// **'Based on alert frequency'**
  String get insightsScoreHelpBullets1;

  /// No description provided for @insightsScoreHelpBullets2.
  ///
  /// In en, this message translates to:
  /// **'Considers how recent the events are'**
  String get insightsScoreHelpBullets2;

  /// No description provided for @insightsScoreHelpBullets3.
  ///
  /// In en, this message translates to:
  /// **'Does not replace clinical assessment'**
  String get insightsScoreHelpBullets3;

  /// No description provided for @insightsScoreHelpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The higher the score, the greater the need for follow-up.'**
  String get insightsScoreHelpDisclaimer;

  /// No description provided for @insightsScoreHelpButton.
  ///
  /// In en, this message translates to:
  /// **'Learn how it works'**
  String get insightsScoreHelpButton;

  /// No description provided for @insightsScoreHelpPageTitle.
  ///
  /// In en, this message translates to:
  /// **'How the attention score works'**
  String get insightsScoreHelpPageTitle;

  /// No description provided for @insightsScoreHelpPageBody.
  ///
  /// In en, this message translates to:
  /// **'The score summarizes attention signals from recent records to make triage easier. It combines the number of alerts, the type of behavior observed, and how long it has been since the last event.'**
  String get insightsScoreHelpPageBody;

  /// No description provided for @insightsClinicalPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical priority'**
  String get insightsClinicalPriorityTitle;

  /// No description provided for @insightsClinicalPrioritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick summary to decide where to look first'**
  String get insightsClinicalPrioritySubtitle;

  /// No description provided for @insightsPatientsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} patients need attention'**
  String insightsPatientsNeedAttention(int count);

  /// No description provided for @insightsHighPriorityAlertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} high-priority alerts'**
  String insightsHighPriorityAlertsCount(int count);

  /// No description provided for @insightsActiveRate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of patients active'**
  String insightsActiveRate(String percent);

  /// No description provided for @insightsClinicalActionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Action recommended today'**
  String get insightsClinicalActionNeeded;

  /// No description provided for @insightsClinicalPriorityWithAlerts.
  ///
  /// In en, this message translates to:
  /// **'There are recent critical alerts. Review the patients with the highest ranking and the high-priority events first.'**
  String get insightsClinicalPriorityWithAlerts;

  /// No description provided for @insightsClinicalPriorityNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No recent critical alerts. Use the ranking to review patients with the highest score and inactivity.'**
  String get insightsClinicalPriorityNoAlerts;

  /// No description provided for @insightsPatientAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient analysis'**
  String get insightsPatientAnalyticsTitle;

  /// No description provided for @insightsPatientAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top cases that deserve a quick read'**
  String get insightsPatientAnalyticsSubtitle;

  /// No description provided for @insightsPatientAnalyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are not enough patients yet to compare individual analysis.'**
  String get insightsPatientAnalyticsEmpty;

  /// No description provided for @insightsTrendComparison.
  ///
  /// In en, this message translates to:
  /// **'{current} meals in the last week vs {previous} in the previous week, {trend}'**
  String insightsTrendComparison(int current, int previous, String trend);

  /// No description provided for @insightsAlertsTrendComparison.
  ///
  /// In en, this message translates to:
  /// **'{current} alerts in the last week vs {previous} in the previous week, {trend}'**
  String insightsAlertsTrendComparison(int current, int previous, String trend);

  /// No description provided for @insightsScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String insightsScoreValue(int score);

  /// No description provided for @insightsMealsTrend.
  ///
  /// In en, this message translates to:
  /// **'{current} meals in the last week vs {previous} in the previous week'**
  String insightsMealsTrend(int current, int previous);

  /// No description provided for @insightsNegativeFeelings.
  ///
  /// In en, this message translates to:
  /// **'{percent}% negative feelings'**
  String insightsNegativeFeelings(String percent);

  /// No description provided for @insightsRestrictionRate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% low intake'**
  String insightsRestrictionRate(String percent);

  /// No description provided for @insightsHighPriorityAlerts.
  ///
  /// In en, this message translates to:
  /// **'critical alerts'**
  String get insightsHighPriorityAlerts;

  /// No description provided for @insightsTrendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get insightsTrendStable;

  /// No description provided for @insightsTrendModerate.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get insightsTrendModerate;

  /// No description provided for @insightsTrendLow.
  ///
  /// In en, this message translates to:
  /// **'Low activity'**
  String get insightsTrendLow;

  /// No description provided for @insightsTrendNoData.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get insightsTrendNoData;

  /// No description provided for @insightsTrendUp.
  ///
  /// In en, this message translates to:
  /// **'going up'**
  String get insightsTrendUp;

  /// No description provided for @insightsTrendDown.
  ///
  /// In en, this message translates to:
  /// **'going down'**
  String get insightsTrendDown;

  /// No description provided for @insightsTrendFlat.
  ///
  /// In en, this message translates to:
  /// **'flat'**
  String get insightsTrendFlat;

  /// No description provided for @insightsActionReviewToday.
  ///
  /// In en, this message translates to:
  /// **'Review today'**
  String get insightsActionReviewToday;

  /// No description provided for @insightsActionReviewSoon.
  ///
  /// In en, this message translates to:
  /// **'Review soon'**
  String get insightsActionReviewSoon;

  /// No description provided for @insightsActionStable.
  ///
  /// In en, this message translates to:
  /// **'Stable case'**
  String get insightsActionStable;

  /// No description provided for @insightsActionWorsening.
  ///
  /// In en, this message translates to:
  /// **'Getting worse'**
  String get insightsActionWorsening;

  /// No description provided for @insightsActionImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get insightsActionImproving;

  /// No description provided for @insightsActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get insightsActionLabel;

  /// No description provided for @insightsActionSummary.
  ///
  /// In en, this message translates to:
  /// **'{today} today, {soon} soon and {stable} stable'**
  String insightsActionSummary(int today, int soon, int stable);

  /// No description provided for @insightsClinicalSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical signals'**
  String get insightsClinicalSignalsTitle;

  /// No description provided for @insightsClinicalSignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who worsened, who improved and who needs attention'**
  String get insightsClinicalSignalsSubtitle;

  /// No description provided for @insightsClinicalWhyHere.
  ///
  /// In en, this message translates to:
  /// **'Why this patient is here'**
  String get insightsClinicalWhyHere;

  /// No description provided for @insightsClinicalWhyHereHighRisk.
  ///
  /// In en, this message translates to:
  /// **'There is a recent critical alert and the score is high.'**
  String get insightsClinicalWhyHereHighRisk;

  /// No description provided for @insightsClinicalWhyHereWorsening.
  ///
  /// In en, this message translates to:
  /// **'The pattern worsened in the latest comparison.'**
  String get insightsClinicalWhyHereWorsening;

  /// No description provided for @insightsClinicalWhyHereBalanced.
  ///
  /// In en, this message translates to:
  /// **'The signals are balanced, but the evolution is worth following.'**
  String get insightsClinicalWhyHereBalanced;

  /// No description provided for @insightsTrendMealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get insightsTrendMealsLabel;

  /// No description provided for @insightsTrendAlertsLabel.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get insightsTrendAlertsLabel;

  /// No description provided for @insightsTrendWorse.
  ///
  /// In en, this message translates to:
  /// **'worse'**
  String get insightsTrendWorse;

  /// No description provided for @insightsTrendBetter.
  ///
  /// In en, this message translates to:
  /// **'better'**
  String get insightsTrendBetter;

  /// No description provided for @insightsTrendSame.
  ///
  /// In en, this message translates to:
  /// **'stable'**
  String get insightsTrendSame;

  /// No description provided for @insightsTrendActionWorse.
  ///
  /// In en, this message translates to:
  /// **'Needs earlier review'**
  String get insightsTrendActionWorse;

  /// No description provided for @insightsTrendActionBetter.
  ///
  /// In en, this message translates to:
  /// **'Can be reviewed later'**
  String get insightsTrendActionBetter;

  /// No description provided for @insightsPatientPriorityToday.
  ///
  /// In en, this message translates to:
  /// **'{count} to review today'**
  String insightsPatientPriorityToday(int count);

  /// No description provided for @insightsPatientPrioritySoon.
  ///
  /// In en, this message translates to:
  /// **'{count} to review soon'**
  String insightsPatientPrioritySoon(int count);

  /// No description provided for @insightsPatientPriorityStable.
  ///
  /// In en, this message translates to:
  /// **'{count} stable'**
  String insightsPatientPriorityStable(int count);

  /// No description provided for @insightsPatientPriorityWorsening.
  ///
  /// In en, this message translates to:
  /// **'{count} worsening'**
  String insightsPatientPriorityWorsening(int count);

  /// No description provided for @insightsPatientPriorityImproving.
  ///
  /// In en, this message translates to:
  /// **'{count} improving'**
  String insightsPatientPriorityImproving(int count);

  /// No description provided for @insightsDashboardOperationalTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational summary'**
  String get insightsDashboardOperationalTitle;

  /// No description provided for @insightsDashboardOperationalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Case status to prioritize the schedule'**
  String get insightsDashboardOperationalSubtitle;

  /// No description provided for @insightsPatientNarrativeInactive.
  ///
  /// In en, this message translates to:
  /// **'This patient has gone {days} days without a recorded meal and needs review.'**
  String insightsPatientNarrativeInactive(int days);

  /// No description provided for @insightsPatientNarrativeHighAlert.
  ///
  /// In en, this message translates to:
  /// **'There are recent critical signs. It is worth reviewing the events in detail first.'**
  String get insightsPatientNarrativeHighAlert;

  /// No description provided for @insightsPatientNarrativeBalanced.
  ///
  /// In en, this message translates to:
  /// **'The signals are more balanced, so this patient can come after the priority cases.'**
  String get insightsPatientNarrativeBalanced;

  /// No description provided for @insightsPatientDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient detail'**
  String get insightsPatientDetailTitle;

  /// No description provided for @insightsPatientDetailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick clinical summary with signals and trend'**
  String get insightsPatientDetailSubtitle;

  /// No description provided for @insightsPatientDetailSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main signals'**
  String get insightsPatientDetailSignalsTitle;

  /// No description provided for @insightsPatientDetailAlertCount.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get insightsPatientDetailAlertCount;

  /// No description provided for @insightsPatientDetailInactive.
  ///
  /// In en, this message translates to:
  /// **'Days without meals'**
  String get insightsPatientDetailInactive;

  /// No description provided for @insightsPatientDetailNarrativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical reading'**
  String get insightsPatientDetailNarrativeTitle;

  /// No description provided for @insightsPatientDetailRecentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get insightsPatientDetailRecentAlerts;

  /// No description provided for @insightsPatientDetailNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No recent alerts in this period.'**
  String get insightsPatientDetailNoAlerts;

  /// No description provided for @insightsPatientDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This patient could not be opened.'**
  String get insightsPatientDetailNotFound;

  /// No description provided for @insightsTrendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get insightsTrendLabel;

  /// No description provided for @insightsMealsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} meals (7d)'**
  String insightsMealsCount(int count);

  /// No description provided for @insightsAlertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} alerts'**
  String insightsAlertsCount(int count);

  /// No description provided for @insightsInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive for {days} days'**
  String insightsInactive(int days);

  /// No description provided for @insightsLastMeal.
  ///
  /// In en, this message translates to:
  /// **'Last meal: {date}'**
  String insightsLastMeal(String date);

  /// No description provided for @insightsNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get insightsNoMeals;

  /// No description provided for @insightsPeriod7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get insightsPeriod7Days;

  /// No description provided for @insightsPeriodPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get insightsPeriodPreviousWeek;

  /// No description provided for @insightsPeriodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get insightsPeriodThisWeek;

  /// No description provided for @insightsPeriod30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get insightsPeriod30Days;

  /// No description provided for @insightsPeriod90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get insightsPeriod90Days;

  /// No description provided for @insightsViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get insightsViewAnalytics;

  /// No description provided for @insightsAnalyticsMealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'avg meals/day'**
  String get insightsAnalyticsMealsPerDay;

  /// No description provided for @insightsAnalyticsFeelingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get insightsAnalyticsFeelingsTitle;

  /// No description provided for @insightsAnalyticsFeelingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distribution of how the patient felt during meals'**
  String get insightsAnalyticsFeelingsSubtitle;

  /// No description provided for @insightsAnalyticsAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount consumed'**
  String get insightsAnalyticsAmountTitle;

  /// No description provided for @insightsAnalyticsAmountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distribution of how much the patient ate'**
  String get insightsAnalyticsAmountSubtitle;

  /// No description provided for @insightsAnalyticsFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording frequency'**
  String get insightsAnalyticsFrequencyTitle;

  /// No description provided for @insightsAnalyticsFrequencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Heat map of the last days'**
  String get insightsAnalyticsFrequencySubtitle;

  /// No description provided for @insightsAnalyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records in the selected period'**
  String get insightsAnalyticsEmpty;

  /// No description provided for @insightsAnalyticsHeatMapMin.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get insightsAnalyticsHeatMapMin;

  /// No description provided for @insightsAnalyticsHeatMapMax.
  ///
  /// In en, this message translates to:
  /// **'Many'**
  String get insightsAnalyticsHeatMapMax;

  /// No description provided for @insightsAnalyticsTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Aggregate trends'**
  String get insightsAnalyticsTrendTitle;

  /// No description provided for @insightsAnalyticsTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison: current vs previous period'**
  String get insightsAnalyticsTrendSubtitle;

  /// No description provided for @insightsAnalyticsTrendCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get insightsAnalyticsTrendCurrent;

  /// No description provided for @insightsAnalyticsTrendPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get insightsAnalyticsTrendPrevious;

  /// No description provided for @insightsAnalyticsTrendDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'+{delta}'**
  String insightsAnalyticsTrendDeltaUp(int delta);

  /// No description provided for @insightsAnalyticsTrendDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'{delta}'**
  String insightsAnalyticsTrendDeltaDown(int delta);

  /// No description provided for @insightsAnalyticsSkippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Skipped meals'**
  String get insightsAnalyticsSkippedTitle;

  /// No description provided for @insightsAnalyticsSkippedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Records marked as skipped or no consumption, by type'**
  String get insightsAnalyticsSkippedSubtitle;

  /// No description provided for @insightsAnalyticsSkippedFeelingTitle.
  ///
  /// In en, this message translates to:
  /// **'Feelings when skipping meals'**
  String get insightsAnalyticsSkippedFeelingTitle;

  /// No description provided for @insightsAnalyticsSkippedFeelingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How the patient felt when skipping or not eating'**
  String get insightsAnalyticsSkippedFeelingSubtitle;

  /// No description provided for @insightsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at {time}'**
  String insightsUpdatedAt(String time);

  /// No description provided for @insightsMealsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Records in period'**
  String get insightsMealsPeriod;

  /// No description provided for @mealDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal details'**
  String get mealDetailTitle;

  /// No description provided for @mealDetailWhere.
  ///
  /// In en, this message translates to:
  /// **'Where ate'**
  String get mealDetailWhere;

  /// No description provided for @mealDetailWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Ate with others'**
  String get mealDetailWithOthers;

  /// No description provided for @mealDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get mealDetailAmount;

  /// No description provided for @mealDetailFeeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get mealDetailFeeling;

  /// No description provided for @mealDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mealDetailDescription;

  /// No description provided for @mealDetailFeelingText.
  ///
  /// In en, this message translates to:
  /// **'About the feeling'**
  String get mealDetailFeelingText;

  /// No description provided for @mealDetailBehaviors.
  ///
  /// In en, this message translates to:
  /// **'Behaviors'**
  String get mealDetailBehaviors;

  /// No description provided for @mealDetailClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mealDetailClose;

  /// No description provided for @behaviorForcedVomit.
  ///
  /// In en, this message translates to:
  /// **'Self-induced vomiting'**
  String get behaviorForcedVomit;

  /// No description provided for @behaviorUsedLaxatives.
  ///
  /// In en, this message translates to:
  /// **'Laxative use'**
  String get behaviorUsedLaxatives;

  /// No description provided for @behaviorRegurgitated.
  ///
  /// In en, this message translates to:
  /// **'Regurgitation'**
  String get behaviorRegurgitated;

  /// No description provided for @behaviorHiddenFood.
  ///
  /// In en, this message translates to:
  /// **'Hidden food'**
  String get behaviorHiddenFood;

  /// No description provided for @behaviorAteInSecret.
  ///
  /// In en, this message translates to:
  /// **'Ate in secret'**
  String get behaviorAteInSecret;

  /// No description provided for @behaviorDiuretics.
  ///
  /// In en, this message translates to:
  /// **'Diuretic use'**
  String get behaviorDiuretics;

  /// No description provided for @behaviorOtherMedication.
  ///
  /// In en, this message translates to:
  /// **'Other medications'**
  String get behaviorOtherMedication;

  /// No description provided for @behaviorCompensatoryExercise.
  ///
  /// In en, this message translates to:
  /// **'Compensatory exercise'**
  String get behaviorCompensatoryExercise;

  /// No description provided for @behaviorChewAndSpit.
  ///
  /// In en, this message translates to:
  /// **'Chew and spit'**
  String get behaviorChewAndSpit;

  /// No description provided for @behaviorIntermittentFast.
  ///
  /// In en, this message translates to:
  /// **'Intermittent fasting'**
  String get behaviorIntermittentFast;

  /// No description provided for @behaviorSkipMeal.
  ///
  /// In en, this message translates to:
  /// **'Skipped meal'**
  String get behaviorSkipMeal;

  /// No description provided for @behaviorBingeEating.
  ///
  /// In en, this message translates to:
  /// **'Binge eating'**
  String get behaviorBingeEating;

  /// No description provided for @behaviorGuiltAfterEating.
  ///
  /// In en, this message translates to:
  /// **'Guilt after eating'**
  String get behaviorGuiltAfterEating;

  /// No description provided for @behaviorCalorieCounting.
  ///
  /// In en, this message translates to:
  /// **'Calorie counting'**
  String get behaviorCalorieCounting;

  /// No description provided for @behaviorBodyChecking.
  ///
  /// In en, this message translates to:
  /// **'Body checking'**
  String get behaviorBodyChecking;

  /// No description provided for @behaviorBodyWeighing.
  ///
  /// In en, this message translates to:
  /// **'Body weighing'**
  String get behaviorBodyWeighing;

  /// No description provided for @formConfigCategoryCompensatory.
  ///
  /// In en, this message translates to:
  /// **'Compensatory methods'**
  String get formConfigCategoryCompensatory;

  /// No description provided for @formConfigCategoryRestriction.
  ///
  /// In en, this message translates to:
  /// **'Dietary restriction'**
  String get formConfigCategoryRestriction;

  /// No description provided for @formConfigCategoryBinge.
  ///
  /// In en, this message translates to:
  /// **'Binge eating'**
  String get formConfigCategoryBinge;

  /// No description provided for @formConfigCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get formConfigCategoryOther;

  /// No description provided for @formConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Behaviors for the form'**
  String get formConfigTitle;

  /// No description provided for @formConfigPatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Patient: {name}'**
  String formConfigPatientSubtitle(String name);

  /// No description provided for @formConfigSectionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable behavior section in patient form'**
  String get formConfigSectionEnabled;

  /// No description provided for @formConfigLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: by {name} on {date}'**
  String formConfigLastUpdated(String name, String date);

  /// No description provided for @formConfigChangeLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get formConfigChangeLogTitle;

  /// No description provided for @formConfigButton.
  ///
  /// In en, this message translates to:
  /// **'Configure form'**
  String get formConfigButton;

  /// No description provided for @formConfigSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get formConfigSave;

  /// No description provided for @formConfigSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get formConfigSaving;

  /// No description provided for @formConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved!'**
  String get formConfigSaved;

  /// No description provided for @formConfigNoChangesYet.
  ///
  /// In en, this message translates to:
  /// **'No changes recorded yet.'**
  String get formConfigNoChangesYet;

  /// No description provided for @settingsDebugApnsTitle.
  ///
  /// In en, this message translates to:
  /// **'APNS token (debug)'**
  String get settingsDebugApnsTitle;

  /// No description provided for @settingsDebugApnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary — iOS push diagnostics'**
  String get settingsDebugApnsSubtitle;

  /// No description provided for @settingsDebugApnsShow.
  ///
  /// In en, this message translates to:
  /// **'Show APNS token'**
  String get settingsDebugApnsShow;

  /// No description provided for @settingsDebugApnsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get settingsDebugApnsCopy;

  /// No description provided for @settingsDebugApnsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'APNS token not available yet. Reopen the app or wait a few seconds.'**
  String get settingsDebugApnsUnavailable;

  /// No description provided for @settingsDebugApnsCopied.
  ///
  /// In en, this message translates to:
  /// **'APNS token copied'**
  String get settingsDebugApnsCopied;

  /// No description provided for @settingsDebugApnsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get settingsDebugApnsRefresh;

  /// No description provided for @settingsDebugFcmTitle.
  ///
  /// In en, this message translates to:
  /// **'FCM token (debug)'**
  String get settingsDebugFcmTitle;

  /// No description provided for @settingsDebugFcmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same value stored in Firestore for push'**
  String get settingsDebugFcmSubtitle;

  /// No description provided for @settingsDebugFcmShow.
  ///
  /// In en, this message translates to:
  /// **'Show FCM token'**
  String get settingsDebugFcmShow;

  /// No description provided for @settingsDebugFcmCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get settingsDebugFcmCopy;

  /// No description provided for @settingsDebugFcmUnavailable.
  ///
  /// In en, this message translates to:
  /// **'FCM token unavailable. Check notification permission and network.'**
  String get settingsDebugFcmUnavailable;

  /// No description provided for @settingsDebugFcmCopied.
  ///
  /// In en, this message translates to:
  /// **'FCM token copied'**
  String get settingsDebugFcmCopied;

  /// No description provided for @appRatingModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying YummyLog for Clinicians?'**
  String get appRatingModalTitle;

  /// No description provided for @appRatingModalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a star rating to help us improve.'**
  String get appRatingModalSubtitle;

  /// No description provided for @appRatingButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get appRatingButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
