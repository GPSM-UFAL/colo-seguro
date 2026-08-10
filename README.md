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

A jornada **não é fixa** — ela segue o fluxograma do projeto. Na tela "Onde você está agora?" a paciente escolhe sua situação, e o app monta **só o caminho dela**:

- resultado normal → volta à rotina;
- alteração leve → repetir o preventivo;
- alteração importante → encaminhamento → colposcopia → acompanhamento.

Quem escolhe "Não sei — quero ver tudo" cai na tela **Todos os caminhos**, que espelha o fluxograma completo (incluindo os caminhos do Teste de HPV). Essa tela também fica acessível pelo botão "Ver todos os caminhos" na Jornada.

Toda a lógica e os textos estão em `lib/data/content.dart`:

- `stepContents` — os nós (etapas) do fluxograma;
- `currentStepIndexForOnboarding(index)` — converte a escolha inicial em etapa;
- `journeyForCurrentStepIndex(index)` — monta a jornada a partir da etapa atual;
- `allPaths` / `hpvPaths` — o conteúdo da tela "Todos os caminhos".

Para mudar o fluxo (ex.: novo protocolo), edite só esse arquivo.

## Onde colocar as ilustrações

As imagens de cada tela vão em **`assets/illustrations/`**. Os nomes esperados estão em `assets/illustrations/LEIA-ME.txt` (ex.: `intro_0.png`, `etapa_encaminhamento.png`).

Enquanto a arte não existe, o app mostra um placeholder suave e **não quebra** — você adiciona as imagens depois, uma a uma. Para usar SVG no lugar de PNG, veja a observação no fim do `LEIA-ME.txt`.

## Onde colocar o áudio

Os `.mp3` da narração vão em **`assets/audio/`**. Os nomes exatos esperados estão em `assets/audio/LEIA-ME.txt` (ex.: `intro_0.mp3`, `etapa_encaminhamento.mp3`).

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
  services/audio_service.dart# tocador de áudio (just_audio)
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
    all_paths_screen.dart        # fluxograma completo ("todos os caminhos")
    step_detail_screen.dart      # detalhe de cada etapa
    faq_screen.dart              # tira-dúvidas + glossário
    support_screen.dart          # apoio
assets/audio/                # >>> seus .mp3 aqui <<<
assets/illustrations/        # >>> suas imagens aqui <<<
```

## Empacotar

- **Android (APK):** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **iOS:** `flutter build ios` (precisa de macOS + Xcode)
