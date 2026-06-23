// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutThisQuote => 'Sobre esta cita';

  @override
  String a11yLetterCellEmpty(String letter) {
    return 'Letra $letter, vacía';
  }

  @override
  String a11yLetterCellFilled(String letter, String guess) {
    return 'Letra $letter, respuesta $guess';
  }

  @override
  String get a11yDismiss => 'Cerrar';

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

  @override
  String get homeDailyLabel => 'PUZLE DIARIO';

  @override
  String get homeDailySolved => '¡Resuelto! Vuelve mañana por uno nuevo.';

  @override
  String homeDailyAwaits(String author) {
    return 'Te espera un cifrado de $author.';
  }

  @override
  String get pressBackAgainToExit => 'Pulsa atrás de nuevo para salir';

  @override
  String get homeContinueLabel => 'CONTINUAR';

  @override
  String get homeContinueSubtitle => 'Retoma donde lo dejaste';

  @override
  String get continuePlaying => 'Continuar';

  @override
  String get playNow => 'Jugar ahora';

  @override
  String get replay => 'Volver a jugar';

  @override
  String get puzzlePacks => 'Paquetes de puzles';

  @override
  String packsSolved(int solved, int total) {
    return '$solved de $total resueltos';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get statisticsSubtitle => 'Rachas, tiempos y tu mapa de actividad';

  @override
  String get achievements => 'Logros';

  @override
  String achievementsUnlocked(int count) {
    return '$count desbloqueados';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Sin anuncios · pistas ilimitadas · packs extra';

  @override
  String get musicToggleTooltip => 'Música sí/no';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Resuelve sin límites';

  @override
  String get paywallSubhead =>
      'Una sola compra. Tuya para siempre. Sin suscripción.';

  @override
  String get paywallNoAdsTitle => 'Sin anuncios, nunca';

  @override
  String get paywallNoAdsBody =>
      'Todos los banners y anuncios a pantalla completa, fuera';

  @override
  String get paywallHintsTitle => 'Pistas ilimitadas';

  @override
  String get paywallHintsBody => 'Revela una letra cuando te atasques';

  @override
  String get paywallPacksTitle => 'Paquetes extra exclusivos';

  @override
  String get paywallPacksBody =>
      'Un paquete exclusivo de Clásicos con voces eternas, y más en camino';

  @override
  String get paywallSupportTitle => 'Apoya el juego';

  @override
  String get paywallSupportBody =>
      'Una compra ayuda a que Quotecrack siga creciendo';

  @override
  String get paywallActive => 'Premium activo. ¡Disfruta!';

  @override
  String get paywallUnavailable =>
      'Las compras están disponibles en la app de Android.';

  @override
  String get paywallLoadingPrice => 'Cargando precio…';

  @override
  String paywallUnlock(String price) {
    return 'Desbloquear Premium · $price';
  }

  @override
  String get paywallRestore => 'Restaurar compra anterior';

  @override
  String get premiumUnlockedTitle => '¡Premium activado!';

  @override
  String get premiumUnlockedBody =>
      'Se acabaron los anuncios y las pistas son ilimitadas. ¡Gracias por apoyar a Quotecrack!';

  @override
  String get premiumContinue => 'Empezar a jugar';

  @override
  String get purchaseFailed =>
      'No se pudo completar la compra. Inténtalo de nuevo.';

  @override
  String get purchaseRestoring => 'Restaurando tu compra…';

  @override
  String get completeDailyTitle => '¡Diario resuelto!';

  @override
  String get completeTitle => '¡Resuelto!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
      zero: 'Sin pistas',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Logros desbloqueados',
      one: 'Logro desbloqueado',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Compartir resultado';

  @override
  String get nextPuzzle => 'Siguiente puzle';

  @override
  String get backToMenu => 'Volver al menú';

  @override
  String get reminderNudgeTitle => 'Protege tu racha';

  @override
  String get reminderNudgeBody =>
      'Un aviso suave al día para que el puzle de mañana no se te escape. Puedes cambiar la hora en Ajustes.';

  @override
  String get reminderNudgeNo => 'Ahora no';

  @override
  String get reminderNudgeDenied =>
      'Se denegó el permiso de notificaciones. Puedes activarlo cuando quieras en Ajustes.';

  @override
  String get packsSectionByDifficulty => 'Por dificultad';

  @override
  String get packsDifficultyHint =>
      'Contraintuitivo pero cierto: las frases más cortas son las más difíciles. Menos letras significan menos pistas con las que trabajar.';

  @override
  String get packsSectionThemed => 'Temáticos';

  @override
  String get statsFirstRun =>
      'Resuelve el cifrado de hoy para empezar tus estadísticas y tu racha.';

  @override
  String get statPuzzlesSolved => 'Puzles resueltos';

  @override
  String get statCurrentStreak => 'Racha actual';

  @override
  String get statBestStreak => 'Mejor racha';

  @override
  String get statFastestSolve => 'Resolución más rápida';

  @override
  String get statNoHintSolves => 'Sin pistas';

  @override
  String get statDailiesSolved => 'Diarios resueltos';

  @override
  String get statsDailyActivity => 'Actividad diaria';

  @override
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Últimas $weeks semanas · $start a $end';
  }

  @override
  String get puzzleAlreadySolved => 'Ya descifraste este.';

  @override
  String get showSolution => 'Mostrar solución';

  @override
  String get backToPuzzle => 'Volver a mi intento';

  @override
  String get actionPrev => 'Letra anterior';

  @override
  String get actionNext => 'Letra siguiente';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionRedo => 'Rehacer';

  @override
  String get dailyPuzzleTitle => 'Criptograma diario';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Logros ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Cada letra está sustituida';

  @override
  String get onbStep1Body =>
      'En un criptograma, cada letra del alfabeto representa a otra distinta. La E puede ser K, la T puede ser A, pero la sustitución es coherente en todo el texto.';

  @override
  String get onbStep2Title => 'Descífralo con patrones';

  @override
  String get onbStep2Body =>
      'Las palabras cortas son apoyos: las letras más frecuentes son E y A, y artículos como EL o LA aparecen por todas partes. La frecuencia de letras es tu aliada.';

  @override
  String get onbStep3Title => 'Toca y escribe';

  @override
  String get onbStep3Body =>
      'Toca cualquier casilla para seleccionar esa letra cifrada y luego elige su letra real en el teclado. Las letras idénticas se rellenan juntas.';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get onbTryOne => 'Prueba uno (30 segundos)';

  @override
  String get onbSkip => 'Omitir';

  @override
  String get notificationDailyTitle => 'Tu criptograma diario está listo';

  @override
  String get notificationDailyBody =>
      'Una nueva frase espera a ser descifrada. ¡Mantén viva tu racha!';

  @override
  String shareSolvedIn(String time) {
    return 'resuelto en $time';
  }

  @override
  String get packTitleBeginner => 'Principiante';

  @override
  String get packTaglineBeginner => 'Frases largas, cifrados suaves';

  @override
  String get packTitleCasual => 'Relajado';

  @override
  String get packTaglineCasual => 'Un reto cómodo';

  @override
  String get packTitleSkilled => 'Hábil';

  @override
  String get packTaglineSkilled => 'Para descifradores con práctica';

  @override
  String get packTitleExpert => 'Experto';

  @override
  String get packTaglineExpert => 'Corto, agudo, implacable';

  @override
  String get packTitleShortSweet => 'Cortas y al grano';

  @override
  String get packTaglineShortSweet => 'Frases breves para una victoria rápida';

  @override
  String get packTitleProverbs => 'Refranes';

  @override
  String get packTaglineProverbs => 'Sabiduría popular del mundo';

  @override
  String get packTitleWisdom => 'Sabiduría';

  @override
  String get packTaglineWisdom => 'Pensadores y estadistas';

  @override
  String get packTitleLiterature => 'Literatura';

  @override
  String get packTaglineLiterature => 'Versos de grandes libros';

  @override
  String get packTitleWit => 'Ingenio';

  @override
  String get packTaglineWit => 'Lenguas afiladas y ocurrencias';

  @override
  String get packTitleClassics => 'Clásicos';

  @override
  String get packTaglineClassics => 'Voces eternas, elegidas a mano';

  @override
  String get packTitleInspire => 'Corazón y Coraje';

  @override
  String get packTaglineInspire => 'Refranes de amor, amistad y constancia';

  @override
  String get achDescFirst => 'Resuelve tu primer criptograma';

  @override
  String achDescSolve(int count) {
    return 'Resuelve $count puzles';
  }

  @override
  String achDescStreak(int count) {
    return 'Alcanza una racha de $count días';
  }

  @override
  String achDescNoHints(int count) {
    return 'Resuelve $count puzles sin pistas';
  }

  @override
  String achDescSpeed(int count) {
    return 'Resuelve un puzle en menos de $count segundos';
  }

  @override
  String achDescDaily(int count) {
    return 'Resuelve $count puzles diarios';
  }

  @override
  String get achTitleFirstSolve => 'Primer Golpe';

  @override
  String get achTitleSolve10 => 'Descifrador Aprendiz';

  @override
  String get achTitleSolve25 => 'Rompecódigos';

  @override
  String get achTitleSolve50 => 'Sabueso de Cifrados';

  @override
  String get achTitleSolve100 => 'Centurión';

  @override
  String get achTitleSolve250 => 'Criptólogo Maestro';

  @override
  String get achTitleSolve500 => 'Gran Maestro';

  @override
  String get achTitleStreak3 => 'Calentando';

  @override
  String get achTitleStreak7 => 'Una Semana Completa';

  @override
  String get achTitleStreak14 => 'Quince Días de Foco';

  @override
  String get achTitleStreak30 => 'Devoción Mensual';

  @override
  String get achTitleStreak100 => 'Irrompible';

  @override
  String get achTitleStreak365 => 'Descifrador de Todo el Año';

  @override
  String get achTitleNoHints10 => 'Purista';

  @override
  String get achTitleNoHints25 => 'Autosuficiente';

  @override
  String get achTitleNoHints50 => 'Voluntad de Hierro';

  @override
  String get achTitleNoHints100 => 'Mente sin Ayuda';

  @override
  String get achTitleSpeed30 => 'En un Parpadeo';

  @override
  String get achTitleSpeed60 => 'Veloz como el Rayo';

  @override
  String get achTitleSpeed120 => 'Pensador Rápido';

  @override
  String get achTitleDaily10 => 'Ritual Diario';

  @override
  String get achTitleDaily25 => 'Solucionador Fiel';

  @override
  String get achTitleDaily50 => 'Café de la Mañana';

  @override
  String get achTitleDaily100 => 'Cien Mañanas';

  @override
  String get hintRevealLetter => 'Revelar letra';

  @override
  String hintRevealLetterCount(int count) {
    return 'Revelar letra ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count pistas añadidas';
  }

  @override
  String get adNoVideo =>
      'No hay ningún vídeo disponible ahora. Inténtalo de nuevo en un momento.';

  @override
  String get badgeNew => 'NUEVO';
}
