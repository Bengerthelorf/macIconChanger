---
title: Importar e Exportar
section: guide
order: 8
locale: pt
---

Faca backup das suas configuracoes de icones ou transfira-as para outro Mac.

## O Que e Exportado

Um arquivo de exportacao (JSON) inclui:
- **Aliases de apps** — seus mapeamentos personalizados de nomes de pesquisa
- **Referencias de icones em cache** — quais apps possuem icones personalizados e os arquivos de icones em cache

## Exportando

### Pela Interface Grafica

Va em **Settings** > **Advanced** > **Configuration** e clique em **Export**.

### Pela CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importando

### Pela Interface Grafica

Va em **Settings** > **Advanced** > **Configuration** e clique em **Import**.

### Pela CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
A importacao apenas **adiciona** novos itens. Ela nunca substitui ou remove seus aliases ou icones em cache existentes.
:::

## Validando

Antes de importar, voce pode validar um arquivo de configuracao:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Isso verifica a estrutura do arquivo sem fazer nenhuma alteracao.

## Automacao com Dotfiles

Voce pode automatizar a configuracao do IconChanger como parte dos seus dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Instalar o app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Instalar a CLI (do bundle do app)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importar sua configuracao de icones
iconchanger import ~/dotfiles/iconchanger/config.json
```