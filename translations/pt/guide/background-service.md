# Servico em Segundo Plano

O servico em segundo plano mantem seus icones personalizados intactos, mesmo apos atualizacoes de apps ou alteracoes no sistema.

## Ativando

Va em **Settings** > **Background** e ative **Run in Background**.

Quando ativado, o IconChanger continua em execucao apos voce fechar a janela. Voce pode acessa-lo pela barra de menus ou pelo Dock.

## Funcionalidades

### Restauracao Programada

Restaure automaticamente todos os icones personalizados em cache em intervalos regulares.

- Ative **Restore Icons on Schedule**
- Escolha um intervalo: a cada hora, 3 horas, 6 horas, 12 horas, diariamente ou um intervalo personalizado
- As configuracoes mostram quando a ultima e a proxima restauracao ocorrerao

### Deteccao de Atualizacao de Apps

Detecte quando os apps sao atualizados e reaplique automaticamente seus icones personalizados.

- Ative **Restore Icons When Apps Update**
- Defina a frequencia de verificacao de atualizacoes (a cada 5 minutos ate a cada 2 horas, ou personalizado)

### Visibilidade do App

Controle onde o IconChanger aparece quando esta sendo executado em segundo plano:

- **Show in Menu Bar** — adiciona um icone na barra de menus
- **Show in Dock** — mantem o app no Dock

Pelo menos uma dessas opcoes deve estar ativada.

### Iniciar no Login

Inicie o IconChanger automaticamente quando voce fizer login no seu Mac.

- **Open Main Window** — inicia normalmente com a janela principal
- **Start Hidden** — inicia silenciosamente em segundo plano (requer que "Run in Background" esteja ativado)

::: info
"Start Hidden" afeta apenas a inicializacao no login. Abrir o app manualmente sempre exibira a janela principal.
:::

## Status do Servico

Quando o servico em segundo plano esta ativo, a pagina de configuracoes exibe:
- **Service Status** — se o servico esta em execucao
- **Cached Icons** — quantos icones estao prontos para restauracao
