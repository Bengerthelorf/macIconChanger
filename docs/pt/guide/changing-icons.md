# Alterando Icones

## Usando a Interface Grafica

### Pesquisar Online

1. Selecione um app na barra lateral.
2. Navegue pelos icones do [macOSicons.com](https://macosicons.com/) na area principal.
3. Use o menu suspenso **Style** para filtrar por estilo (ex.: Liquid Glass).
4. Clique em um icone para aplica-lo.

![Pesquisando icones](/images/search-icons.png)

### Escolher um Arquivo Local

Clique em **Choose from the Local** (ou pressione <kbd>Cmd</kbd>+<kbd>O</kbd>) para abrir o seletor de arquivos. Formatos suportados: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Arrastar e Soltar

Arraste um arquivo de imagem do Finder diretamente para a area de icone do app. Um destaque azul aparecera para confirmar a zona de soltura.

![Arrastar e soltar](/images/drag-drop.png)

### Restaurar Icone Padrao

Para restaurar o icone original de um app:
- Clique no botao **Restore Default** (ou pressione <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Ou clique com o botao direito no app na barra lateral e selecione **Restore Default Icon**

## Escapar da Prisao Squircle (macOS Tahoe)

O macOS 26 Tahoe forca todos os icones de apps em um formato squircle (quadrado arredondado). Apps com icones nao conformes sao reduzidos e colocados sobre um fundo cinza em squircle.

O IconChanger pode corrigir isso reaplicando o proprio icone incluso no app como um icone personalizado, o que contorna a imposicao de squircle do macOS.

### Por App

Clique com o botao direito em um app na barra lateral e selecione **Escape Squircle Jail**.

### Todos os Apps de Uma Vez

Clique no menu **...** na barra de ferramentas e selecione **Escape Squircle Jail (All Apps)**. Isso processa todos os apps que ainda nao possuem icones personalizados.

::: tip
Icones personalizados definidos dessa forma **nao** suportam os modos de icone Clear, Tinted ou Dark do macOS Tahoe — eles permanecem estaticos. Esta e uma limitacao do sistema.
:::

::: info
Seu servico em segundo plano reaplicara automaticamente os icones apos atualizacoes de apps, mantendo-os fora da prisao squircle.
:::

## Cache de Icones

Quando voce aplica um icone personalizado, ele e automaticamente armazenado em cache. Isso significa:
- Seus icones personalizados podem ser restaurados apos atualizacoes de apps
- O servico em segundo plano pode reaplica-los em intervalos programados
- Voce pode exportar e importar suas configuracoes de icones

Gerencie os icones em cache em **Settings** > **Icon Cache**.

## Atalhos de Teclado

| Atalho | Acao |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Escolher um arquivo de icone local |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Restaurar icone padrao |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Atualizar exibicao de icones |

## Dicas

- Se nenhum icone for encontrado para um app, tente [definir um alias](./aliases) com um nome mais simples.
- O contador (ex.: "12/15") mostra quantos icones foram carregados com sucesso do total encontrado.
- Os icones sao ordenados por popularidade (contagem de downloads) por padrao.
