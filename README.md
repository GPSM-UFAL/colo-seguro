# Colo Seguro

App mobile (Flutter) que guia, com calma e em áudio, mulheres pelo caminho do rastreamento do câncer de colo do útero (preventivo → resultado → encaminhamento → colposcopia → acompanhamento).

Telas e textos do app **Colo Seguro**.

## Como rodar

Pré-requisito: ter o Flutter instalado (`flutter --version`). Se ainda não tem: https://docs.flutter.dev/get-started/install

```bash
flutter pub get
flutter run
```

O projeto oferece suporte somente a Android, iOS e web. Se for necessário
regenerar essas pastas, use `flutter create --platforms=android,ios,web .`.

Para rodar em um device específico: `flutter devices` e depois `flutter run -d <id>`.

## Como a jornada funciona (árvore de decisão)

A jornada segue o fluxograma do projeto. Na tela "Onde você está agora?" a pessoa escolhe sua situação, e o app persiste uma identidade estável para a etapa atual:

- coleta do preventivo → resultado → encaminhamento → colposcopia;
- biópsia solicitada → biópsia → acompanhamento;
- biópsia não solicitada → acompanhamento, com a biópsia marcada como "não necessária".

Quem escolhe "Não sei — quero ver tudo" entra no **Modo de exploração**: vê todas as etapas sem marcar ou alterar seu progresso. Se já existia uma etapa atual, ela é preservada.

As responsabilidades ficam separadas:

- `lib/data/content.dart` — textos e conteúdo das etapas;
- `lib/domain/journey_definition.dart` — identidades, ordem, transições e associação validada ao conteúdo;
- `lib/services/journey_session.dart` — persistência, migração e estado transitório das telas;
- `CONTEXT.md` — vocabulário e invariantes do cuidado.

A `JourneySession` publica estados prontos para as telas e só altera o estado visível depois que a nova etapa foi persistida com sucesso.

## Onde colocar as ilustrações

As imagens de cada tela vão em **`assets/illustrations/`**. Os nomes usados atualmente estão em `assets/illustrations/README.txt` (ex.: `welcome.jpeg`, `etapa_colposcopia.png`).

Enquanto a arte não existe, o app mostra um placeholder suave e **não quebra** — você adiciona as imagens depois, uma a uma. Para usar SVG no lugar de PNG, veja a observação no fim do `README.txt`.

## Onde colocar o áudio

Os `.mp3` da narração vão em **`assets/audio/`**. Os nomes usados atualmente estão em `assets/audio/README.txt` (ex.: `vamos_te_acompanhar.mp3`, `etapa_encaminhamento.mp3`).

Fluxo sugerido:

1. Abra `lib/data/content.dart` e copie os textos (`title`/`body`/`sections`).
2. Gere a narração numa IA de voz PT-BR (ElevenLabs, Azure Neural TTS, Google Cloud TTS).
3. Salve cada `.mp3` em `assets/audio/` com o nome esperado.
4. `flutter run` — o botão "Ouvir explicação" já toca o arquivo certo.

Enquanto um áudio não existir, o app não quebra: mostra um aviso discreto.

## Estrutura

```
lib/
  main.dart                  # entrada do app
  theme/app_theme.dart       # cores e fonte (tokens do Figma)
  services/audio_service.dart # tocador de áudio (just_audio)
  domain/journey_definition.dart # estrutura e regras puras da jornada
  services/journey_session.dart # persistência e estado transitório
  data/content.dart          # TODOS os textos + nomes dos áudios
  widgets/
    audio_button.dart        # botão "Ouvir explicação" reutilizável
    primary_button.dart      # botão verde + ilustração
  widgets/
    app_illustration.dart    # ilustração por tela (com fallback de placeholder)
  screens/
    welcome_carousel_screen.dart # telas 0–5 (intro)
    onboarding_screen.dart       # "Onde você está agora?" (define o caminho)
    home_shell.dart              # barra inferior (Jornada/Dúvidas/Apoio)
    journey_screen.dart          # jornada personalizada (só o caminho dela)
    post_colposcopy_decision_screen.dart # decisão condicional da biópsia
    step_detail_screen.dart      # detalhe de cada etapa
    faq_screen.dart              # tira-dúvidas + glossário
    support_screen.dart          # apoio
assets/audio/                # >>> seus .mp3 aqui <<<
assets/illustrations/        # >>> suas imagens aqui <<<
```

## Design e documentação

- `prototype.pen` — protótipo visual atual, incluindo o fluxo de biópsia.
- `images/digital-welcome.fig` — fonte complementar do design no Figma.
- `SCREEN_GUIDE.md` — requisitos funcionais e fluxo das telas.
- `GETTING_STARTED.md` — instruções resumidas para executar e gerar builds.

## Empacotar

- **Android (APK):** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **iOS:** `flutter build ios` (precisa de macOS + Xcode)
