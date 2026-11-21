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
}
