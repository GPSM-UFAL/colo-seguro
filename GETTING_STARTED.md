# Como rodar o Colo Seguro

App Flutter (Android APK + iOS/web) que guia, em áudio, a jornada da paciente no rastreamento do câncer de colo do útero.

## Pré-requisitos

- Flutter instalado: https://docs.flutter.dev/get-started/install
- Verifique com: `flutter --version`

## Rodar em modo desenvolvimento

```bash
flutter pub get
flutter run
```

Para escolher o dispositivo:

```bash
flutter devices
flutter run -d <id-do-dispositivo>
```

## Gerar build

- **Android (APK):** `flutter build apk --release`
  → `build/app/outputs/flutter-apk/app-release.apk`
- **iOS:** `flutter build ios` (precisa de macOS + Xcode)
- **Web (PWA):** `flutter build web`

## Onde ficam as coisas

- `lib/data/content.dart` — todos os textos e a árvore de decisão da jornada.
- `assets/audio/` — arquivos `.mp3` da narração (nomes no `README.txt`).
- `assets/illustrations/` — imagens das telas (nomes no `README.txt`).
- `prototype.pen` — protótipo visual atual.
- `SCREEN_GUIDE.md` — requisitos funcionais e fluxo das telas.

> Áudios e ilustrações são opcionais para rodar: se ainda não existirem,
> o app usa um placeholder e não quebra.

Detalhes completos da estrutura estão no `README.md`.
