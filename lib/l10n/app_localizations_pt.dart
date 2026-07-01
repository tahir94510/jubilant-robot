// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutThisQuote => 'Sobre esta citação';

  @override
  String a11yLetterCellEmpty(String letter) {
    return 'Letra $letter, vazia';
  }

  @override
  String a11yLetterCellFilled(String letter, String guess) {
    return 'Letra $letter, resposta $guess';
  }

  @override
  String get a11yDismiss => 'Fechar';

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
  String get vibrationStrength => 'Intensidade da vibração';

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
  String get reminderSendTest => 'Enviar uma notificação de teste';

  @override
  String get reminderTestSent => 'Notificação de teste enviada';

  @override
  String get reminderBatteryHint =>
      'Alguns telefones (ex.: Xiaomi, Huawei) param os lembretes em segundo plano para poupar bateria. Permite que o Quotecrack seja executado em segundo plano para nunca perderes o teu lembrete diário.';

  @override
  String get reminderBatteryAction => 'Definições de bateria';

  @override
  String get notificationsBlockedTitle => 'As notificações estão desativadas';

  @override
  String get notificationsBlockedBody =>
      'O Quotecrack não pode mostrar notificações até você ativá-las nas configurações do sistema.';

  @override
  String get openSettings => 'Abrir configurações';

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
  String get startupErrorTitle => 'O Quotecrack não conseguiu iniciar';

  @override
  String get startupErrorBody =>
      'Feche o aplicativo completamente e abra-o novamente. Se o problema continuar, reinstalar irá resolvê-lo.';

  @override
  String get homeDailyLabel => 'DESAFIO DIÁRIO';

  @override
  String get homeDailySolved => 'Resolvido! Volte amanhã para um novo.';

  @override
  String homeDailyAwaits(String author) {
    return 'Um texto cifrado de $author espera por você.';
  }

  @override
  String get pressBackAgainToExit => 'Pressione voltar novamente para sair';

  @override
  String get homeContinueLabel => 'CONTINUAR';

  @override
  String get homeContinueSubtitle => 'Continue de onde parou';

  @override
  String get continuePlaying => 'Continuar';

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
      'Um pacote exclusivo de Clássicos com vozes atemporais, e mais a caminho';

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
  String get premiumUnlockedTitle => 'Premium desbloqueado!';

  @override
  String get premiumUnlockedBody =>
      'Os anúncios acabaram e as dicas são ilimitadas. Obrigado por apoiar o Quotecrack!';

  @override
  String get premiumContinue => 'Começar a jogar';

  @override
  String get purchaseFailed =>
      'Não foi possível concluir a compra. Tente novamente.';

  @override
  String get purchaseRestoring => 'Restaurando a sua compra…';

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
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Últimas $weeks semanas · $start a $end';
  }

  @override
  String get puzzleAlreadySolved => 'Você já decifrou este.';

  @override
  String get showSolution => 'Mostrar solução';

  @override
  String get backToPuzzle => 'Voltar à minha tentativa';

  @override
  String get actionPrev => 'Letra anterior';

  @override
  String get actionNext => 'Próxima letra';

  @override
  String get actionUndo => 'Desfazer';

  @override
  String get actionRedo => 'Refazer';

  @override
  String get dailyPuzzleTitle => 'Criptograma diário';

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

  @override
  String get onbDone => 'Concluído';

  @override
  String get replayTutorial => 'Repetir tutorial';

  @override
  String get notificationDailyTitle => 'Seu criptograma diário está pronto';

  @override
  String get notificationDailyBody =>
      'Uma nova frase espera para ser decifrada. Mantenha sua sequência viva!';

  @override
  String shareSolvedIn(String time) {
    return 'resolvido em $time';
  }

  @override
  String get packTitleBeginner => 'Iniciante';

  @override
  String get packTaglineBeginner => 'Frases longas, cifras suaves';

  @override
  String get packTitleCasual => 'Tranquilo';

  @override
  String get packTaglineCasual => 'Um desafio confortável';

  @override
  String get packTitleSkilled => 'Habilidoso';

  @override
  String get packTaglineSkilled => 'Para decifradores experientes';

  @override
  String get packTitleExpert => 'Especialista';

  @override
  String get packTaglineExpert => 'Curto, afiado, implacável';

  @override
  String get packTitleShortSweet => 'Curtas e Diretas';

  @override
  String get packTaglineShortSweet => 'Frases curtas para uma vitória rápida';

  @override
  String get packTitleProverbs => 'Provérbios';

  @override
  String get packTaglineProverbs => 'A sabedoria popular do mundo';

  @override
  String get packTitleWisdom => 'Sabedoria';

  @override
  String get packTaglineWisdom => 'Pensadores e estadistas';

  @override
  String get packTitleLiterature => 'Literatura';

  @override
  String get packTaglineLiterature => 'Versos de grandes livros';

  @override
  String get packTitleWit => 'Humor';

  @override
  String get packTaglineWit => 'Línguas afiadas e tiradas espirituosas';

  @override
  String get packTitleClassics => 'Clássicos';

  @override
  String get packTaglineClassics => 'Vozes atemporais, selecionadas a dedo';

  @override
  String get packTitleInspire => 'Coração e Coragem';

  @override
  String get packTaglineInspire => 'Provérbios de amor, amizade e perseverança';

  @override
  String get achDescFirst => 'Resolva seu primeiro criptograma';

  @override
  String achDescSolve(int count) {
    return 'Resolva $count desafios';
  }

  @override
  String achDescStreak(int count) {
    return 'Alcance uma sequência de $count dias';
  }

  @override
  String achDescNoHints(int count) {
    return 'Resolva $count desafios sem dicas';
  }

  @override
  String achDescSpeed(int count) {
    return 'Resolva um desafio em menos de $count segundos';
  }

  @override
  String achDescDaily(int count) {
    return 'Resolva $count desafios diários';
  }

  @override
  String get achTitleFirstSolve => 'Primeira Quebra';

  @override
  String get achTitleSolve10 => 'Decifrador Aprendiz';

  @override
  String get achTitleSolve25 => 'Quebrador de Códigos';

  @override
  String get achTitleSolve50 => 'Sabujo das Cifras';

  @override
  String get achTitleSolve100 => 'Centurião';

  @override
  String get achTitleSolve250 => 'Mestre Criptólogo';

  @override
  String get achTitleSolve500 => 'Grão-Mestre';

  @override
  String get achTitleStreak3 => 'Aquecendo';

  @override
  String get achTitleStreak7 => 'Uma Semana Inteira';

  @override
  String get achTitleStreak14 => 'Quinzena de Foco';

  @override
  String get achTitleStreak30 => 'Devoção Mensal';

  @override
  String get achTitleStreak100 => 'Inquebrável';

  @override
  String get achTitleStreak365 => 'Decifrador do Ano Todo';

  @override
  String get achTitleNoHints10 => 'Purista';

  @override
  String get achTitleNoHints25 => 'Autossuficiente';

  @override
  String get achTitleNoHints50 => 'Vontade de Ferro';

  @override
  String get achTitleNoHints100 => 'Mente sem Ajuda';

  @override
  String get achTitleSpeed30 => 'Num Piscar de Olhos';

  @override
  String get achTitleSpeed60 => 'Rápido como um Raio';

  @override
  String get achTitleSpeed120 => 'Pensador Ágil';

  @override
  String get achTitleDaily10 => 'Ritual Diário';

  @override
  String get achTitleDaily25 => 'Solucionador Fiel';

  @override
  String get achTitleDaily50 => 'Café da Manhã';

  @override
  String get achTitleDaily100 => 'Cem Manhãs';

  @override
  String get hintRevealLetter => 'Revelar letra';

  @override
  String hintRevealLetterCount(int count) {
    return 'Revelar letra ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count dicas adicionadas';
  }

  @override
  String get adNoVideo =>
      'Nenhum vídeo disponível agora. Tente novamente em instantes.';

  @override
  String get badgeNew => 'NOVO';
}
