// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get sectionGameplay => 'Juego';

  @override
  String get sectionDailyReminder => 'Recordatorio diario';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Privacidad e información';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get theme => 'Tema';

  @override
  String get themeAutoSubtitle => 'Automático (sigue tu dispositivo)';

  @override
  String get themeAuto => 'Automático';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get colorblindTitle => 'Colores para daltónicos';

  @override
  String get colorblindSubtitle => 'Resaltado azul/naranja en lugar de rojo';

  @override
  String get errorCheckingTitle => 'Comprobación de errores';

  @override
  String get errorCheckingSubtitle =>
      'Marca las letras erróneas cuando el tablero esté lleno';

  @override
  String get showTimerTitle => 'Mostrar cronómetro';

  @override
  String get showTimerSubtitle =>
      'Desactívalo para una experiencia totalmente zen';

  @override
  String get hapticsTitle => 'Respuesta háptica';

  @override
  String get soundEffectsTitle => 'Efectos de sonido';

  @override
  String get soundEffectsSubtitle => 'Toques de tecla suaves y tonos delicados';

  @override
  String get effectsVolume => 'Volumen de efectos';

  @override
  String get musicTitle => 'Música';

  @override
  String get musicSubtitle => 'Música ambiental tranquila mientras juegas';

  @override
  String get musicVolume => 'Volumen de música';

  @override
  String get remindMeDaily => 'Recordármelo a diario';

  @override
  String reminderAt(String time) {
    return 'A las $time';
  }

  @override
  String get neverMissStreak => 'No pierdas tu racha';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get reminderDenied =>
      'Se denegó el permiso de notificaciones en los ajustes del sistema.';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get premiumActiveSubtitle => '¡Gracias por apoyar Quotecrack!';

  @override
  String get goPremium => 'Hazte Premium';

  @override
  String get goPremiumSubtitle =>
      'Sin anuncios, pistas ilimitadas, packs extra';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get checkingPurchases => 'Comprobando compras anteriores…';

  @override
  String get privacyOptions => 'Opciones de privacidad';

  @override
  String get privacyOptionsSubtitle =>
      'Gestiona tus preferencias de consentimiento de anuncios';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get version => 'Versión';
}
