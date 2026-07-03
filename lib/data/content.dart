import 'package:flutter/material.dart';

/// ===================================================================
/// CONTEÚDO + FLUXOGRAMA DO APP "Colo Seguro"
///
/// Aqui ficam:
///   1) Os textos de cada tela (retirados do Figma e do fluxograma).
///   2) O campo `audio`       -> nome do .mp3 em assets/audio/
///   3) O campo `illustration`-> nome da imagem em assets/illustrations/
///   4) A ÁRVORE DE DECISÃO da jornada da paciente (motor `journeyForOnboarding`).
///
/// Para mudar conteúdo, áudio ou ilustração, edite SÓ este arquivo.
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
    'Toque na etapa em que você está. O app guarda apenas esta escolha neste aparelho para não perder seu progresso.';

/// As opções estão na MESMA ordem usada pelo motor `journeyForOnboarding`.
const List<String> onboardingOptions = [
  'Fiz o exame preventivo Papanicolau ou Teste DNA HPV', // 0
  'Recebi um resultado alterado no exame de triagem preventivo', // 1
  'Fui encaminhada a outro serviço', // 2
  'Vou fazer a colposcopia', // 3
  'Já fiz a colposcopia', // 4
  'Não sei — quero ver tudo', // 5 (modo explorar todos os caminhos)
];

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

/// Ícones de cada opção do onboarding (mesma ordem de onboardingOptions).
const List<IconData> onboardingIcons = [
  Icons.assignment_outlined, // Fiz o exame preventivo
  Icons.favorite_outline_rounded, // Recebi um resultado alterado
  Icons.local_hospital_outlined, // Fui encaminhada a outro serviço
  Icons.search_rounded, // Vou fazer a colposcopia
  Icons.assignment_turned_in_outlined, // Já fiz a colposcopia
  Icons.help_outline_rounded, // Não sei — quero ver tudo
];

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
          // StepSection(
          //   'Como funciona',
          //   'Você se deita como no preventivo. A profissional usa um pequeno instrumento para visualizar o colo do útero e coleta a amostra com uma escovinha ou espátula. Pode causar um leve incômodo, mas costuma ser rápido.',
          //   audioFile: 'coleta_papanicolau_como_funciona.mp3',
          // ),
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
          // StepSection(
          //   'Por que ele é importante',
          //   'Quando encontra o vírus cedo, a equipe consegue acompanhar melhor e evitar problemas no futuro. A coleta é parecida com a do preventivo.',
          //   audioFile: 'coleta_dna_hpv_importancia.mp3',
          // ),
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
    // tabs: [
    //   CollectionTabContent(
    //     id: 'colposcopia',
    //     label: 'Colposcopia',
    //     tip:
    //         'Não esqueça de levar o encaminhamento para o centro especializado, assim como o resultado da citologia ou do Teste DNA HPV feito anteriormente.',
    //     sections: [
    //       StepSection(
    //         'O que é a colposcopia',
    //         'É um exame em que o médico usa um aparelho com luz e lente para ver o colo do útero bem de perto. Não corta e não entra no corpo.',
    //         audioFile: 'colposcopia_o_que_e.mp3',
    //       ),
    //       StepSection(
    //         'Como funciona',
    //         'Você fica deitada, como no preventivo. Pode sentir um leve incômodo e dura poucos minutos. Às vezes o médico coleta um pedacinho (semelhante a um grão de areia) para examinar em uma outra etapa chamada Biópsia',
    //         audioFile: 'colposcopia_como_funciona.mp3',
    //       ),
    //       StepSection(
    //         'Requisitos para o exame',
    //         '• Evite relações sexuais, inclusive com camisinha, de 24 a 48 horas antes.\n• Não use duchas vaginais, cremes, óvulos ou lubrificantes vaginais nos 2 dias anteriores.\n• Não esteja menstruada. O ideal é realizar o exame de 5 a 7 dias após o término do sangramento.\n• Informe ao médico caso esteja grávida ou com suspeita de gravidez.',
    //         audioFile: 'colposcopia_requisitos.mp3',
    //       ),
    //     ],
    //   ),
    //   CollectionTabContent(
    //     id: 'biopsia',
    //     label: 'Biópsia',
    //     tip:
    //         'Depois da biópsia, aguarde o resultado e siga a orientação da equipe.',
    //     sections: [
    //       StepSection(
    //         'O que é a biópsia',
    //         'Se o médico encontrar qualquer área suspeita durante a colposcopia, ele retira um pedacinho de tecido, semelhante ao tamanho de um grão de areia, para confirmar o diagnóstico em laboratório.',
    //         audioFile: 'biopsia_o_que_e.mp3',
    //       ),
    //       StepSection(
    //         'Como funciona',
    //         'Você fica deitada, como no preventivo. Pode sentir um leve incômodo e dura poucos minutos. Às vezes o médico coleta um pedacinho para examinar.',
    //         audioFile: 'biopsia_como_funciona.mp3',
    //       ),
    //     ],
    //   ),
    // ],
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
  // ----- Nós terminais dos caminhos A e B (aparecem em "todos os caminhos") -----
  'rotina': StepContent(
    id: 'rotina',
    title: 'Volta à rotina',
    summary: 'Resultado normal. Veja como seguir a rotina.',
    reassurance: 'Resultado normal. Continue se cuidando.',
    sections: [
      StepSection('O que significa (NILM)',
          'Seu exame não mostrou alterações. Você não precisa de exames avançados agora.'),
      StepSection('O que fazer',
          'Você volta ao rastreamento de rotina no posto. Em geral, repete o preventivo a cada 3 anos (ou conforme a equipe orientar).'),
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
      StepSection('O que significa (ASC-US, LSIL)',
          'É uma alteração pequena. Muitas dessas alterações desaparecem sozinhas, sem precisar de tratamento.'),
      StepSection('O que fazer',
          'A conduta costuma ser só repetir o exame preventivo depois de um tempo, no prazo que a equipe indicar. Você continua acompanhada no posto.'),
    ],
    tip: 'Volte para repetir o exame na data combinada.',
    audio: 'etapa_repetir.mp3',
    illustration: 'etapa_resultado.png',
  ),
};

/// ===================================================================
/// MOTOR DA JORNADA — monta o caminho da paciente conforme o perfil
/// ===================================================================
enum StepStatus { done, current, next, later }

class PlannedStep {
  final StepContent content;
  final StepStatus status;
  final String statusLabel; // "Concluído", "Você está aqui"...
  const PlannedStep(this.content, this.status, this.statusLabel);
}

class JourneyPlan {
  final String headline;
  final int currentStepIndex;
  final List<PlannedStep> steps;
  const JourneyPlan({
    required this.headline,
    required this.currentStepIndex,
    required this.steps,
  });
}

PlannedStep _p(String id, StepStatus s, String label) =>
    PlannedStep(stepContents[id]!, s, label);

const List<String> _journeyStepIds = [
  'primeiros-cuidados',
  'resultado',
  'encaminhamento',
  'colposcopia',
  'biopsia',
  'acompanhamento',
];

int currentStepIndexForOnboarding(int index) {
  switch (index) {
    case 0:
      return 1;
    case 1:
    case 2:
      return 2;
    case 3:
      return 3;
    case 4:
      return 4;
    case 5:
    default:
      return 0;
  }
}

String _headlineForCurrentStep(int index) {
  switch (index) {
    case 0:
      return 'Veja o caminho completo, com calma.';
    case 1:
      return 'Você fez o preventivo. Agora é aguardar o resultado.';
    case 2:
      return 'Seu exame teve uma alteração. Vamos juntas no próximo passo.';
    case 3:
      return 'A colposcopia é o seu próximo passo. Saber o que esperar ajuda.';
    case 4:
      return 'Você já fez a colposcopia. Agora é o acompanhamento.';
    case 5:
    default:
      return 'Você chegou ao acompanhamento. O cuidado continua.';
  }
}

String _statusLabelForStep(int stepIndex, int currentStepIndex) {
  if (stepIndex < currentStepIndex) return 'Concluído';
  if (stepIndex == currentStepIndex) {
    return currentStepIndex == 0 ? 'Comece por aqui' : 'Você está aqui';
  }
  if (stepIndex == currentStepIndex + 1) return 'Próxima etapa';
  return 'Depois';
}

StepStatus _statusForStep(int stepIndex, int currentStepIndex) {
  if (stepIndex < currentStepIndex) return StepStatus.done;
  if (stepIndex == currentStepIndex) return StepStatus.current;
  if (stepIndex == currentStepIndex + 1) return StepStatus.next;
  return StepStatus.later;
}

JourneyPlan journeyForCurrentStepIndex(int index) {
  final currentStepIndex = index.clamp(0, _journeyStepIds.length - 1).toInt();

  return JourneyPlan(
    headline: _headlineForCurrentStep(currentStepIndex),
    currentStepIndex: currentStepIndex,
    steps: List.generate(_journeyStepIds.length, (i) {
      return _p(
        _journeyStepIds[i],
        _statusForStep(i, currentStepIndex),
        _statusLabelForStep(i, currentStepIndex),
      );
    }),
  );
}

/// Recebe o índice escolhido no onboarding e devolve a jornada.
JourneyPlan journeyForOnboarding(int index) {
  switch (index) {
    case 0: // Fiz o exame preventivo -> aguardando resultado
      return JourneyPlan(
        currentStepIndex: 1,
        headline: 'Você fez o preventivo. Agora é aguardar o resultado.',
        steps: [
          _p('primeiros-cuidados', StepStatus.done, 'Concluído'),
          _p('resultado', StepStatus.current, 'Você está aqui'),
          _p('encaminhamento', StepStatus.next, 'Próxima etapa'),
          _p('colposcopia', StepStatus.later, 'Depois'),
          _p('biopsia', StepStatus.later, 'Depois'),
          _p('acompanhamento', StepStatus.later, 'Depois'),
        ],
      );
    case 1: // Recebi um resultado alterado
    case 2: // Fui encaminhada a outro serviço
      return JourneyPlan(
        currentStepIndex: 2,
        headline:
            'Seu exame teve uma alteração. Vamos juntas no próximo passo.',
        steps: [
          _p('primeiros-cuidados', StepStatus.done, 'Concluído'),
          _p('resultado', StepStatus.done, 'Concluído'),
          _p('encaminhamento', StepStatus.current, 'Você está aqui'),
          _p('colposcopia', StepStatus.next, 'Próxima etapa'),
          _p('biopsia', StepStatus.later, 'Depois'),
          _p('acompanhamento', StepStatus.later, 'Depois'),
        ],
      );
    case 3: // Vou fazer a colposcopia
      return JourneyPlan(
        currentStepIndex: 3,
        headline:
            'A colposcopia é o seu próximo passo. Saber o que esperar ajuda.',
        steps: [
          _p('primeiros-cuidados', StepStatus.done, 'Concluído'),
          _p('resultado', StepStatus.done, 'Concluído'),
          _p('encaminhamento', StepStatus.done, 'Concluído'),
          _p('colposcopia', StepStatus.current, 'Você está aqui'),
          _p('biopsia', StepStatus.next, 'Próxima etapa'),
          _p('acompanhamento', StepStatus.later, 'Depois'),
        ],
      );
    case 4:
      return JourneyPlan(
        currentStepIndex: 4,
        headline: 'Você já fez a colposcopia. Agora é o acompanhamento.',
        steps: [
          _p('primeiros-cuidados', StepStatus.done, 'Concluído'),
          _p('resultado', StepStatus.done, 'Concluído'),
          _p('encaminhamento', StepStatus.done, 'Concluído'),
          _p('colposcopia', StepStatus.done, 'Concluído'),
          _p('biopsia', StepStatus.current, 'Você está aqui'),
          _p('acompanhamento', StepStatus.next, 'Próxima etapa'),
        ],
      );
    case 5: // Não sei — quero ver tudo
    default:
      return JourneyPlan(
        currentStepIndex: 0,
        headline: 'Veja o caminho completo, com calma.',
        steps: [
          _p('primeiros-cuidados', StepStatus.current, 'Comece por aqui'),
          _p('resultado', StepStatus.next, 'Próxima etapa'),
          _p('encaminhamento', StepStatus.later, 'Depois'),
          _p('colposcopia', StepStatus.later, 'Depois'),
          _p('biopsia', StepStatus.later, 'Depois'),
          _p('acompanhamento', StepStatus.later, 'Depois'),
        ],
      );
  }
}

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

const List<String> supportMessages = [
  'Um passo de cada vez.',
  'Você não está sozinha.',
  'Pedir ajuda é se cuidar.',
];

class SupportContact {
  final String title;
  final String subtitle;
  final IconData icon;
  const SupportContact(this.title, this.subtitle, this.icon);
}

const List<SupportContact> supportContacts = [
  SupportContact('Unidade de referência',
      'Procure o posto onde você se consulta.', Icons.location_on_rounded),
  SupportContact('Disque Saúde — 136',
      'Ligação gratuita do Ministério da Saúde.', Icons.phone_rounded),
];
