# Projeto Colo Seguro

Este contexto descreve a linguagem do aplicativo de acolhimento e orientação da jornada de cuidado após exames preventivos do colo do útero.

## Language

**Etapa atual da jornada**:
A única posição persistida do cuidado da pessoa; no Acompanhamento, ela distingue internamente o caminho com Biópsia do caminho em que ela não foi necessária. A situação escolhida no onboarding apenas determina a posição inicial e não é preservada separadamente.
_Avoid_: persistir a escolha do onboarding como um segundo estado da jornada

**Modo de exploração**:
A visualização transitória e somente de leitura de toda a jornada para quem ainda não sabe informar sua Etapa atual, sem marcar nem persistir uma posição.
_Avoid_: tratar como Primeiros cuidados ou inventar progresso para a pessoa

**Coleta do preventivo**:
A etapa única da jornada em que a pessoa realizou o exame preventivo do colo do útero, seja por Papanicolau ou por Teste DNA HPV.
_Avoid_: separar Papanicolau e Teste DNA HPV como etapas diferentes da jornada

**Papanicolau**:
Tipo de exame preventivo que observa células coletadas do colo do útero para identificar alterações.
_Avoid_: tratar como sinônimo único de preventivo quando Teste DNA HPV também estiver no contexto

**Teste DNA HPV**:
Tipo de exame preventivo que procura sinais do HPV na amostra coletada do colo do útero.
_Avoid_: misturar com colposcopia ou biópsia

**Colposcopia**:
Exame em que o profissional de saúde observa o colo do útero de perto com um aparelho com luz e lente.
_Avoid_: tratar como coleta do preventivo, biópsia ou tratamento

**Decisão após a colposcopia**:
A informação dada pela pessoa sobre a solicitação de Biópsia, usada para reconhecer qual etapa vem depois da Colposcopia.
_Avoid_: avançar todas as pessoas automaticamente para Biópsia

**Biópsia**:
Coleta de um pequeno pedaço de tecido quando há uma área suspeita durante a colposcopia, para análise em laboratório. Antes da Decisão após a colposcopia, aparece na jornada como “Pode ser necessária”.
_Avoid_: tratar como parte obrigatória de toda colposcopia, como próxima etapa certa ou como diagnóstico final

**Biópsia não necessária**:
O estado exibido na jornada quando a pessoa informa que a Biópsia não foi solicitada após a Colposcopia.
_Avoid_: apresentar como Biópsia concluída ou ocultar essa etapa da jornada

**Acompanhamento**:
Etapa que sucede a Colposcopia, diretamente quando a Biópsia não foi necessária ou depois da Biópsia quando ela ocorreu.
_Avoid_: exigir Biópsia para chegar ao Acompanhamento
