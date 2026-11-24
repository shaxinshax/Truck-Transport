import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ka'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Registration'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginWithPhone;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginWithEmail;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+995 555 123 456'**
  String get phoneHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent an SMS code to {phone}'**
  String codeSent(String phone);

  /// No description provided for @smsCode.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get smsCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verify;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Create one'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email and confirm your address, then sign in.'**
  String get checkEmail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteConfirm;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the number with country code, e.g. +995…'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @citizenship.
  ///
  /// In en, this message translates to:
  /// **'Citizenship'**
  String get citizenship;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @driversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get driversLicense;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get licenseNumber;

  /// No description provided for @licenseCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get licenseCategories;

  /// No description provided for @licenseCountry.
  ///
  /// In en, this message translates to:
  /// **'Issuing country'**
  String get licenseCountry;

  /// No description provided for @issuedAt.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issuedAt;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiresAt;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport / ID'**
  String get passport;

  /// No description provided for @passportNumber.
  ///
  /// In en, this message translates to:
  /// **'Passport or ID number'**
  String get passportNumber;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusPendingInfo.
  ///
  /// In en, this message translates to:
  /// **'Your registration is being reviewed. We will let you know when it is approved.'**
  String get statusPendingInfo;

  /// No description provided for @statusApprovedInfo.
  ///
  /// In en, this message translates to:
  /// **'Your registration is approved.'**
  String get statusApprovedInfo;

  /// No description provided for @statusRejectedInfo.
  ///
  /// In en, this message translates to:
  /// **'Your registration needs changes. See the note below.'**
  String get statusRejectedInfo;

  /// No description provided for @reviewNote.
  ///
  /// In en, this message translates to:
  /// **'Note from reviewer'**
  String get reviewNote;

  /// No description provided for @completeProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Fill in and save your profile first.'**
  String get completeProfileFirst;

  /// No description provided for @missingRequired.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 required document is missing} other{{count} required documents are missing}}'**
  String missingRequired(int count);

  /// No description provided for @addTruck.
  ///
  /// In en, this message translates to:
  /// **'Add truck'**
  String get addTruck;

  /// No description provided for @addTrailer.
  ///
  /// In en, this message translates to:
  /// **'Add trailer'**
  String get addTrailer;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @trailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// No description provided for @make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get plateNumber;

  /// No description provided for @plateCountry.
  ///
  /// In en, this message translates to:
  /// **'Plate country'**
  String get plateCountry;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// No description provided for @trailerType.
  ///
  /// In en, this message translates to:
  /// **'Trailer type'**
  String get trailerType;

  /// No description provided for @noVehicles.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet. Add your truck.'**
  String get noVehicles;

  /// No description provided for @vehicleDocuments.
  ///
  /// In en, this message translates to:
  /// **'Photos and documents'**
  String get vehicleDocuments;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get notUploaded;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @requiredMark.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredMark;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large (max 10 MB)'**
  String get fileTooLarge;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String errorGeneric(String message);

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get admin;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (the driver will see it)'**
  String get rejectReason;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone or plate'**
  String get search;

  /// No description provided for @noDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get noDrivers;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered {date}'**
  String registeredOn(String date);

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'The app is not connected to a server yet. Start it with SUPABASE_URL and SUPABASE_ANON_KEY.'**
  String get notConfigured;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get downloadAll;

  /// No description provided for @downloadDriver.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadDriver;

  /// No description provided for @preparingDownload.
  ///
  /// In en, this message translates to:
  /// **'Preparing files…'**
  String get preparingDownload;

  /// No description provided for @downloadSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get downloadSaved;

  /// No description provided for @loginWithWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get loginWithWhatsapp;

  /// No description provided for @loginWithSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get loginWithSms;

  /// No description provided for @getCodeWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Get code on WhatsApp'**
  String get getCodeWhatsapp;

  /// No description provided for @codeSentWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone} on WhatsApp'**
  String codeSentWhatsapp(String phone);

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick registration'**
  String get setupTitle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String stepOf(int n, int total);

  /// No description provided for @stepAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get stepAboutYou;

  /// No description provided for @stepTruck.
  ///
  /// In en, this message translates to:
  /// **'Your truck'**
  String get stepTruck;

  /// No description provided for @stepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Document photos'**
  String get stepPhotos;

  /// No description provided for @stepPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of each document with your phone camera.'**
  String get stepPhotosHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @setupDoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your registration was sent for review. You can add more details any time.'**
  String get setupDoneInfo;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add route'**
  String get addRoute;

  /// No description provided for @editRoute.
  ///
  /// In en, this message translates to:
  /// **'Edit route'**
  String get editRoute;

  /// No description provided for @fromCity.
  ///
  /// In en, this message translates to:
  /// **'From (city)'**
  String get fromCity;

  /// No description provided for @toCity.
  ///
  /// In en, this message translates to:
  /// **'To (city)'**
  String get toCity;

  /// No description provided for @departAt.
  ///
  /// In en, this message translates to:
  /// **'Leaving'**
  String get departAt;

  /// No description provided for @arriveFrom.
  ///
  /// In en, this message translates to:
  /// **'Arrival from'**
  String get arriveFrom;

  /// No description provided for @arriveTo.
  ///
  /// In en, this message translates to:
  /// **'Arrival until'**
  String get arriveTo;

  /// No description provided for @freeForCargo.
  ///
  /// In en, this message translates to:
  /// **'Free for new cargo at destination'**
  String get freeForCargo;

  /// No description provided for @freeForCargoShort.
  ///
  /// In en, this message translates to:
  /// **'Free for cargo'**
  String get freeForCargoShort;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @routeStatus.
  ///
  /// In en, this message translates to:
  /// **'Trip status'**
  String get routeStatus;

  /// No description provided for @routePlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get routePlanned;

  /// No description provided for @routeOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get routeOnTheWay;

  /// No description provided for @routeDone.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get routeDone;

  /// No description provided for @routeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get routeCancelled;

  /// No description provided for @noRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes yet. Add where you are going and when you will arrive.'**
  String get noRoutes;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notifDriverApproved.
  ///
  /// In en, this message translates to:
  /// **'Your registration is approved'**
  String get notifDriverApproved;

  /// No description provided for @notifDriverRejected.
  ///
  /// In en, this message translates to:
  /// **'Your registration needs changes'**
  String get notifDriverRejected;

  /// No description provided for @notifDocRejected.
  ///
  /// In en, this message translates to:
  /// **'A document was rejected'**
  String get notifDocRejected;

  /// No description provided for @notifNewDriver.
  ///
  /// In en, this message translates to:
  /// **'New driver registered'**
  String get notifNewDriver;

  /// No description provided for @notifNewRoute.
  ///
  /// In en, this message translates to:
  /// **'New route added'**
  String get notifNewRoute;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @liveMap.
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get liveMap;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get shareLocation;

  /// No description provided for @shareLocationInfo.
  ///
  /// In en, this message translates to:
  /// **'The dispatcher sees where your truck is. You can turn it off any time.'**
  String get shareLocationInfo;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this device'**
  String get locationOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was not given'**
  String get locationDenied;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String lastSeen(String time);

  /// No description provided for @trackingNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'TD is sharing your location'**
  String get trackingNotifTitle;

  /// No description provided for @trackingNotifText.
  ///
  /// In en, this message translates to:
  /// **'You can turn it off in the Routes tab'**
  String get trackingNotifText;

  /// No description provided for @noLiveTrucks.
  ///
  /// In en, this message translates to:
  /// **'No trucks are sharing their location right now'**
  String get noLiveTrucks;

  /// No description provided for @speedKmh.
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h'**
  String speedKmh(String speed);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ka', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ka':
      return AppLocalizationsKa();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
