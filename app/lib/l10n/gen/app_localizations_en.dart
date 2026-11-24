// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Driver Registration';

  @override
  String get language => 'Language';

  @override
  String get loginWithPhone => 'Phone';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get phone => 'Phone number';

  @override
  String get phoneHint => '+995 555 123 456';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sendCode => 'Send code';

  @override
  String codeSent(String phone) {
    return 'We sent an SMS code to $phone';
  }

  @override
  String get smsCode => 'SMS code';

  @override
  String get verify => 'Confirm';

  @override
  String get changeNumber => 'Change number';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get noAccount => 'No account yet? Create one';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get checkEmail =>
      'Check your email and confirm your address, then sign in.';

  @override
  String get logout => 'Sign out';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Delete this item?';

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPhone => 'Enter the number with country code, e.g. +995…';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get profile => 'Profile';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get documents => 'Documents';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get citizenship => 'Citizenship';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get country => 'Country';

  @override
  String get driversLicense => 'Driver\'s license';

  @override
  String get licenseNumber => 'License number';

  @override
  String get licenseCategories => 'Categories';

  @override
  String get licenseCountry => 'Issuing country';

  @override
  String get issuedAt => 'Issue date';

  @override
  String get expiresAt => 'Expiry date';

  @override
  String get passport => 'Passport / ID';

  @override
  String get passportNumber => 'Passport or ID number';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get statusPending => 'Under review';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPendingInfo =>
      'Your registration is being reviewed. We will let you know when it is approved.';

  @override
  String get statusApprovedInfo => 'Your registration is approved.';

  @override
  String get statusRejectedInfo =>
      'Your registration needs changes. See the note below.';

  @override
  String get reviewNote => 'Note from reviewer';

  @override
  String get completeProfileFirst => 'Fill in and save your profile first.';

  @override
  String missingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count required documents are missing',
      one: '1 required document is missing',
    );
    return '$_temp0';
  }

  @override
  String get addTruck => 'Add truck';

  @override
  String get addTrailer => 'Add trailer';

  @override
  String get truck => 'Truck';

  @override
  String get trailer => 'Trailer';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get plateNumber => 'License plate';

  @override
  String get plateCountry => 'Plate country';

  @override
  String get vin => 'VIN';

  @override
  String get trailerType => 'Trailer type';

  @override
  String get noVehicles => 'No vehicles yet. Add your truck.';

  @override
  String get vehicleDocuments => 'Photos and documents';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get notUploaded => 'Not uploaded';

  @override
  String get replace => 'Replace';

  @override
  String get view => 'View';

  @override
  String get requiredMark => 'Required';

  @override
  String get fileTooLarge => 'File is too large (max 10 MB)';

  @override
  String errorGeneric(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get admin => 'Admin panel';

  @override
  String get drivers => 'Drivers';

  @override
  String get all => 'All';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReason => 'Reason (the driver will see it)';

  @override
  String get search => 'Search by name, phone or plate';

  @override
  String get noDrivers => 'No drivers found';

  @override
  String registeredOn(String date) {
    return 'Registered $date';
  }

  @override
  String get notConfigured =>
      'The app is not connected to a server yet. Start it with SUPABASE_URL and SUPABASE_ANON_KEY.';

  @override
  String get edit => 'Edit';

  @override
  String get downloadAll => 'Download all';

  @override
  String get downloadDriver => 'Download';

  @override
  String get preparingDownload => 'Preparing files…';

  @override
  String get downloadSaved => 'Saved';

  @override
  String get loginWithWhatsapp => 'WhatsApp';

  @override
  String get loginWithSms => 'SMS';

  @override
  String get getCodeWhatsapp => 'Get code on WhatsApp';

  @override
  String codeSentWhatsapp(String phone) {
    return 'We sent a code to $phone on WhatsApp';
  }

  @override
  String get code => 'Code';

  @override
  String get setupTitle => 'Quick registration';

  @override
  String stepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get stepAboutYou => 'About you';

  @override
  String get stepTruck => 'Your truck';

  @override
  String get stepPhotos => 'Document photos';

  @override
  String get stepPhotosHint =>
      'Take a photo of each document with your phone camera.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip for now';

  @override
  String get finish => 'Finish';

  @override
  String get setupDoneInfo =>
      'Thank you! Your registration was sent for review. You can add more details any time.';

  @override
  String get routes => 'Routes';

  @override
  String get addRoute => 'Add route';

  @override
  String get editRoute => 'Edit route';

  @override
  String get fromCity => 'From (city)';

  @override
  String get toCity => 'To (city)';

  @override
  String get departAt => 'Leaving';

  @override
  String get arriveFrom => 'Arrival from';

  @override
  String get arriveTo => 'Arrival until';

  @override
  String get freeForCargo => 'Free for new cargo at destination';

  @override
  String get freeForCargoShort => 'Free for cargo';

  @override
  String get note => 'Note';

  @override
  String get routeStatus => 'Trip status';

  @override
  String get routePlanned => 'Planned';

  @override
  String get routeOnTheWay => 'On the way';

  @override
  String get routeDone => 'Finished';

  @override
  String get routeCancelled => 'Cancelled';

  @override
  String get noRoutes =>
      'No routes yet. Add where you are going and when you will arrive.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notifDriverApproved => 'Your registration is approved';

  @override
  String get notifDriverRejected => 'Your registration needs changes';

  @override
  String get notifDocRejected => 'A document was rejected';

  @override
  String get notifNewDriver => 'New driver registered';

  @override
  String get notifNewRoute => 'New route added';

  @override
  String get arrival => 'Arrival';

  @override
  String get notSet => 'Not set';

  @override
  String get liveMap => 'Live map';

  @override
  String get shareLocation => 'Share my location';

  @override
  String get shareLocationInfo =>
      'The dispatcher sees where your truck is. You can turn it off any time.';

  @override
  String get locationOff => 'Location is turned off on this device';

  @override
  String get locationDenied => 'Location permission was not given';

  @override
  String lastSeen(String time) {
    return 'Updated $time';
  }

  @override
  String get trackingNotifTitle => 'TD is sharing your location';

  @override
  String get trackingNotifText => 'You can turn it off in the Routes tab';

  @override
  String get noLiveTrucks => 'No trucks are sharing their location right now';

  @override
  String speedKmh(String speed) {
    return '$speed km/h';
  }
}
