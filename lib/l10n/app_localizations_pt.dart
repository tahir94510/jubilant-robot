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

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Resolva sem limites';

  @override
  String get paywallSubhead =>
      'Uma única compra. Sua para sempre. Sem assinatura.';

  @override
  String get paywallNoAdsTitle => 'Sem anúncios, nunca';

  @override
  String get paywallNoAdsBody =>
      'Todos os banners e anúncios em tela cheia, eliminados';

  @override
  String get paywallHintsTitle => 'Dicas ilimitadas';

  @override
  String get paywallHintsBody => 'Revele uma letra sempre que travar';

  @override
  String get paywallPacksTitle => 'Pacotes bônus exclusivos';

  @override
  String get paywallPacksBody =>
      'Shakespeare, sabedoria estoica e mais a caminho';

  @override
  String get paywallSupportTitle => 'Apoie o jogo';

  @override
  String get paywallSupportBody =>
      'Uma compra ajuda o Quotecrack a continuar crescendo';

  @override
  String get paywallActive => 'Premium ativo. Aproveite!';

  @override
  String get paywallUnavailable =>
      'As compras estão disponíveis no app Android.';

  @override
  String get paywallLoadingPrice => 'Carregando preço…';

  @override
  String paywallUnlock(String price) {
    return 'Desbloquear Premium · $price';
  }

  @override
  String get paywallRestore => 'Restaurar compra anterior';

  @override
  String get completeDailyTitle => 'Desafio diário resolvido!';

  @override
  String get completeTitle => 'Resolvido!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dicas',
      one: '1 dica',
      zero: 'Sem dicas',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conquistas desbloqueadas',
      one: 'Conquista desbloqueada',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Compartilhar resultado';

  @override
  String get nextPuzzle => 'Próximo desafio';

  @override
  String get backToMenu => 'Voltar ao menu';

  @override
  String get reminderNudgeTitle => 'Proteja sua sequência';

  @override
  String get reminderNudgeBody =>
      'Um lembrete gentil por dia, para o desafio de amanhã nunca passar batido. Você pode mudar o horário nas Configurações.';

  @override
  String get reminderNudgeNo => 'Agora não';

  @override
  String get reminderNudgeDenied =>
      'A permissão de notificações foi negada. Você pode ativá-la quando quiser nas Configurações.';

  @override
  String get packsSectionByDifficulty => 'Por dificuldade';

  @override
  String get packsDifficultyHint =>
      'Contraintuitivo, mas verdadeiro: as frases mais curtas são as mais difíceis. Menos letras significam menos pistas para trabalhar.';

  @override
  String get packsSectionThemed => 'Temáticos';

  @override
  String get statsFirstRun =>
      'Resolva o cifrado de hoje para iniciar suas estatísticas e sua sequência.';

  @override
  String get statPuzzlesSolved => 'Desafios resolvidos';

  @override
  String get statCurrentStreak => 'Sequência atual';

  @override
  String get statBestStreak => 'Melhor sequência';

  @override
  String get statFastestSolve => 'Resolução mais rápida';

  @override
  String get statNoHintSolves => 'Sem dicas';

  @override
  String get statDailiesSolved => 'Diários resolvidos';

  @override
  String get statsDailyActivity => 'Atividade diária';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Conquistas ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Cada letra é trocada';

  @override
  String get onbStep1Body =>
      'Num criptograma, cada letra do alfabeto representa outra. O E pode ser K, o T pode ser A, mas a troca é consistente em todo o texto.';

  @override
  String get onbStep2Title => 'Decifre com padrões';

  @override
  String get onbStep2Body =>
      'Palavras curtas são apoios: as letras mais frequentes são A e E, e palavras como O, A, E aparecem por toda parte. A frequência das letras é sua aliada.';

  @override
  String get onbStep3Title => 'Toque e digite';

  @override
  String get onbStep3Body =>
      'Toque em qualquer célula para selecionar aquela letra cifrada e escolha a letra real no teclado. Letras iguais se preenchem juntas.';

  @override
  String get onbNext => 'Avançar';

  @override
  String get onbTryOne => 'Experimente um (30 segundos)';

  @override
  String get onbSkip => 'Pular';
}
