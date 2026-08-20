==========================================================
  PASTA DE ÁUDIO — Colo Seguro
==========================================================

Coloque aqui os arquivos .mp3 da narração. O botão "Ouvir
explicação" em cada tela toca o arquivo correspondente.

Gere os áudios com uma IA de voz (ElevenLabs, Azure Neural
TTS, Google Cloud TTS...) em português-BR, com voz acolhedora.

------ FORMATO OBRIGATÓRIO DOS ÁUDIOS ------

Para funcionar bem no Android/ExoPlayer, salve todos os áudios como:

  - Formato: MP3
  - Codec: MPEG Layer III
  - Taxa de amostragem: 24 kHz
  - Bitrate: 96 kbps
  - Canais: mono
  - Sem tag ID3v2.4 no início do arquivo

O arquivo deve começar diretamente como stream MP3. Evite exportações
que adicionam metadados ID3v2.4, pois alguns aparelhos podem não tocar.

Se receber um áudio de IA ou editor externo, normalize antes de colocar
nesta pasta:

  ffmpeg -y -i entrada.mp3 -map_metadata -1 -id3v2_version 0 \
    -ar 24000 -ac 1 -codec:a libmp3lame -b:a 96k nome_esperado.mp3

Exemplo:

  ffmpeg -y -i narracao.mp3 -map_metadata -1 -id3v2_version 0 \
    -ar 24000 -ac 1 -codec:a libmp3lame -b:a 96k coleta_papanicolau_o_que_e.mp3

Depois de adicionar ou substituir áudios, reinstale o app ou rode:

  flutter clean
  flutter pub get
  flutter run

------ NOMES DOS ARQUIVOS USADOS ATUALMENTE ------

Carrossel de introdução:
  vamos_te_acompanhar.mp3       -> "Vamos te acompanhar"
  o_exame_preventivo.mp3        -> "O exame preventivo"
  seu_resultado_veio_alterado.mp3 -> "Seu resultado veio alterado"
  intro_3.mp3   -> "Você vai a um serviço especial"
  intro_4.mp3   -> "O que é colposcopia"
  intro_biopsia.mp3 -> "O que é biópsia"
  intro_5.mp3   -> "Você não está sozinha"

Etapas da jornada:
  etapa_coleta.mp3          -> Coleta do preventivo
  etapa_resultado.mp3       -> Resultado do exame
  etapa_encaminhamento.mp3  -> Encaminhamento
  etapa_colposcopia.mp3     -> Colposcopia
  etapa_biopsia.mp3         -> Biópsia
  etapa_acompanhamento.mp3  -> Conduta e acompanhamento
  etapa_rotina.mp3          -> Volta à rotina
  etapa_repetir.mp3         -> Repetição do exame

Decisões da jornada:
  depois_colposcopia.mp3    -> Depois da colposcopia

Os áudios de detalhes, dúvidas, glossário e apoio seguem os nomes definidos
em `lib/data/content.dart` e `lib/screens/support_screen.dart`.

------ IMPORTANTE ------

- Os textos para narração estão em lib/data/content.dart
  (campos "title"/"body"/"sections"). É só copiar e gerar.
- Se um arquivo ainda não existir, o app NÃO quebra: ele
  só mostra um aviso "áudio ainda não adicionado".
- Para trocar/atualizar um áudio, basta substituir o .mp3
  com o mesmo nome e rodar de novo.
==========================================================
