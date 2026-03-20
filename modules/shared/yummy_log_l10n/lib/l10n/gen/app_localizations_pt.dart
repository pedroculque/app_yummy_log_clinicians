// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get diaryTitle => 'Diário';

  @override
  String get greeting => 'Olá';

  @override
  String get diaryEmptyTitle => 'Seu diário alimentar';

  @override
  String get diaryEmptySubtitle => 'Nenhuma refeição anotada hoje.';

  @override
  String get today => 'Hoje';

  @override
  String get noMealsThisDay => 'Nenhuma refeição neste dia';

  @override
  String get addMeal => 'Adicionar refeição';

  @override
  String get editMeal => 'Editar refeição';

  @override
  String get sectionMealTime => 'Horário da refeição';

  @override
  String get sectionWhichMeal => 'Qual refeição?';

  @override
  String get mealTypeBreakfast => 'Café da manhã';

  @override
  String get mealTypeLunch => 'Almoço';

  @override
  String get mealTypeDinner => 'Jantar';

  @override
  String get mealTypeSupper => 'Ceia';

  @override
  String get mealTypeMorningSnack => 'Lanche da manhã';

  @override
  String get mealTypeAfternoonSnack => 'Lanche da tarde';

  @override
  String get mealTypeEveningSnack => 'Lanche da noite';

  @override
  String get sectionWhereAte => 'Onde você comeu?';

  @override
  String get whereAteHome => 'Casa';

  @override
  String get whereAteWork => 'Trabalho';

  @override
  String get whereAteRestaurant => 'Restaurante';

  @override
  String get whereAteOther => 'Outro';

  @override
  String get sectionAteWithOthers => 'Comeu acompanhado?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get sectionHowMuch => 'Quanto você comeu?';

  @override
  String get amountNothing => 'Nada';

  @override
  String get amountLittle => 'Um pouco';

  @override
  String get amountHalf => 'Metade';

  @override
  String get amountMost => 'A maior parte';

  @override
  String get amountAll => 'Tudo';

  @override
  String get sectionHowFelt => 'Como você se sentiu?';

  @override
  String get feelingSad => 'Triste';

  @override
  String get feelingNothing => 'Nada';

  @override
  String get feelingHappy => 'Alegre';

  @override
  String get feelingProud => 'Orgulho';

  @override
  String get feelingAngry => 'Raivoso';

  @override
  String get sectionFeelingText => 'Fale sobre o que sentiu';

  @override
  String get feelingTextHint => 'Escreva sobre o sentimento durante e/ou após a refeição. Ex. Enjoo depois da refeição...';

  @override
  String get buttonAddMeal => 'ADICIONAR REFEIÇÃO';

  @override
  String get buttonSaveChanges => 'SALVAR ALTERAÇÕES';

  @override
  String get saving => 'Salvando...';

  @override
  String get detailTitle => 'Detalhe';

  @override
  String get whatDoYouWantToDo => 'O que deseja fazer?';

  @override
  String get actionEdit => 'EDITAR';

  @override
  String get actionDelete => 'APAGAR';

  @override
  String get confirmDeleteEntry => 'Deseja mesmo apagar?';

  @override
  String get entryNotFound => 'Registro não encontrado';

  @override
  String get back => 'Voltar';

  @override
  String get labelDate => 'Data';

  @override
  String get labelTime => 'Horário';

  @override
  String get labelMeal => 'Refeição';

  @override
  String get labelFeeling => 'Sentimento';

  @override
  String get labelAboutFeeling => 'Sobre o sentimento';

  @override
  String get labelWhereAte => 'Onde comeu';

  @override
  String get labelAteWithOthers => 'Comeu acompanhado';

  @override
  String get labelHowMuch => 'Quanto comeu';

  @override
  String characterCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get sectionMealPhoto => 'Foto da refeição';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get profilePhotoSheetTitle => 'Foto do perfil';

  @override
  String get profilePhotoUpdated => 'Foto de perfil atualizada.';

  @override
  String get profilePhotoNeedSignIn => 'Faça login novamente para atualizar a foto.';

  @override
  String get profilePhotoWrongAccount => 'Conta diferente da logada.';

  @override
  String get profilePhotoTokenFailed => 'Erro de autenticação. Tente fazer login novamente.';

  @override
  String get profilePhotoUploadFailed => 'Falha ao enviar a foto.';

  @override
  String get skipPhoto => 'Só anotar';

  @override
  String get changePhoto => 'Trocar foto';

  @override
  String get sendPhoto => 'Adicionar foto';

  @override
  String get sendPhotoHint => 'Toque para fotografar ou escolher da galeria';

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get sectionDescribeWhatAte => 'Descreva o que comeu';

  @override
  String get describeWhatAteHint => 'Escreva sobre detalhes sobre o seu prato';

  @override
  String get questionHiddenFood => 'Você escondeu sua comida?';

  @override
  String get questionRegurgitated => 'Você regurgitou?';

  @override
  String get questionForcedVomit => 'Forçou a vomitar?';

  @override
  String get questionAteInSecret => 'Comeu em segredo?';

  @override
  String get questionUsedLaxatives => 'Você usou laxantes desde seu último registro?';

  @override
  String get questionDiuretics => 'Você usou diuréticos desde seu último registro?';

  @override
  String get viewDayList => 'Ver lista do dia';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle => 'Preferências do aplicativo';

  @override
  String get sectionAccount => 'Conta';

  @override
  String get accountSignInIntro => 'Entre na sua conta para sincronizar e conectar com seu nutricionista.';

  @override
  String get accountProHint => 'Login e sincronização disponíveis no plano Clínicos.';

  @override
  String get viewPlans => 'Ver planos';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEn => 'English (US)';

  @override
  String get languageEs => 'Español';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String get sectionAbout => 'Sobre';

  @override
  String get versionLabel => 'Versão';

  @override
  String get standardsLabel => 'Padrões';

  @override
  String get ageRangeLabel => 'Faixa etária';

  @override
  String get ageRangeValue => '0 - 19 anos';

  @override
  String get curveSourcesLabel => 'Fontes das curvas e classificações';

  @override
  String get curveSourcesValue => 'OMS (WHO)';

  @override
  String get requestAccountDeletion => 'Solicitar exclusão de conta e dados';

  @override
  String get privacyPolicyLink => 'Link para a política de privacidade';

  @override
  String get sectionSupport => 'Suporte';

  @override
  String get supportIdLabel => 'ID de Suporte';

  @override
  String get supportIdHint => 'Use este código ao entrar em contato';

  @override
  String get copySupportId => 'Copiar';

  @override
  String get rateApp => 'Avaliar o app';

  @override
  String get rateAppSubtitle => 'Sua opinião nos ajuda a melhorar';

  @override
  String get loginWithGoogle => 'Entrar com Google';

  @override
  String get loginWithApple => 'Entrar com Apple';

  @override
  String get logout => 'Sair';

  @override
  String loggedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get connectNutritionist => 'Conectar com nutricionista';

  @override
  String get connectNutritionistHint => 'Vincule-se ao seu nutricionista para ele acompanhar seu diário. Requer login.';

  @override
  String get displayNameLabel => 'Nome';

  @override
  String get setDisplayName => 'Definir nome';

  @override
  String get displayNameHint => 'Como quer ser chamado na saudação';

  @override
  String get save => 'Salvar';

  @override
  String get conectarTitle => 'Conectar';

  @override
  String get nutritionistCode => 'Código do nutricionista';

  @override
  String get nutritionistCodeHint => 'Digite o código fornecido pelo seu nutricionista';

  @override
  String get buttonConnect => 'Conectar';

  @override
  String get connectSuccess => 'Clínico adicionado com sucesso!';

  @override
  String get connectLoginRequired => 'Faça login em Configurações para conectar-se a um nutricionista.';

  @override
  String get goToSettings => 'Ir para Configurações';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get professionNutricionista => 'Nutricionista';

  @override
  String get clinicianCodeLabel => 'Digite o código do clínico';

  @override
  String get clinicianCodeHelper => '6 caracteres: letras e números (ex.: ABC123)';

  @override
  String get clinicianCodeInvalidLength => 'O código deve ter exatamente 6 caracteres (letras e números).';

  @override
  String get buttonSend => 'Enviar';

  @override
  String get removeClinician => 'Excluir clínico';

  @override
  String get confirmRemoveClinician => 'Deseja mesmo excluir?';

  @override
  String connectedSince(String date) {
    return 'desde $date';
  }

  @override
  String get myProfessionals => 'Meus Profissionais';

  @override
  String get headerSubtitle => 'Compartilhe seu diário com sua equipe de saúde';

  @override
  String get emptyStateTitle => 'Você ainda não está conectado';

  @override
  String get emptyStateSubtitle => 'Peça o código ao seu profissional de saúde para compartilhar seu diário alimentar';

  @override
  String get addProfessional => 'Adicionar profissional';

  @override
  String get healthProfessionalCode => 'Código do profissional';

  @override
  String get healthProfessionalCodeHint => 'Digite o código de 6 dígitos';

  @override
  String get professionHealthProfessional => 'Profissional de Saúde';

  @override
  String get connectHealthProfessional => 'Conecte-se com profissionais de saúde';

  @override
  String get yesterday => 'Ontem';

  @override
  String get mealSingular => 'refeição';

  @override
  String get mealPlural => 'refeições';

  @override
  String get validationPhotoRequired => 'Adicione uma foto da refeição.';

  @override
  String get validationMealTypeRequired => 'Selecione o tipo de refeição.';

  @override
  String get validationWhereAteRequired => 'Selecione onde você comeu.';

  @override
  String get validationAteWithOthersRequired => 'Informe se comeu acompanhado.';

  @override
  String get navPatients => 'Pacientes';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Configurações';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsComingSoonSubtitle => 'Em breve você poderá visualizar métricas e dados dos seus pacientes aqui.';

  @override
  String get plansUnlockPro => 'Desbloqueie o YummyLog Clínicos';

  @override
  String get plansUnlockSubtitle => 'Aproveite todos os recursos sem limites';

  @override
  String get plansComingSoon => 'Em breve';

  @override
  String get plansComingSoonMessage => 'A assinatura YummyLog Clínicos estará disponível em breve. Fique ligado nas atualizações!';

  @override
  String get plansGotIt => 'Entendi';

  @override
  String get plansFeatureUnlimitedPatients => 'Pacientes ilimitados';

  @override
  String get plansFeatureFullHistory => 'Histórico completo';

  @override
  String get plansFeatureExportReports => 'Exportar relatórios';

  @override
  String get plansFeaturePrioritySupport => 'Suporte prioritário';

  @override
  String get plansFeatureMealPushNotifications => 'Notificações push das refeições';

  @override
  String get plansAnnual => 'Anual';

  @override
  String get plansSave40 => 'Economize 40%';

  @override
  String get plansMonthly => 'Mensal';

  @override
  String get plansMostPopular => 'MAIS POPULAR';

  @override
  String get plansPriceAnnual => 'R\$ 179,90';

  @override
  String get plansPriceMonthly => 'R\$ 24,90';

  @override
  String get plansPeriodYear => '/ano';

  @override
  String get plansPeriodMonth => '/mês';

  @override
  String get plansSubscribeAnnual => 'Assinar Anual';

  @override
  String get plansSubscribeMonthly => 'Assinar Mensal';

  @override
  String get plansTrialAnnual => '7 dias grátis, depois R\$ 179,90/ano';

  @override
  String get plansTrialMonthly => '7 dias grátis, depois R\$ 24,90/mês';

  @override
  String get plansCancelAnytime => 'Cancele quando quiser';

  @override
  String get errorNotLoggedIn => 'Não conectado';

  @override
  String get patientsLoadError => 'Erro ao carregar pacientes';

  @override
  String get removePatientTitle => 'Remover paciente?';

  @override
  String removePatientMessage(String name) {
    return 'Você deixará de acompanhar o diário de $name. O paciente pode se reconectar usando um novo código.';
  }

  @override
  String get removePatientButton => 'REMOVER';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String patientRemoved(String name) {
    return '$name foi removido';
  }

  @override
  String get loginRequiredTitle => 'Login necessário';

  @override
  String get loginRequiredMessage => 'Para convidar pacientes, você precisa fazer login primeiro.';

  @override
  String get limitReachedTitle => 'Limite atingido';

  @override
  String get limitReachedMessage => 'Você atingiu o limite de 2 pacientes do plano gratuito. Faça upgrade para o YummyLog Clínicos e tenha pacientes ilimitados!';

  @override
  String get viewPlansButton => 'Ver Planos';

  @override
  String get notNow => 'Agora não';

  @override
  String get noPatientsConnected => 'Nenhum paciente conectado';

  @override
  String get onePatientConnected => '1 paciente conectado';

  @override
  String patientsConnectedCount(int count) {
    return '$count pacientes conectados';
  }

  @override
  String get patientsHeaderYummyLogHint => 'Via app YummyLog do paciente';

  @override
  String get inviteRequiresYummyLogApp => 'O paciente precisa do app YummyLog para aceitar o convite.';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get somethingWentWrong => 'Ops! Algo deu errado';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get startFollowingTitle => 'Comece a acompanhar';

  @override
  String get startFollowingSubtitleLoggedOut => 'Faça login e convide seus pacientes para acompanhar o diário alimentar deles em tempo real.';

  @override
  String get startFollowingSubtitleLoggedIn => 'Convide seus pacientes usando o botão abaixo e acompanhe a evolução alimentar deles.';

  @override
  String get featureViewMealsTitle => 'Visualize refeições';

  @override
  String get featureViewMealsSubtitle => 'Fotos e detalhes de cada refeição';

  @override
  String get featureFollowFeelingsTitle => 'Acompanhe sentimentos';

  @override
  String get featureFollowFeelingsSubtitle => 'Entenda a relação emocional com a comida';

  @override
  String get featureRealtimeTitle => 'Tempo real';

  @override
  String get featureRealtimeSubtitle => 'Dados sincronizados automaticamente';

  @override
  String get actionRemove => 'Remover';

  @override
  String linkedSinceDate(String date) {
    return 'Desde $date';
  }

  @override
  String get invitePatientButton => 'CONVIDAR PACIENTE';

  @override
  String get inviteCodeTitle => 'Código de convite';

  @override
  String get inviteCodeSubtitle => 'Compartilhe este código com seu paciente para que ele possa se conectar ao seu perfil.';

  @override
  String get codeCopied => 'Código copiado!';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareSms => 'SMS';

  @override
  String get shareEmail => 'E-mail';

  @override
  String shareInviteMessage(String code) {
    return 'Use o código $code para se conectar comigo no YummyLog!';
  }

  @override
  String get patientDefaultName => 'Paciente';

  @override
  String get diaryLoadError => 'Erro ao carregar dados';

  @override
  String get patientNoMealsThisDay => 'O paciente não registrou refeições neste dia.';

  @override
  String get rateAppStoreSoon => 'Avaliar na loja: em breve';

  @override
  String get sectionSubscription => 'Assinatura';

  @override
  String get sectionNotificationsPush => 'Alertas';

  @override
  String get notificationPushMasterTitle => 'Novas entradas no diário';

  @override
  String get notificationPushMasterSubtitle => 'Receba notificações quando seus pacientes registrarem refeições.';

  @override
  String get notificationPushCustomizeHint => 'Personalize o tipo de alerta abaixo';

  @override
  String get notificationPushAllEntries => 'Todas as novas entradas';

  @override
  String get notificationPushAllEntriesRowSubtitle => 'Cada refeição que o paciente registrar.';

  @override
  String get notificationPushCriticalOnly => 'Somente com comportamento de risco';

  @override
  String get notificationPushCriticalOnlyRowSubtitle => 'Vômito, laxantes, regurgitação, comer escondido, etc.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get restorePurchasesSoon => 'Restaurar compras: em breve';

  @override
  String get purchasesNotConfigured => 'Compras não estão configuradas neste build. Defina as chaves do RevenueCat.';

  @override
  String get purchaseSuccess => 'Assinatura ativada.';

  @override
  String get purchaseCancelled => 'Compra cancelada.';

  @override
  String get purchaseFailed => 'Não foi possível concluir a compra. Tente novamente.';

  @override
  String get purchaseOfferingsUnavailable => 'Planos indisponíveis no momento. Tente mais tarde.';

  @override
  String get purchasesRestoreSuccess => 'Assinatura restaurada com sucesso.';

  @override
  String get purchasesRestoreEmpty => 'Nenhuma assinatura encontrada para esta conta.';

  @override
  String get purchasesRestoreFailed => 'Não foi possível restaurar as compras.';

  @override
  String get planPro => 'Plano Clínicos';

  @override
  String get planFree => 'Plano Gratuito';

  @override
  String get loading => 'Carregando...';

  @override
  String get unlimitedPatients => 'Pacientes ilimitados';

  @override
  String patientsCountOfMax(int current, int max) {
    return '$current de $max pacientes';
  }

  @override
  String get upgradeToPro => 'Fazer upgrade para Clínicos';

  @override
  String get insightsDashboard => 'Dashboard';

  @override
  String get insightsActivePatients => 'Pacientes ativos';

  @override
  String get insightsActivePatientsSubtitle => 'com registros nos últimos 7 dias';

  @override
  String get insightsMealsThisWeek => 'Registros esta semana';

  @override
  String get insightsMealsThisWeekSubtitle => 'refeições de todos pacientes';

  @override
  String get insightsAlerts => 'Alertas';

  @override
  String get insightsAlertsSubtitle => 'comportamentos de risco';

  @override
  String get insightsRecentAlerts => 'Alertas recentes';

  @override
  String get insightsNoAlerts => 'Nenhum alerta de risco nos últimos 7 dias';

  @override
  String get insightsNeedsAttention => 'Precisam de atenção';

  @override
  String get insightsNoAttentionNeeded => 'Todos os pacientes estão bem';

  @override
  String get insightsViewDiary => 'Ver diário';

  @override
  String get insightsEmptyTitle => 'Sem dados ainda';

  @override
  String get insightsEmptySubtitle => 'Convide pacientes e aguarde alguns dias de registros para ver insights aqui.';

  @override
  String get insightsNotLoggedIn => 'Faça login para ver insights dos seus pacientes.';

  @override
  String get insightsAlertForcedVomit => 'Vômito forçado';

  @override
  String get insightsAlertUsedLaxatives => 'Uso de laxantes';

  @override
  String get insightsAlertDiuretics => 'Uso de diurético';

  @override
  String get insightsAlertRegurgitated => 'Regurgitação';

  @override
  String get insightsAlertHiddenFood => 'Escondeu comida';

  @override
  String get insightsAlertAteInSecret => 'Comeu em segredo';

  @override
  String get insightsHighPriority => 'Alta prioridade';

  @override
  String get insightsMediumPriority => 'Média prioridade';

  @override
  String get insightsLowPriority => 'Monitorar';

  @override
  String insightsAttentionScore(int score) {
    return 'Score de atenção: $score';
  }

  @override
  String get insightsScoreLabel => 'Score de atenção';

  @override
  String get insightsScoreHelpTitle => 'O que é o Score de atenção?';

  @override
  String get insightsScoreHelpBody => 'É um indicador que ajuda a priorizar pacientes com mais sinais de atenção nos registros recentes.';

  @override
  String get insightsScoreHelpBullets1 => 'Baseado na frequência dos alertas';

  @override
  String get insightsScoreHelpBullets2 => 'Considera a recência dos eventos';

  @override
  String get insightsScoreHelpBullets3 => 'Não substitui avaliação clínica';

  @override
  String get insightsScoreHelpDisclaimer => 'Quanto maior o score, maior a necessidade de acompanhamento.';

  @override
  String get insightsScoreHelpButton => 'Entenda como funciona';

  @override
  String get insightsScoreHelpPageTitle => 'Como funciona o Score de atenção';

  @override
  String get insightsScoreHelpPageBody => 'O score resume sinais de atenção a partir dos registros mais recentes para facilitar a triagem. Ele combina a quantidade de alertas, o tipo de comportamento observado e o tempo desde o último evento.';

  @override
  String get insightsClinicalPriorityTitle => 'Prioridade clínica';

  @override
  String get insightsClinicalPrioritySubtitle => 'Resumo rápido para decidir onde olhar primeiro';

  @override
  String insightsPatientsNeedAttention(int count) {
    return '$count pacientes precisam de atenção';
  }

  @override
  String insightsHighPriorityAlertsCount(int count) {
    return '$count alertas de alta prioridade';
  }

  @override
  String insightsActiveRate(String percent) {
    return '$percent% de pacientes ativos';
  }

  @override
  String get insightsClinicalActionNeeded => 'Ação recomendada hoje';

  @override
  String get insightsClinicalPriorityWithAlerts => 'Há alertas críticos recentes. Revise primeiro os pacientes mais altos no ranking e os eventos com prioridade alta.';

  @override
  String get insightsClinicalPriorityNoAlerts => 'Nenhum alerta crítico recente. Use o ranking para revisar os pacientes com maior score e inatividade.';

  @override
  String get insightsPatientAnalyticsTitle => 'Análise por paciente';

  @override
  String get insightsPatientAnalyticsSubtitle => 'Topo dos casos que mais merecem leitura rápida';

  @override
  String get insightsPatientAnalyticsEmpty => 'Ainda não há pacientes suficientes para comparar análises individuais.';

  @override
  String insightsTrendComparison(int current, int previous, String trend) {
    return '$current refeições na última semana vs $previous na semana anterior, $trend';
  }

  @override
  String insightsAlertsTrendComparison(int current, int previous, String trend) {
    return '$current alertas na última semana vs $previous na semana anterior, $trend';
  }

  @override
  String insightsScoreValue(int score) {
    return 'Score $score';
  }

  @override
  String insightsMealsTrend(int current, int previous) {
    return '$current refeições na última semana vs $previous na semana anterior';
  }

  @override
  String insightsNegativeFeelings(String percent) {
    return '$percent% sentimentos negativos';
  }

  @override
  String insightsRestrictionRate(String percent) {
    return '$percent% baixa ingestão';
  }

  @override
  String get insightsHighPriorityAlerts => 'alertas críticos';

  @override
  String get insightsTrendStable => 'Estável';

  @override
  String get insightsTrendModerate => 'Atenção';

  @override
  String get insightsTrendLow => 'Baixa atividade';

  @override
  String get insightsTrendNoData => 'Sem histórico';

  @override
  String get insightsTrendUp => 'em alta';

  @override
  String get insightsTrendDown => 'em queda';

  @override
  String get insightsTrendFlat => 'estável';

  @override
  String get insightsActionReviewToday => 'Revisar hoje';

  @override
  String get insightsActionReviewSoon => 'Revisar em breve';

  @override
  String get insightsActionStable => 'Caso estável';

  @override
  String get insightsActionWorsening => 'Em piora';

  @override
  String get insightsActionImproving => 'Em melhora';

  @override
  String get insightsActionLabel => 'Ação';

  @override
  String insightsActionSummary(int today, int soon, int stable) {
    return '$today hoje, $soon em breve e $stable estáveis';
  }

  @override
  String get insightsClinicalSignalsTitle => 'Sinais clínicos';

  @override
  String get insightsClinicalSignalsSubtitle => 'Quem piorou, quem melhorou e quem precisa de atenção';

  @override
  String get insightsClinicalWhyHere => 'Por que este paciente está aqui';

  @override
  String get insightsClinicalWhyHereHighRisk => 'Há alerta crítico recente e o score está alto.';

  @override
  String get insightsClinicalWhyHereWorsening => 'O padrão piorou na última comparação temporal.';

  @override
  String get insightsClinicalWhyHereBalanced => 'Os sinais estão equilibrados, mas vale acompanhar a evolução.';

  @override
  String get insightsTrendMealsLabel => 'Adesão';

  @override
  String get insightsTrendAlertsLabel => 'Alertas';

  @override
  String get insightsTrendWorse => 'piorando';

  @override
  String get insightsTrendBetter => 'melhorando';

  @override
  String get insightsTrendSame => 'estável';

  @override
  String get insightsTrendActionWorse => 'Precisa de revisão mais cedo';

  @override
  String get insightsTrendActionBetter => 'Pode ficar para revisão posterior';

  @override
  String insightsPatientPriorityToday(int count) {
    return '$count para revisar hoje';
  }

  @override
  String insightsPatientPrioritySoon(int count) {
    return '$count para revisar em breve';
  }

  @override
  String insightsPatientPriorityStable(int count) {
    return '$count estáveis';
  }

  @override
  String insightsPatientPriorityWorsening(int count) {
    return '$count em piora';
  }

  @override
  String insightsPatientPriorityImproving(int count) {
    return '$count em melhora';
  }

  @override
  String get insightsDashboardOperationalTitle => 'Resumo operacional';

  @override
  String get insightsDashboardOperationalSubtitle => 'Estado dos casos para priorizar a agenda';

  @override
  String insightsPatientNarrativeInactive(int days) {
    return 'Paciente está há $days dias sem refeição registrada e precisa de revisão.';
  }

  @override
  String get insightsPatientNarrativeHighAlert => 'Há sinais críticos recentes. Vale revisar os eventos em detalhe primeiro.';

  @override
  String get insightsPatientNarrativeBalanced => 'Os sinais estão mais equilibrados, então este paciente pode ficar após os casos prioritários.';

  @override
  String get insightsPatientDetailTitle => 'Detalhe do paciente';

  @override
  String get insightsPatientDetailSubtitle => 'Resumo clínico rápido com sinais e tendência';

  @override
  String get insightsPatientDetailSignalsTitle => 'Sinais principais';

  @override
  String get insightsPatientDetailAlertCount => 'Alertas recentes';

  @override
  String get insightsPatientDetailInactive => 'Dias sem refeição';

  @override
  String get insightsPatientDetailNarrativeTitle => 'Leitura clínica';

  @override
  String get insightsPatientDetailRecentAlerts => 'Alertas recentes';

  @override
  String get insightsPatientDetailNoAlerts => 'Nenhum alerta recente neste período.';

  @override
  String get insightsPatientDetailNotFound => 'Não foi possível abrir este paciente.';

  @override
  String get insightsTrendLabel => 'Tendência';

  @override
  String insightsMealsCount(int count) {
    return '$count refeições (7d)';
  }

  @override
  String insightsAlertsCount(int count) {
    return '$count alertas';
  }

  @override
  String insightsInactive(int days) {
    return 'Inativo há $days dias';
  }

  @override
  String insightsLastMeal(String date) {
    return 'Última refeição: $date';
  }

  @override
  String get insightsNoMeals => 'Sem registros';

  @override
  String get insightsPeriod7Days => '7 dias';

  @override
  String get insightsPeriodPreviousWeek => 'Semana anterior';

  @override
  String get insightsPeriodThisWeek => 'Esta semana';

  @override
  String get insightsPeriod30Days => '30 dias';

  @override
  String get insightsPeriod90Days => '90 dias';

  @override
  String get insightsViewAnalytics => 'Ver análises';

  @override
  String get insightsAnalyticsMealsPerDay => 'média refeições/dia';

  @override
  String get insightsAnalyticsFeelingsTitle => 'Sentimentos';

  @override
  String get insightsAnalyticsFeelingsSubtitle => 'Distribuição de como o paciente se sentiu nas refeições';

  @override
  String get insightsAnalyticsAmountTitle => 'Quantidade consumida';

  @override
  String get insightsAnalyticsAmountSubtitle => 'Distribuição do quanto o paciente comeu';

  @override
  String get insightsAnalyticsFrequencyTitle => 'Frequência de registros';

  @override
  String get insightsAnalyticsFrequencySubtitle => 'Calendário de calor dos últimos dias';

  @override
  String get insightsAnalyticsEmpty => 'Sem registros no período selecionado';

  @override
  String get insightsAnalyticsHeatMapMin => 'Nenhum';

  @override
  String get insightsAnalyticsHeatMapMax => 'Muitos';

  @override
  String get insightsAnalyticsTrendTitle => 'Tendências agregadas';

  @override
  String get insightsAnalyticsTrendSubtitle => 'Comparativo: período atual vs anterior';

  @override
  String get insightsAnalyticsTrendCurrent => 'Atual';

  @override
  String get insightsAnalyticsTrendPrevious => 'Anterior';

  @override
  String insightsAnalyticsTrendDeltaUp(int delta) {
    return '+$delta';
  }

  @override
  String insightsAnalyticsTrendDeltaDown(int delta) {
    return '$delta';
  }

  @override
  String get insightsAnalyticsSkippedTitle => 'Refeições puladas';

  @override
  String get insightsAnalyticsSkippedSubtitle => 'Registros marcados como pulados ou sem consumo, por tipo';

  @override
  String get insightsAnalyticsSkippedFeelingTitle => 'Sentimentos em refeições puladas';

  @override
  String get insightsAnalyticsSkippedFeelingSubtitle => 'Como o paciente se sentiu quando pulou ou não comeu';

  @override
  String insightsUpdatedAt(String time) {
    return 'Atualizado às $time';
  }

  @override
  String get insightsMealsPeriod => 'Registros no período';

  @override
  String get mealDetailTitle => 'Detalhes da refeição';

  @override
  String get mealDetailWhere => 'Onde comeu';

  @override
  String get mealDetailWithOthers => 'Comeu acompanhado';

  @override
  String get mealDetailAmount => 'Quantidade';

  @override
  String get mealDetailFeeling => 'Sentimento';

  @override
  String get mealDetailDescription => 'Descrição';

  @override
  String get mealDetailFeelingText => 'Sobre o sentimento';

  @override
  String get mealDetailBehaviors => 'Comportamentos';

  @override
  String get mealDetailClose => 'Fechar';

  @override
  String get behaviorForcedVomit => 'Vômito auto induzido';

  @override
  String get behaviorUsedLaxatives => 'Uso de laxante';

  @override
  String get behaviorRegurgitated => 'Regurgitação';

  @override
  String get behaviorHiddenFood => 'Escondeu comida';

  @override
  String get behaviorAteInSecret => 'Comer escondido';

  @override
  String get behaviorDiuretics => 'Uso de diurético';

  @override
  String get behaviorOtherMedication => 'Outras medicações';

  @override
  String get behaviorCompensatoryExercise => 'Exercício físico compensatório';

  @override
  String get behaviorChewAndSpit => 'Mastigar e cuspir';

  @override
  String get behaviorIntermittentFast => 'Jejum intermitente';

  @override
  String get behaviorSkipMeal => 'Pular refeição';

  @override
  String get behaviorBingeEating => 'Compulsão alimentar';

  @override
  String get behaviorGuiltAfterEating => 'Culpa após comer';

  @override
  String get behaviorCalorieCounting => 'Contagem de calorias';

  @override
  String get behaviorBodyChecking => 'Checagem corporal';

  @override
  String get behaviorBodyWeighing => 'Pesagem corporal';

  @override
  String get formConfigCategoryCompensatory => 'Métodos compensatórios';

  @override
  String get formConfigCategoryRestriction => 'Restrição alimentar';

  @override
  String get formConfigCategoryBinge => 'Exagero alimentar';

  @override
  String get formConfigCategoryOther => 'Outros';

  @override
  String get formConfigTitle => 'Comportamentos para o formulário';

  @override
  String formConfigPatientSubtitle(String name) {
    return 'Paciente: $name';
  }

  @override
  String get formConfigSectionEnabled => 'Habilitar seção de comportamento no formulário do paciente';

  @override
  String formConfigLastUpdated(String name, String date) {
    return 'Última alteração: por $name em $date';
  }

  @override
  String get formConfigChangeLogTitle => 'Histórico de alterações';

  @override
  String get formConfigButton => 'Configurar formulário';

  @override
  String get formConfigSave => 'Salvar';

  @override
  String get formConfigSaving => 'Salvando...';

  @override
  String get formConfigSaved => 'Configuração salva!';

  @override
  String get formConfigNoChangesYet => 'Nenhuma alteração registrada ainda.';

  @override
  String get settingsDebugApnsTitle => 'Token APNS (debug)';

  @override
  String get settingsDebugApnsSubtitle => 'Temporário — para diagnóstico de push no iOS';

  @override
  String get settingsDebugApnsShow => 'Ver token APNS';

  @override
  String get settingsDebugApnsCopy => 'Copiar';

  @override
  String get settingsDebugApnsUnavailable => 'Token APNS ainda não disponível. Abra o app de novo ou aguarde alguns segundos.';

  @override
  String get settingsDebugApnsCopied => 'Token APNS copiado';

  @override
  String get settingsDebugApnsRefresh => 'Atualizar';

  @override
  String get settingsDebugFcmTitle => 'Token FCM (debug)';

  @override
  String get settingsDebugFcmSubtitle => 'Mesmo valor gravado no Firestore para push';

  @override
  String get settingsDebugFcmShow => 'Ver token FCM';

  @override
  String get settingsDebugFcmCopy => 'Copiar';

  @override
  String get settingsDebugFcmUnavailable => 'Token FCM indisponível. Verifique permissão de notificação e rede.';

  @override
  String get settingsDebugFcmCopied => 'Token FCM copiado';
}
