import 'package:flutter/material.dart';

import '../domain/journey_definition.dart';

/// ===================================================================
/// CONTEÚDO DO APP "Colo Seguro"
///
/// Aqui ficam:
///   1) Os textos de cada tela (retirados do Figma e do fluxograma).
///   2) O campo `audio`       -> nome do .mp3 em assets/audio/
///   3) O campo `illustration`-> nome da imagem em assets/illustrations/
///
/// Para mudar conteúdo, áudio ou ilustração, edite este arquivo. As regras de
/// estrutura da jornada fica em `domain/journey_definition.dart`.
/// ===================================================================

/// ---------- Carrossel de introdução (telas 0 a 5) ----------
class IntroPage {
  final String title;
  final String body;
  final String? bodySecondary;
  final String? stepLabel;
  final String cta;
  final String audio; // assets/audio/<audio>
  final String illustration; // assets/illustrations/<illustration>

  const IntroPage({
    required this.title,
    required this.body,
    required this.cta,
    required this.audio,
    required this.illustration,
    this.bodySecondary,
    this.stepLabel,
  });
}

const List<IntroPage> introPages = [
  IntroPage(
    title: 'Vamos te acompanhar',
    body:
        'Este aplicativo explica, com calma, cada passo do seu cuidado. Você pode ouvir tudo em áudio.',
    cta: 'Começar',
    audio: 'vamos_te_acompanhar.mp3',
    illustration: 'welcome.jpeg',
  ),
  IntroPage(
    title: 'Primeiros cuidados',
    body:
        'Cuidar da sua saúde começa com exames simples de rotina.  Hoje em dia, existem duas maneiras principais de fazer essa checagem:',
    bodySecondary: '''
• Papanicolau:  É o mais comum. Ele procura por pequenas alterações nas células do útero. Também pode ser chamado de citologia, preventivo ou colpositologia.

• Teste DNA HPV: É um exame mais moderno. Ele procura diretamente pelo vírus que pode causar essas alterações.''',
    stepLabel: 'Passo 1 de 6',
    cta: 'Próximo',
    audio: 'o_exame_preventivo.mp3',
    illustration: 'etapa_coleta.png',
  ),
  IntroPage(
    title: 'Entendendo seu resultado',
    body:
        'Receber um resultado alterado pode assustar, mas não significa que você tem câncer. Na verdade, isso quer dizer apenas que o exame cumpriu o seu papel de prevenção: ele acendeu um sinal amarelo para que o médico olhe tudo mais de perto, por pura segurança. É o momento de investigar com calma para cuidar de você da melhor forma possível.',
    stepLabel: 'Passo 2 de 6',
    cta: 'Próximo',
    audio: 'seu_resultado_veio_alterado.mp3',
    illustration: 'etapa_resultado.png',
  ),
  IntroPage(
    title: 'Consulta em Centro de Especialidade',
    body:
        'Se a enfermeira ou médica recomendou uma visita a um centro de especialidade, fique tranquila: isso faz parte do protocolo normal de segurança. Lá, você será atendida por uma equipe focada em olhar para o seu caso com ainda mais atenção e carinho. É um ambiente seguro, preparado exatamente para tirar todas as dúvidas.',
    stepLabel: 'Passo 3 de 6',
    cta: 'Próximo',
    audio: 'intro_3.mp3',
    illustration: 'voce_vai_a_um_servico_especial.png',
  ),
  IntroPage(
    title: 'O que é a Colposcopia',
    body:
        'A colposcopia é um exame bem simples e seguro. Para realizá-lo, o médico usa um aparelho chamado colposcópio, que funciona como uma espécie de binóculo com luz. Ele fica posicionado do lado de fora do corpo, apenas iluminando e ampliando a imagem para ver o colo do útero bem de pertinho.',
    stepLabel: 'Passo 4 de 6',
    cta: 'Próximo',
    audio: 'intro_4.mp3',
    illustration: 'etapa_colposcopia.png',
  ),
  IntroPage(
    title: 'O que é a Biópsia',
    body:
        '''Durante a colposcopia, se o médico encontrar alguma área suspeita, ele retirará um pequeno pedaço de tecido para análise. 

Esse material será enviado a um laboratório de patologia. Depois de pronto, você deverá retirar o resultado no laboratório para dar andamento aos próximos passos do seu atendimento.''',
    stepLabel: 'Passo 4 de 6',
    cta: 'Próximo',
    audio: 'intro_biopsia.mp3',
    illustration: 'etapa_colposcopia.png',
  ),
  IntroPage(
    title: 'Você não está sozinha',
    body:
        'O cuidado com a sua saúde é um caminho que trilhamos juntas. Agora que você já conhece os próximos passos, o segredo é manter a calma e seguir em frente. Toda a equipe de saúde está preparada para acompanhar você de perto, com toda a segurança e atenção que você merece.',
    stepLabel: 'Passo 5 de 6',
    cta: 'Concluir',
    audio: 'intro_5.mp3',
    illustration: 'voce_nao_esta_sozinha.jpeg',
  ),
];

/// ---------- Onboarding "Onde você está" ----------
const String onboardingTitle = 'Onde você está agora?';
const String onboardingSubtitle =
    'Toque na etapa em que você está. O app guarda apenas sua etapa atual neste aparelho para não perder seu progresso.';

class OnboardingOption {
  final JourneySituation situation;
  final String label;
  final IconData icon;

  const OnboardingOption({
    required this.situation,
    required this.label,
    required this.icon,
  });
}

const List<OnboardingOption> onboardingOptions = [
  OnboardingOption(
    situation: JourneySituation.preventiveCollected,
    label: 'Fiz o exame preventivo Papanicolau ou Teste DNA HPV',
    icon: Icons.assignment_outlined,
  ),
  OnboardingOption(
    situation: JourneySituation.alteredResult,
    label: 'Recebi um resultado alterado no exame de triagem preventivo',
    icon: Icons.favorite_outline_rounded,
  ),
  OnboardingOption(
    situation: JourneySituation.referred,
    label: 'Fui encaminhada a outro serviço',
    icon: Icons.local_hospital_outlined,
  ),
  OnboardingOption(
    situation: JourneySituation.awaitingColposcopy,
    label: 'Vou fazer a colposcopia',
    icon: Icons.search_rounded,
  ),
  OnboardingOption(
    situation: JourneySituation.postColposcopy,
    label: 'Já fiz a colposcopia',
    icon: Icons.assignment_turned_in_outlined,
  ),
  OnboardingOption(
    situation: JourneySituation.explore,
    label: 'Não sei — quero ver tudo',
    icon: Icons.help_outline_rounded,
  ),
];

const String journeyExplorationHeadline =
    'Explore todos os passos, sem marcar uma etapa atual.';

String journeyHeadlineFor(JourneyStageId stage) {
  return switch (stage) {
    JourneyStageId.preventiveCollection =>
      'Veja o caminho completo, com calma.',
    JourneyStageId.result =>
      'Você fez o preventivo. Agora é aguardar o resultado.',
    JourneyStageId.referral =>
      'Seu exame teve uma alteração. Vamos juntas no próximo passo.',
    JourneyStageId.colposcopy =>
      'A colposcopia é o seu próximo passo. Saber o que esperar ajuda.',
    JourneyStageId.biopsy =>
      'A biópsia foi solicitada. Vamos entender esta etapa.',
    JourneyStageId.followUp =>
      'Você chegou ao acompanhamento. O cuidado continua.',
  };
}

String journeyStatusLabelFor(
  JourneyStageStatus status, {
  bool isFirstStage = false,
}) {
  return switch (status) {
    JourneyStageStatus.completed => 'Concluído',
    JourneyStageStatus.current =>
      isFirstStage ? 'Comece por aqui' : 'Você está aqui',
    JourneyStageStatus.next => 'Próxima etapa',
    JourneyStageStatus.later => 'Depois',
    JourneyStageStatus.mayBeNeeded => 'Pode ser necessária',
    JourneyStageStatus.notNeeded => 'Biópsia não necessária',
    JourneyStageStatus.exploration => 'Conheça esta etapa',
  };
}

/// ===================================================================
/// CONTEÚDO DAS ETAPAS (nós do fluxograma)
/// ===================================================================
class StepSection {
  final String label;
  final String text;
  final String? audioFile;
  const StepSection(this.label, this.text, {this.audioFile});
}

class CollectionTabContent {
  final String id;
  final String label;
  final List<StepSection> sections;
  final String tip;

  const CollectionTabContent({
    required this.id,
    required this.label,
    required this.sections,
    required this.tip,
  });
}

/// Conteúdo de uma etapa — independente da posição na jornada.
class StepContent {
  final String id;
  final String title;
  final String summary; // frase curta mostrada no card "Você está aqui"
  final String reassurance;
  final List<StepSection> sections;
  final List<CollectionTabContent>? tabs;
  final String tip;
  final String audio; // assets/audio/<audio>
  final String illustration; // assets/illustrations/<illustration>

  const StepContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.reassurance,
    required this.sections,
    this.tabs,
    required this.tip,
    required this.audio,
    required this.illustration,
  });
}

/// Mapa central de todos os nós do fluxograma.
const Map<String, StepContent> stepContents = {
  'primeiros-cuidados': StepContent(
    id: 'primeiros-cuidados',
    title: 'Primeiros Cuidados',
    summary: 'O primeiro passo do seu cuidado, feito no posto.',
    reassurance: 'A coleta é rápida. Se sentir medo, avise a profissional.',
    sections: [],
    tabs: [
      CollectionTabContent(
        id: 'papanicolau',
        label: 'Papanicolau',
        tip:
            'Depois da coleta, aguarde o resultado e siga a orientação da equipe. O exame costuma ser realizado todo ano nos dois primeiros anos e, se estiver tudo certo, repetido a cada 3 anos.',
        sections: [
          StepSection('O que é o Papanicolau',
              'O preventivo, ou Papanicolau, é um exame simples feito no posto. A enfermeira coleta uma pequena amostra do colo do útero através de uma escovinha, sem dor, para ver se está tudo bem.',
              audioFile: 'coleta_papanicolau_o_que_e.mp3'),
          StepSection(
            'Requisitos para o exame',
            '• Evite relações sexuais, inclusive com camisinha, de 24 a 48 horas antes.\n• Não use duchas vaginais, cremes, óvulos ou lubrificantes nos 2 dias anteriores.\n• Não esteja menstruada. O ideal é fazer de 5 a 7 dias depois que o sangramento terminar.',
            audioFile: 'coleta_papanicolau_requisitos.mp3',
          ),
        ],
      ),
      CollectionTabContent(
        id: 'dna-hpv',
        label: 'Teste DNA HPV',
        tip:
            'Depois da coleta, aguarde o resultado e siga a orientação da equipe. O exame costuma ser realizado todo ano nos dois primeiros anos e, se estiver tudo certo, repetido a cada 3 anos.',
        sections: [
          StepSection(
            'O que é o Teste DNA HPV',
            'É um exame feito com a coleta no colo do útero. Ele procura sinais do HPV, vírus que pode causar alterações antes de virar doença.',
            audioFile: 'coleta_dna_hpv_o_que_e.mp3',
          ),
          StepSection(
            'Requisitos para o exame',
            '• Evite relações sexuais, inclusive com camisinha, de 24 a 48 horas antes.\n• Não use duchas vaginais, cremes, óvulos ou lubrificantes nos 2 dias anteriores.\n• Não esteja menstruada. O ideal é fazer de 5 a 7 dias depois que o sangramento terminar.\n• Avise a profissional se estiver grávida ou se houver suspeita de gravidez.',
            audioFile: 'coleta_dna_hpv_requisitos.mp3',
          ),
        ],
      ),
    ],
    tip: 'Depois da coleta, aguarde o resultado e siga a orientação da equipe.',
    audio: 'etapa_coleta.mp3',
    illustration: 'etapa_coleta.png',
  ),
  'resultado': StepContent(
    id: 'resultado',
    title: 'Resultado dos exames',
    summary:
        'Agora é entender o que o resultado do seu exame indica. O resultado pode seguir três caminhos:',
    reassurance: 'Receber um resultado pode dar medo. Vamos com calma.',
    sections: [
      StepSection('Tudo certo (NILM)',
          'Não achou alteração. Você volta para a rotina do posto.'),
      StepSection('Alteração leve (ASC-US, LSIL)',
          'Pequena alteração. Muitas somem sozinhas — você só repete o exame depois.'),
      StepSection('Alteração importante (ASC-H, HSIL, AGC e AIS)',
          'Aí sim você vai para um exame mais detalhado: a colposcopia.'),
    ],
    tip: 'O resultado pode seguir três caminhos. Veja o seu com a equipe.',
    audio: 'etapa_resultado.mp3',
    illustration: 'etapa_resultado.png',
  ),
  'encaminhamento': StepContent(
    id: 'encaminhamento',
    title: 'Encaminhamento',
    summary:
        'Seu preventivo teve uma alteração. Por isso você foi a um serviço especializado.',
    reassurance: 'Respire. Vamos com calma, juntas nisso.',
    sections: [
      StepSection('Por que você está aqui',
          'Seu exame preventivo teve uma alteração. Por isso a equipe de saúde te encaminhou para um serviço especializado em ginecologia.'),
      StepSection('O que acontece agora',
          'Nesse serviço, um médico vai examinar o colo do útero bem de perto, com um exame chamado colposcopia. É normal e seguro.'),
    ],
    tip:
        'Leve seu documento, o resultado do preventivo e o encaminhamento para fazer a colposcopia.',
    audio: 'etapa_encaminhamento.mp3',
    illustration: 'voce_vai_a_um_servico_especial.png',
  ),
  'colposcopia': StepContent(
    id: 'colposcopia',
    title: 'Colposcopia',
    summary: 'É o seu próximo exame. Saber o que esperar ajuda.',
    reassurance: 'É normal sentir ansiedade. Saber o que esperar ajuda.',
    sections: [
      StepSection('O que é a Colposcopia',
          'É um exame em que o médico usa um aparelho com luz e lente para ver o colo do útero bem de perto. Não corta e não entra no corpo.'),
      StepSection('Como funciona',
          'Você fica deitada, como no preventivo. Pode sentir um leve incômodo e dura poucos minutos. Às vezes o médico coleta um pedacinho (semelhante a um grão de areia) para examinar em uma outra etapa chamada Biópsia'),
      StepSection(
        'Requisitos para o exame',
        '• Evite relações sexuais, inclusive com camisinha, de 24 a 48 horas antes.\n• Não use duchas vaginais, cremes, óvulos ou lubrificantes nos 2 dias anteriores.\n• Não esteja menstruada. O ideal é fazer de 5 a 7 dias depois que o sangramento terminar.\n • Informar ao médico caso  esteja grávida ou com suspeita de gravidez',
        audioFile: 'coleta_papanicolau_requisitos.mp3',
      ),
    ],
    tip:
        'Não esqueça de levar o encaminhamento para o centro especializado, assim como o resultado da citologia ou teste de DNA HPV feito anteriormente',
    audio: 'etapa_colposcopia.mp3',
    illustration: 'etapa_colposcopia.png',
  ),
  'biopsia': StepContent(
    id: 'biopsia',
    title: 'Biópsia',
    summary: 'Agora é entender o que o resultado do seu exame indica.',
    reassurance: 'Receber um resultado pode dar medo. Vamos com calma.',
    sections: [
      StepSection('O que é a Biópsia',
          'Se o médico encontrar qualquer área suspeita durante a colposcopia, ele retira um pedacinho de tecido (semelhante ao tamanho de um grão de areia) para mandar confirmar o diagnóstico em laboratório.'),
      StepSection('Como funciona',
          'O material coletado no exame de colposcopia será enviado para o laboratório de patologia. Lá você deve buscar o resultado depois de pronto para seguir com as próximas etapas.'),
    ],
    tip:
        'Depois da coleta, aguarde o resultado e siga a orientação da equipe. O exame é realizado todo ano nos dois primeiros anos e caso esteja tudo certo, se repetirá a cada 3 anos',
    audio: 'etapa_biopsia.mp3',
    illustration: 'etapa_resultado.png',
  ),
  'acompanhamento': StepContent(
    id: 'acompanhamento',
    title: 'Acompanhamento',
    summary: 'O cuidado continua. Veja o que acontece depois.',
    reassurance: 'Você chegou até aqui. Estamos com você.',
    sections: [
      StepSection(
        'O que acontece depois',
        'Com o resultado dos exames resultados em mãos, você deve voltar ao posto de saúde para mostrar ao profissional (enfermeiro ou médico). Lá a equipe irá decidir o melhor tratamento: pode ser só acompanhar de perto, ou um pequeno tratamento. Cada caso é único.',
        audioFile: 'coleta_papanicolau_requisitos.mp3',
      ),
      StepSection(
        'Por que continuar indo',
        'Buscar o resultado dos exames e manter as consulta garante que tudo seja acompanhado e resolvido cedo. Não falte às datas marcadas.',
        audioFile: 'coleta_papanicolau_requisitos.mp3',
      ),
    ],
    tip: 'Volte sempre que a equipe marcar. Anote as datas para não se perder.',
    audio: 'etapa_acompanhamento.mp3',
    illustration: 'etapa_acompanhamento.jpeg',
  ),
};

/// Conteúdo complementar ainda não associado à Definição da Jornada.
///
/// Mantê-lo separado faz a validação fail-fast distinguir conteúdo ativo de
/// material editorial reservado para uma evolução futura do caminho.
const Map<String, StepContent> supplementaryStepContents = {
  'rotina': StepContent(
    id: 'rotina',
    title: 'Volta à rotina',
    summary: 'Resultado normal. Veja como seguir a rotina.',
    reassurance: 'Resultado normal. Continue se cuidando.',
    sections: [
      StepSection(
        'O que significa (NILM)',
        'Seu exame não mostrou alterações. Você não precisa de exames avançados agora.',
      ),
      StepSection(
        'O que fazer',
        'Você volta ao rastreamento de rotina no posto. Em geral, repete o preventivo a cada 3 anos (ou conforme a equipe orientar).',
      ),
    ],
    tip: 'Não deixe de repetir o preventivo no prazo.',
    audio: 'etapa_rotina.mp3',
    illustration: 'etapa_rotina.jpeg',
  ),
  'repetir': StepContent(
    id: 'repetir',
    title: 'Repetir o preventivo',
    summary: 'Alteração leve. Veja por que é só repetir o exame.',
    reassurance: 'Alteração leve não é motivo para se assustar.',
    sections: [
      StepSection(
        'O que significa (ASC-US, LSIL)',
        'É uma alteração pequena. Muitas dessas alterações desaparecem sozinhas, sem precisar de tratamento.',
      ),
      StepSection(
        'O que fazer',
        'A conduta costuma ser só repetir o exame preventivo depois de um tempo, no prazo que a equipe indicar. Você continua acompanhada no posto.',
      ),
    ],
    tip: 'Volte para repetir o exame na data combinada.',
    audio: 'etapa_repetir.mp3',
    illustration: 'etapa_resultado.png',
  ),
};

/// ---------- Tira-dúvidas ----------
class FaqItem {
  final String question;
  final String answer;
  final String? audio;
  const FaqItem(this.question, this.answer, {this.audio});
}

const List<FaqItem> faqItems = [
  FaqItem('Resultado alterado é câncer?',
      'Não. Quer dizer que algo precisa ser olhado com mais atenção. Não é um diagnóstico de câncer.',
      audio: 'faq_resultado_alterado.mp3'),
  FaqItem('A colposcopia dói?',
      'Geralmente não. Pode causar um leve incômodo, parecido com o preventivo, e dura poucos minutos.',
      audio: 'faq_colposcopia_doi.mp3'),
  FaqItem('Preciso levar algo no dia da colposcopia?',
      'Leve seu documento, o resultado do preventivo e o encaminhamento para fazer a colposcopia. Use roupas confortáveis.',
      audio: 'faq_o_que_levar.mp3'),
  FaqItem('Posso ir acompanhada?',
      'Sim. Você pode levar alguém de confiança para te dar apoio.',
      audio: 'faq_acompanhada.mp3'),
];

class GlossaryItem {
  final String term;
  final String meaning;
  final String? audio;
  const GlossaryItem(this.term, this.meaning, {this.audio});
}

const List<GlossaryItem> glossary = [
  GlossaryItem('Papanicolau',
      'O exame preventivo do colo do útero, também chamado citologia.',
      audio: 'glossario_papanicolau.mp3'),
  GlossaryItem('Colposcopia', 'Exame que vê o colo de pertinho.',
      audio: 'glossario_colposcopia.mp3'),
  GlossaryItem('Biópsia', 'Coleta de um pedacinho para examinar.',
      audio: 'glossario_biopsia.mp3'),
];

/// ---------- Apoio ----------
const String supportHighlightTitle = 'Sentir medo é normal';
const String supportHighlightBody =
    'Respire fundo. Você está cuidando de você e isso já é coragem.';
