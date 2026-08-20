==========================================================
  PASTA DE ILUSTRAÇÕES — Colo Seguro
==========================================================

Coloque aqui as imagens de cada tela. Enquanto a arte não
existe, o app mostra um PLACEHOLDER suave (não quebra).
É só ir adicionando as imagens depois, uma a uma.

Formato sugerido: PNG (com fundo transparente ou claro).
Tamanho sugerido: ~1080 x 720 px (proporção 3:2).
Se preferir SVG, veja a observação no final.

------ NOMES DOS ARQUIVOS USADOS ATUALMENTE ------

Carrossel de introdução:
  welcome.jpeg                         -> Boas-vindas
  etapa_coleta.png                     -> O exame preventivo
  etapa_resultado.png                  -> Resultado alterado
  voce_vai_a_um_servico_especial.png   -> Serviço especializado
  etapa_colposcopia.png                -> Colposcopia e biópsia
  voce_nao_esta_sozinha.jpeg           -> Você não está sozinha

Etapas da jornada (nós do fluxograma):
  etapa_coleta.png          -> Coleta do preventivo
  etapa_resultado.png       -> Resultado do exame
  voce_vai_a_um_servico_especial.png -> Encaminhamento
  etapa_colposcopia.png     -> Colposcopia
  etapa_acompanhamento.jpeg -> Conduta e acompanhamento
  etapa_rotina.jpeg         -> Resultado normal (volta à rotina)

------ COMO TROCAR/ATUALIZAR ------
Basta colocar a imagem com o nome certo e rodar de novo.
Os nomes também estão em lib/data/content.dart (campo
"illustration") — se quiser usar outro nome, mude lá.

------ QUER USAR SVG EM VEZ DE PNG? ------
1) Adicione a dependência flutter_svg no pubspec.yaml.
2) Em lib/widgets/app_illustration.dart, troque Image.asset
   por SvgPicture.asset (mantendo o errorBuilder/placeholder).
==========================================================
