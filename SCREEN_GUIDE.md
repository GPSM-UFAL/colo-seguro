# Documentação Funcional e Fluxo de Telas - App de Rastreamento do Câncer de Colo do Útero

---

### PÚBLICO-ALVO (DIRETRIZES DE DESIGN)

O aplicativo é voltado exclusivamente para mulheres de diferentes faixas etárias, incluindo usuárias da terceira idade. Muitas delas possuem baixa instrução ou são totalmente analfabetas. O design DEVE seguir estas regras estritas de acessibilidade:

1. Interface Hiper-Visual: Reduza o uso de textos ao mínimo necessário. Use ícones universais, literais e autoexplicativos (ex: uma casa para 'Início', um microfone ou alto-falante para 'Ouvir'). Evite ícones abstratos.
2. Recursos de Áudio (Leitura de Conteúdo): Todas as telas devem ter um botão de "Play/Alto-falante" flutuante ou fixo de destaque próximo aos textos, indicando claramente a opção de leitura por voz.
3. Navegação Linear e Simplificada: Apenas uma ação principal por tela. Botões grandes, fáceis de tocar (mínimo de 48px), com alto contraste.
4. Psicologia das Cores: Use uma paleta de cores acolhedora, feminina e de alta legibilidade (ex: tons suaves combinados com contrastes nítidos para baixa visão). Evite excesso de estímulos visuais; o fundo deve ser limpo.
5. Tipografia: Caso haja texto, use fontes sem serifa, grandes, com excelente espaçamento.

## 📌 Diretrizes Importantes para o Desenvolvimento

1. **Linguagem e Comunicação (Público-Alvo Leigo):**
   - O público do aplicativo não é médico. Toda a comunicação deve ser empática, acolhedora e livre de jargões técnicos desnecessários.
   - **Fluxos Resumidos (Dashboard e Fluxo Secundário):** Devem focar no "o que é" e "o que fazer", usando textos curtos e linguagem extremamente acessível.
   - **Telas Específicas da Jornada:** Devem conter o detalhamento clínico (siglas, prazos, condutas médicas), mas sempre explicando o significado de cada termo logo em seguida para não assustar a paciente.

2. **Uso de Imagens e Ilustrações:**
   - O uso de apoio visual é fundamental para acalmar a usuária e explicar procedimentos. Foram adicionados **`[Placeholder: Imagem...]`** nos pontos onde a equipe de Design deve criar ilustrações amigáveis, preferencialmente em estilo _flat_ ou vetorial, fugindo de fotos realistas que possam causar apreensão.

---

## 🗺️ Arquitetura Global de Telas (User Flow)

> **[Módulo 1: Onboarding]**
> ├─► Tela 1: Boas-Vindas
> └─► Tela 2: Autoseleção (Onde você está?)
> ├─► (Opções 1 a 5) ──► Redireciona para Telas Detalhadas (Módulo 4)
> └─► (Opção "Não sei") ──► Redireciona para Fluxo Secundário Educacional (Módulo 2)
>
> **[Módulo 2: Fluxo Secundário Educacional - Carrossel]**
> ├─► Card Inicial: O que é o Rastreamento?
> ├─► Card 1: A Coleta
> ├─► Card 2: Os Resultados
> ├─► Card 3: A Colposcopia
> └─► Card 4: A Biópsia e Tratamento ──► (Fim do fluxo: Vai para Dashboard ou Tela 2)
>
> **[Módulo 3: Dashboard Principal]**
> └─► Tela Central: Linha do Tempo da Jornada (Status atual, etapas concluídas e próximas)
>
> **[Módulo 4: Telas Detalhadas da Jornada]**
> ├─► Tela 3A: 1º Passo - A Coleta
> ├─► Tela 3B: 2º Passo - Avaliação dos Resultados (Caminhos A, B e C)
> ├─► Tela 3C: 3º Passo - Colposcopia
> └─► Tela 3D: 4º Passo - Resultados da Biópsia e Tratamento

---

## 📄 Documentação Funcional das Telas

### Módulo 1: Onboarding e Triagem

**Tela 1: Boas-Vindas**

- **Objetivo:** Recepcionar a paciente de forma acolhedora.
- **Componentes:**
  - `[Placeholder: Ilustração acolhedora e empática focada na saúde e cuidado da mulher]`
  - **Texto:** _"Bem-vinda ao seu guia de saúde da mulher. Estamos aqui para apoiar e informar você durante toda a sua jornada de prevenção."_
  - **Botão:** "Começar".

**Tela 2: Autoseleção (Identificação da Etapa)**

- **Objetivo:** Identificar o momento da paciente para direcionamento.
- **Componentes:**
  - **Pergunta:** _"Em qual etapa do rastreamento você está no momento?"_
  - **Lista de opções:**
    1. Fiz o exame preventivo (Papanicolau ou Teste DNA HPV) ➔ _Vai para Tela 3A_
    2. Recebi um resultado alterado no exame ➔ _Vai para Tela 3B_
    3. Fui encaminhada a outro serviço ➔ _Vai para Tela 3C_
    4. Vou fazer a colposcopia ➔ _Vai para Tela 3C_
    5. Já fiz a colposcopia ➔ _Vai para Tela 3D_
    6. **Não sei em que etapa estou** ➔ _Vai para Módulo 2 (Fluxo Educacional)_

---

### Módulo 2: Fluxo Secundário Educacional (Visão Geral)

_Visual sugerido: Carrossel de Cards tipo "Stories" ou Swipe._

- **Card Inicial (O Objetivo):** `[Placeholder: Ilustração de um escudo ou símbolo de prevenção]`. **Texto:** O rastreamento busca descobrir pequenas alterações anos antes de virarem um problema grave, garantindo sucesso no tratamento.
- **Card 1 (A Coleta):** `[Placeholder: Ilustração simples de um posto de saúde/UBS]`. **Texto:** Tudo começa com um exame rápido no posto (Papanicolau ou HPV). A amostra vai para o laboratório.
- **Card 2 (Os Resultados):** `[Placeholder: Ilustração de um documento com um selo de verificação e caminhos apontando direções]`. **Texto:** O resultado define o próximo passo: liberação (rotina), repetição (alterações leves) ou exames detalhados (alterações graves).
- **Card 3 (A Colposcopia):** `[Placeholder: Ilustração didática do colposcópio funcionando como uma lupa brilhante]`. **Texto:** Um exame especializado que usa uma "lupa" para olhar o colo do útero de perto.
- **Card 4 (Biópsia e Tratamento):** `[Placeholder: Ilustração de um curativo ou símbolo de saúde recuperada]`. **Texto:** Se necessário, tira-se um pedacinho do tecido. O foco é sempre o tratamento precoce e a cura. (Botão de ação: "Entendi meu processo").

---

### Módulo 3: Dashboard Principal da Jornada

**Tela Central: Linha do Tempo (Roadmap)**

- **Objetivo:** Mostrar visualmente o status da paciente.
- **Componentes:**
  - `[Placeholder: Gráfico de progresso ou barra de linha do tempo interativa]`
  - Indicadores de **Etapas Concluídas** (com check verde).
  - Indicador de **Estado Atual** (em destaque).
  - Indicador de **Próximas Etapas** (bloqueadas ou em cinza).
  - Botões em cada etapa da linha do tempo para acessar as Telas Detalhadas (Módulo 4).

---

### Módulo 4: Telas Detalhadas da Jornada (Aprofundamento)

**Tela 3A: 1º Passo - A Coleta**

- **Objetivo:** Explicar detalhadamente os exames.
- **Componentes:**
  - `[Placeholder: Ilustração simples e não intimidatória do ambiente de coleta]`
  - **Papanicolau:** Explicação da coleta morfológica e periodicidade (anual nos 2 primeiros exames; depois a cada 3 anos se normais).
  - **Teste DNA-HPV:** Explicação da coleta molecular e periodicidade (a cada 5 anos).

**Tela 3B: 2º Passo - Avaliação dos Resultados**

- **Objetivo:** Traduzir o laudo para a paciente.
- **Componentes:**
  - `[Placeholder: Ilustração de laudo médico traduzido]`
  - **Caminho A (Normal - NILM):** Paciente liberada para rotina.
  - **Caminho B (Alterações Leves - ASC-US / LSIL):** Regridem espontaneamente; a conduta é repetir no posto de saúde.
  - **Caminho C (Alterações Graves - ASC-H, HSIL, AGC, AIS):** Risco de evolução. Encaminhamento imediato para colposcopia.
  - _Nota de UX:_ Mostrar apenas o caminho correspondente ao que a paciente preencheu, ou usar "sanfonas" (accordions) para ocultar os resultados que não interessam no momento.

**Tela 3C: 3º Passo - A Colposcopia**

- **Objetivo:** Preparar a paciente para o exame especializado.
- **Componentes:**
  - `[Placeholder: Ilustração amigável médico(a) mostrando o equipamento para a paciente]`
  - **Explicação:** Exame complementar com aplicação de líquidos (ácido acético e Lugol) para mudar a cor de áreas doentes. Se houver suspeita, é feita a biópsia dirigida.

**Tela 3D: 4º Passo - Resultados da Biópsia e Condutas Finais**

- **Objetivo:** Explicar o diagnóstico final e próximos passos.
- **Componentes:**
  - Tabela ou lista interativa com traduções dos termos:
    - **Ausência de Lesão:** Retorno à rotina normal.
    - **NIC I:** Acompanhamento clínico.
    - **NIC II e NIC III:** Tratamento para retirada da área (CAF/LEEP/Conização).
    - **AIS ou Carcinoma Invasor:** Encaminhamento para oncoginecologia (cirurgia/tratamento específico).
