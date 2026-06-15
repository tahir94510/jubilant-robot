// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get sectionGameplay => 'Jogo';

  @override
  String get sectionDailyReminder => 'Lembrete diário';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Privacidade e sobre';

  @override
  String get appLanguage => 'Idioma do app';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get theme => 'Tema';

  @override
  String get themeAutoSubtitle => 'Automático (segue seu aparelho)';

  @override
  String get themeAuto => 'Automático';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSepia => 'Sépia';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get colorblindTitle => 'Cores para daltônicos';

  @override
  String get colorblindSubtitle => 'Destaques azul/laranja em vez de vermelho';

  @override
  String get errorCheckingTitle => 'Verificação de erros';

  @override
  String get errorCheckingSubtitle =>
      'Marcar letras erradas quando o tabuleiro estiver cheio';

  @override
  String get showTimerTitle => 'Mostrar cronômetro';

  @override
  String get showTimerSubtitle =>
      'Desative para uma experiência totalmente zen';

  @override
  String get hapticsTitle => 'Resposta tátil';

  @override
  String get soundEffectsTitle => 'Efeitos sonoros';

  @override
  String get soundEffectsSubtitle => 'Toques de tecla suaves e sons delicados';

  @override
  String get effectsVolume => 'Volume dos efeitos';

  @override
  String get musicTitle => 'Música';

  @override
  String get musicSubtitle => 'Música ambiente calma enquanto você joga';

  @override
  String get musicVolume => 'Volume da música';

  @override
  String get remindMeDaily => 'Lembrar todos os dias';

  @override
  String reminderAt(String time) {
    return 'Às $time';
  }

  @override
  String get neverMissStreak => 'Nunca perca sua sequência';

  @override
  String get reminderTime => 'Horário do lembrete';

  @override
  String get reminderDenied =>
      'A permissão de notificações foi negada nas configurações do sistema.';

  @override
  String get premiumActive => 'Premium ativo';

  @override
  String get premiumActiveSubtitle => 'Obrigado por apoiar o Quotecrack!';

  @override
  String get goPremium => 'Seja Premium';

  @override
  String get goPremiumSubtitle =>
      'Sem anúncios, dicas ilimitadas, pacotes bônus';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get checkingPurchases => 'Verificando compras anteriores…';

  @override
  String get privacyOptions => 'Opções de privacidade';

  @override
  String get privacyOptionsSubtitle =>
      'Gerencie suas escolhas de consentimento de anúncios';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get openSourceLicenses => 'Licenças de código aberto';

  @override
  String get version => 'Versão';

  @override
  String get homeDailyLabel => 'DESAFIO DIÁRIO';

  @override
  String get homeDailySolved => 'Resolvido! Volte amanhã para um novo.';

  @override
  String homeDailyAwaits(String author) {
    return 'Um texto cifrado de $author espera por você.';
  }

  @override
  String get playNow => 'Jogar agora';

  @override
  String get replay => 'Jogar de novo';

  @override
  String get puzzlePacks => 'Pacotes de desafios';

  @override
  String packsSolved(int solved, int total) {
    return '$solved de $total resolvidos';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get statisticsSubtitle => 'Sequências, tempos e seu mapa de atividade';

  @override
  String get achievements => 'Conquistas';

  @override
  String achievementsUnlocked(int count) {
    return '$count desbloqueadas';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Sem anúncios · dicas ilimitadas · pacotes bônus';

  @override
  String get musicToggleTooltip => 'Música lig/desl';

  @override
  String get settingsTooltip => 'Configurações';
}
