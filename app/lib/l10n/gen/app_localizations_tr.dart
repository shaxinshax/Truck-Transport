// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sürücü Kaydı';

  @override
  String get language => 'Dil';

  @override
  String get loginWithPhone => 'Telefon';

  @override
  String get loginWithEmail => 'E-posta';

  @override
  String get phone => 'Telefon numarası';

  @override
  String get phoneHint => '+90 555 123 45 67';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get sendCode => 'Kod gönder';

  @override
  String codeSent(String phone) {
    return '$phone numarasına SMS kodu gönderdik';
  }

  @override
  String get smsCode => 'SMS kodu';

  @override
  String get verify => 'Onayla';

  @override
  String get changeNumber => 'Numarayı değiştir';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Hesap oluştur';

  @override
  String get noAccount => 'Hesabınız yok mu? Oluşturun';

  @override
  String get haveAccount => 'Zaten hesabınız var mı? Giriş yapın';

  @override
  String get checkEmail =>
      'E-postanızı kontrol edip adresinizi onaylayın, ardından giriş yapın.';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get deleteConfirm => 'Bu öğe silinsin mi?';

  @override
  String get required => 'Zorunlu alan';

  @override
  String get invalidEmail => 'Geçerli bir e-posta girin';

  @override
  String get invalidPhone => 'Numarayı ülke koduyla girin, ör. +90…';

  @override
  String get passwordTooShort => 'En az 8 karakter';

  @override
  String get profile => 'Profil';

  @override
  String get vehicles => 'Araçlar';

  @override
  String get documents => 'Belgeler';

  @override
  String get personalInfo => 'Kişisel bilgiler';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get dateOfBirth => 'Doğum tarihi';

  @override
  String get citizenship => 'Vatandaşlık';

  @override
  String get address => 'Adres';

  @override
  String get city => 'Şehir';

  @override
  String get country => 'Ülke';

  @override
  String get driversLicense => 'Ehliyet';

  @override
  String get licenseNumber => 'Ehliyet numarası';

  @override
  String get licenseCategories => 'Sınıflar';

  @override
  String get licenseCountry => 'Veren ülke';

  @override
  String get issuedAt => 'Veriliş tarihi';

  @override
  String get expiresAt => 'Son geçerlilik tarihi';

  @override
  String get passport => 'Pasaport / Kimlik';

  @override
  String get passportNumber => 'Pasaport veya kimlik numarası';

  @override
  String get profilePhoto => 'Profil fotoğrafı';

  @override
  String get changePhoto => 'Fotoğrafı değiştir';

  @override
  String get statusPending => 'İnceleniyor';

  @override
  String get statusApproved => 'Onaylandı';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String get statusPendingInfo =>
      'Kaydınız inceleniyor. Onaylandığında size haber vereceğiz.';

  @override
  String get statusApprovedInfo => 'Kaydınız onaylandı.';

  @override
  String get statusRejectedInfo =>
      'Kaydınızda düzeltme gerekiyor. Aşağıdaki nota bakın.';

  @override
  String get reviewNote => 'İnceleyenin notu';

  @override
  String get completeProfileFirst => 'Önce profilinizi doldurup kaydedin.';

  @override
  String missingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zorunlu belge eksik',
    );
    return '$_temp0';
  }

  @override
  String get addTruck => 'Kamyon ekle';

  @override
  String get addTrailer => 'Dorse ekle';

  @override
  String get truck => 'Kamyon';

  @override
  String get trailer => 'Dorse';

  @override
  String get make => 'Marka';

  @override
  String get model => 'Model';

  @override
  String get year => 'Model yılı';

  @override
  String get plateNumber => 'Plaka';

  @override
  String get plateCountry => 'Plaka ülkesi';

  @override
  String get vin => 'Şasi numarası (VIN)';

  @override
  String get trailerType => 'Dorse tipi';

  @override
  String get noVehicles => 'Henüz araç yok. Kamyonunuzu ekleyin.';

  @override
  String get vehicleDocuments => 'Fotoğraflar ve belgeler';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get chooseFile => 'Dosya seç';

  @override
  String get uploaded => 'Yüklendi';

  @override
  String get notUploaded => 'Yüklenmedi';

  @override
  String get replace => 'Değiştir';

  @override
  String get view => 'Görüntüle';

  @override
  String get requiredMark => 'Zorunlu';

  @override
  String get fileTooLarge => 'Dosya çok büyük (en fazla 10 MB)';

  @override
  String errorGeneric(String message) {
    return 'Bir şeyler ters gitti: $message';
  }

  @override
  String get admin => 'Yönetim paneli';

  @override
  String get drivers => 'Sürücüler';

  @override
  String get all => 'Tümü';

  @override
  String get approve => 'Onayla';

  @override
  String get reject => 'Reddet';

  @override
  String get rejectReason => 'Neden (sürücü görecek)';

  @override
  String get search => 'Ad, telefon veya plakaya göre ara';

  @override
  String get noDrivers => 'Sürücü bulunamadı';

  @override
  String registeredOn(String date) {
    return 'Kayıt tarihi $date';
  }

  @override
  String get notConfigured =>
      'Uygulama henüz bir sunucuya bağlı değil. SUPABASE_URL ve SUPABASE_ANON_KEY ile başlatın.';

  @override
  String get edit => 'Düzenle';

  @override
  String get downloadAll => 'Tümünü indir';

  @override
  String get downloadDriver => 'İndir';

  @override
  String get preparingDownload => 'Dosyalar hazırlanıyor…';

  @override
  String get downloadSaved => 'Kaydedildi';

  @override
  String get loginWithWhatsapp => 'WhatsApp';

  @override
  String get loginWithSms => 'SMS';

  @override
  String get getCodeWhatsapp => 'Kodu WhatsApp\'tan al';

  @override
  String codeSentWhatsapp(String phone) {
    return '$phone numarasına WhatsApp\'tan kod gönderdik';
  }

  @override
  String get code => 'Kod';

  @override
  String get setupTitle => 'Hızlı kayıt';

  @override
  String stepOf(int n, int total) {
    return 'Adım $n / $total';
  }

  @override
  String get stepAboutYou => 'Hakkınızda';

  @override
  String get stepTruck => 'Kamyonunuz';

  @override
  String get stepPhotos => 'Belge fotoğrafları';

  @override
  String get stepPhotosHint =>
      'Her belgenin fotoğrafını telefon kameranızla çekin.';

  @override
  String get next => 'İleri';

  @override
  String get back => 'Geri';

  @override
  String get skip => 'Şimdilik atla';

  @override
  String get finish => 'Bitir';

  @override
  String get setupDoneInfo =>
      'Teşekkürler! Kaydınız incelemeye gönderildi. Daha fazla bilgiyi istediğiniz zaman ekleyebilirsiniz.';

  @override
  String get routes => 'Rotalar';

  @override
  String get addRoute => 'Rota ekle';

  @override
  String get editRoute => 'Rotayı düzenle';

  @override
  String get fromCity => 'Nereden (şehir)';

  @override
  String get toCity => 'Nereye (şehir)';

  @override
  String get departAt => 'Çıkış';

  @override
  String get arriveFrom => 'Varış (en erken)';

  @override
  String get arriveTo => 'Varış (en geç)';

  @override
  String get freeForCargo => 'Varış noktasında yeni yük için müsait';

  @override
  String get freeForCargoShort => 'Yük için müsait';

  @override
  String get note => 'Not';

  @override
  String get routeStatus => 'Sefer durumu';

  @override
  String get routePlanned => 'Planlandı';

  @override
  String get routeOnTheWay => 'Yolda';

  @override
  String get routeDone => 'Tamamlandı';

  @override
  String get routeCancelled => 'İptal edildi';

  @override
  String get noRoutes =>
      'Henüz rota yok. Nereye gittiğinizi ve ne zaman varacağınızı ekleyin.';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get noNotifications => 'Henüz bildirim yok';

  @override
  String get notifDriverApproved => 'Kaydınız onaylandı';

  @override
  String get notifDriverRejected => 'Kaydınızda değişiklik gerekiyor';

  @override
  String get notifDocRejected => 'Bir belge reddedildi';

  @override
  String get notifNewDriver => 'Yeni sürücü kaydoldu';

  @override
  String get notifNewRoute => 'Yeni rota eklendi';

  @override
  String get arrival => 'Varış';

  @override
  String get notSet => 'Belirtilmedi';

  @override
  String get liveMap => 'Canlı harita';

  @override
  String get shareLocation => 'Konumumu paylaş';

  @override
  String get shareLocationInfo =>
      'Görevli kamyonunuzun nerede olduğunu görür. İstediğiniz zaman kapatabilirsiniz.';

  @override
  String get locationOff => 'Bu cihazda konum kapalı';

  @override
  String get locationDenied => 'Konum izni verilmedi';

  @override
  String lastSeen(String time) {
    return 'Güncellendi $time';
  }

  @override
  String get trackingNotifTitle => 'TD konumunuzu paylaşıyor';

  @override
  String get trackingNotifText => 'Rotalar sekmesinden kapatabilirsiniz';

  @override
  String get noLiveTrucks => 'Şu anda konumunu paylaşan kamyon yok';

  @override
  String speedKmh(String speed) {
    return '$speed km/sa';
  }
}
