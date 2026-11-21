// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appTitle => 'მძღოლის რეგისტრაცია';

  @override
  String get language => 'ენა';

  @override
  String get loginWithPhone => 'ტელეფონი';

  @override
  String get loginWithEmail => 'ელ. ფოსტა';

  @override
  String get phone => 'ტელეფონის ნომერი';

  @override
  String get phoneHint => '+995 555 123 456';

  @override
  String get email => 'ელ. ფოსტა';

  @override
  String get password => 'პაროლი';

  @override
  String get sendCode => 'კოდის გაგზავნა';

  @override
  String codeSent(String phone) {
    return 'SMS კოდი გამოგზავნილია ნომერზე $phone';
  }

  @override
  String get smsCode => 'SMS კოდი';

  @override
  String get verify => 'დადასტურება';

  @override
  String get changeNumber => 'ნომრის შეცვლა';

  @override
  String get signIn => 'შესვლა';

  @override
  String get signUp => 'ანგარიშის შექმნა';

  @override
  String get noAccount => 'არ გაქვთ ანგარიში? შექმენით';

  @override
  String get haveAccount => 'უკვე გაქვთ ანგარიში? შედით';

  @override
  String get checkEmail =>
      'შეამოწმეთ ელ. ფოსტა, დაადასტურეთ მისამართი და შემდეგ შედით.';

  @override
  String get logout => 'გასვლა';

  @override
  String get save => 'შენახვა';

  @override
  String get saved => 'შენახულია';

  @override
  String get cancel => 'გაუქმება';

  @override
  String get delete => 'წაშლა';

  @override
  String get deleteConfirm => 'წავშალოთ ეს ჩანაწერი?';

  @override
  String get required => 'სავალდებულო ველი';

  @override
  String get invalidEmail => 'შეიყვანეთ სწორი ელ. ფოსტა';

  @override
  String get invalidPhone => 'შეიყვანეთ ნომერი ქვეყნის კოდით, მაგ. +995…';

  @override
  String get passwordTooShort => 'მინიმუმ 8 სიმბოლო';

  @override
  String get profile => 'პროფილი';

  @override
  String get vehicles => 'ტრანსპორტი';

  @override
  String get documents => 'დოკუმენტები';

  @override
  String get personalInfo => 'პირადი ინფორმაცია';

  @override
  String get firstName => 'სახელი';

  @override
  String get lastName => 'გვარი';

  @override
  String get dateOfBirth => 'დაბადების თარიღი';

  @override
  String get citizenship => 'მოქალაქეობა';

  @override
  String get address => 'მისამართი';

  @override
  String get city => 'ქალაქი';

  @override
  String get country => 'ქვეყანა';

  @override
  String get driversLicense => 'მართვის მოწმობა';

  @override
  String get licenseNumber => 'მოწმობის ნომერი';

  @override
  String get licenseCategories => 'კატეგორიები';

  @override
  String get licenseCountry => 'გამცემი ქვეყანა';

  @override
  String get issuedAt => 'გაცემის თარიღი';

  @override
  String get expiresAt => 'მოქმედების ვადა';

  @override
  String get passport => 'პასპორტი / პირადობა';

  @override
  String get passportNumber => 'პასპორტის ან პირადობის ნომერი';

  @override
  String get profilePhoto => 'პროფილის ფოტო';

  @override
  String get changePhoto => 'ფოტოს შეცვლა';

  @override
  String get statusPending => 'განხილვაშია';

  @override
  String get statusApproved => 'დადასტურებულია';

  @override
  String get statusRejected => 'უარყოფილია';

  @override
  String get statusPendingInfo =>
      'თქვენი რეგისტრაცია განხილვის პროცესშია. დადასტურების შემდეგ შეგატყობინებთ.';

  @override
  String get statusApprovedInfo => 'თქვენი რეგისტრაცია დადასტურებულია.';

  @override
  String get statusRejectedInfo =>
      'რეგისტრაციას სჭირდება შესწორება. იხილეთ შენიშვნა ქვემოთ.';

  @override
  String get reviewNote => 'შემმოწმებლის შენიშვნა';

  @override
  String get completeProfileFirst => 'ჯერ შეავსეთ და შეინახეთ პროფილი.';

  @override
  String missingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'აკლია $count სავალდებულო დოკუმენტი',
    );
    return '$_temp0';
  }

  @override
  String get addTruck => 'სატვირთოს დამატება';

  @override
  String get addTrailer => 'მისაბმელის დამატება';

  @override
  String get truck => 'სატვირთო';

  @override
  String get trailer => 'მისაბმელი';

  @override
  String get make => 'მარკა';

  @override
  String get model => 'მოდელი';

  @override
  String get year => 'გამოშვების წელი';

  @override
  String get plateNumber => 'სახელმწიფო ნომერი';

  @override
  String get plateCountry => 'რეგისტრაციის ქვეყანა';

  @override
  String get vin => 'VIN';

  @override
  String get trailerType => 'მისაბმელის ტიპი';

  @override
  String get noVehicles => 'ტრანსპორტი ჯერ არ არის. დაამატეთ სატვირთო.';

  @override
  String get vehicleDocuments => 'ფოტოები და დოკუმენტები';

  @override
  String get takePhoto => 'ფოტოს გადაღება';

  @override
  String get chooseFile => 'ფაილის არჩევა';

  @override
  String get uploaded => 'ატვირთულია';

  @override
  String get notUploaded => 'არ არის ატვირთული';

  @override
  String get replace => 'შეცვლა';

  @override
  String get view => 'ნახვა';

  @override
  String get requiredMark => 'სავალდებულო';

  @override
  String get fileTooLarge => 'ფაილი ძალიან დიდია (მაქს. 10 MB)';

  @override
  String errorGeneric(String message) {
    return 'დაფიქსირდა შეცდომა: $message';
  }

  @override
  String get admin => 'ადმინისტრატორის პანელი';

  @override
  String get drivers => 'მძღოლები';

  @override
  String get all => 'ყველა';

  @override
  String get approve => 'დადასტურება';

  @override
  String get reject => 'უარყოფა';

  @override
  String get rejectReason => 'მიზეზი (მძღოლი დაინახავს)';

  @override
  String get search => 'ძებნა სახელით, ტელეფონით ან ნომრით';

  @override
  String get noDrivers => 'მძღოლები ვერ მოიძებნა';

  @override
  String registeredOn(String date) {
    return 'დარეგისტრირდა $date';
  }

  @override
  String get notConfigured =>
      'აპლიკაცია ჯერ არ არის სერვერთან დაკავშირებული. გაუშვით SUPABASE_URL და SUPABASE_ANON_KEY პარამეტრებით.';

  @override
  String get edit => 'რედაქტირება';
}
