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
  String get diaryTitle => 'YummyLog';

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
  String get questionUsedLaxatives => 'Você usou laxantes ou diuréticos desde seu último registro?';

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
  String get accountProHint => 'Login e sincronização disponíveis no plano Pro.';

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
}
