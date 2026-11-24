// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Регистрация водителя';

  @override
  String get language => 'Язык';

  @override
  String get loginWithPhone => 'Телефон';

  @override
  String get loginWithEmail => 'Эл. почта';

  @override
  String get phone => 'Номер телефона';

  @override
  String get phoneHint => '+995 555 123 456';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get sendCode => 'Отправить код';

  @override
  String codeSent(String phone) {
    return 'Мы отправили SMS-код на $phone';
  }

  @override
  String get smsCode => 'SMS-код';

  @override
  String get verify => 'Подтвердить';

  @override
  String get changeNumber => 'Изменить номер';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Создать аккаунт';

  @override
  String get noAccount => 'Нет аккаунта? Создайте';

  @override
  String get haveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get checkEmail =>
      'Проверьте почту и подтвердите адрес, затем войдите.';

  @override
  String get logout => 'Выйти';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteConfirm => 'Удалить этот элемент?';

  @override
  String get required => 'Обязательное поле';

  @override
  String get invalidEmail => 'Введите корректный адрес';

  @override
  String get invalidPhone => 'Введите номер с кодом страны, например +995…';

  @override
  String get passwordTooShort => 'Минимум 8 символов';

  @override
  String get profile => 'Профиль';

  @override
  String get vehicles => 'Транспорт';

  @override
  String get documents => 'Документы';

  @override
  String get personalInfo => 'Личные данные';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get dateOfBirth => 'Дата рождения';

  @override
  String get citizenship => 'Гражданство';

  @override
  String get address => 'Адрес';

  @override
  String get city => 'Город';

  @override
  String get country => 'Страна';

  @override
  String get driversLicense => 'Водительское удостоверение';

  @override
  String get licenseNumber => 'Номер удостоверения';

  @override
  String get licenseCategories => 'Категории';

  @override
  String get licenseCountry => 'Страна выдачи';

  @override
  String get issuedAt => 'Дата выдачи';

  @override
  String get expiresAt => 'Действует до';

  @override
  String get passport => 'Паспорт / удостоверение';

  @override
  String get passportNumber => 'Номер паспорта или удостоверения';

  @override
  String get profilePhoto => 'Фото профиля';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get statusPending => 'На проверке';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get statusPendingInfo =>
      'Ваша регистрация на проверке. Мы сообщим, когда она будет одобрена.';

  @override
  String get statusApprovedInfo => 'Ваша регистрация одобрена.';

  @override
  String get statusRejectedInfo =>
      'Регистрацию нужно исправить. См. комментарий ниже.';

  @override
  String get reviewNote => 'Комментарий проверяющего';

  @override
  String get completeProfileFirst => 'Сначала заполните и сохраните профиль.';

  @override
  String missingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не хватает $count обязательных документов',
      few: 'Не хватает $count обязательных документов',
      one: 'Не хватает 1 обязательного документа',
    );
    return '$_temp0';
  }

  @override
  String get addTruck => 'Добавить грузовик';

  @override
  String get addTrailer => 'Добавить прицеп';

  @override
  String get truck => 'Грузовик';

  @override
  String get trailer => 'Прицеп';

  @override
  String get make => 'Марка';

  @override
  String get model => 'Модель';

  @override
  String get year => 'Год выпуска';

  @override
  String get plateNumber => 'Госномер';

  @override
  String get plateCountry => 'Страна регистрации';

  @override
  String get vin => 'VIN';

  @override
  String get trailerType => 'Тип прицепа';

  @override
  String get noVehicles => 'Транспорта пока нет. Добавьте грузовик.';

  @override
  String get vehicleDocuments => 'Фото и документы';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFile => 'Выбрать файл';

  @override
  String get uploaded => 'Загружено';

  @override
  String get notUploaded => 'Не загружено';

  @override
  String get replace => 'Заменить';

  @override
  String get view => 'Открыть';

  @override
  String get requiredMark => 'Обязательно';

  @override
  String get fileTooLarge => 'Файл слишком большой (макс. 10 МБ)';

  @override
  String errorGeneric(String message) {
    return 'Что-то пошло не так: $message';
  }

  @override
  String get admin => 'Панель администратора';

  @override
  String get drivers => 'Водители';

  @override
  String get all => 'Все';

  @override
  String get approve => 'Одобрить';

  @override
  String get reject => 'Отклонить';

  @override
  String get rejectReason => 'Причина (водитель её увидит)';

  @override
  String get search => 'Поиск по имени, телефону или номеру';

  @override
  String get noDrivers => 'Водители не найдены';

  @override
  String registeredOn(String date) {
    return 'Зарегистрирован $date';
  }

  @override
  String get notConfigured =>
      'Приложение ещё не подключено к серверу. Запустите его с SUPABASE_URL и SUPABASE_ANON_KEY.';

  @override
  String get edit => 'Изменить';

  @override
  String get downloadAll => 'Скачать всё';

  @override
  String get downloadDriver => 'Скачать';

  @override
  String get preparingDownload => 'Подготовка файлов…';

  @override
  String get downloadSaved => 'Сохранено';

  @override
  String get loginWithWhatsapp => 'WhatsApp';

  @override
  String get loginWithSms => 'SMS';

  @override
  String get getCodeWhatsapp => 'Получить код в WhatsApp';

  @override
  String codeSentWhatsapp(String phone) {
    return 'Мы отправили код на $phone в WhatsApp';
  }

  @override
  String get code => 'Код';

  @override
  String get setupTitle => 'Быстрая регистрация';

  @override
  String stepOf(int n, int total) {
    return 'Шаг $n из $total';
  }

  @override
  String get stepAboutYou => 'О вас';

  @override
  String get stepTruck => 'Ваш грузовик';

  @override
  String get stepPhotos => 'Фото документов';

  @override
  String get stepPhotosHint =>
      'Сфотографируйте каждый документ камерой телефона.';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get skip => 'Пропустить';

  @override
  String get finish => 'Готово';

  @override
  String get setupDoneInfo =>
      'Спасибо! Ваша регистрация отправлена на проверку. Вы можете добавить данные в любое время.';
}
