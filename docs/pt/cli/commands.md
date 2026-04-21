---
title: Referencia de Comandos
section: cli
locale: pt
---

## Visao Geral

```
iconchanger <comando> [opcoes]
```

## Comandos

### `status`

Exibe o status da configuracao atual.

```bash
iconchanger status
```

Exibe:
- Numero de aliases de apps configurados
- Numero de icones em cache
- Status do script auxiliar

---

### `list`

Lista todos os aliases e icones em cache.

```bash
iconchanger list
```

Exibe uma tabela com todos os aliases configurados e todas as entradas de icones em cache.

---

### `set-icon`

Define um icone personalizado para um aplicativo.

```bash
iconchanger set-icon <caminho-do-app> <caminho-da-imagem>
```

**Argumentos:**
- `caminho-do-app` — Caminho para o aplicativo (ex.: `/Applications/Safari.app`)
- `caminho-da-imagem` — Caminho para a imagem do icone (PNG, JPEG, ICNS, etc.)

**Exemplos:**

```bash
# Definir um icone personalizado para o Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Caminhos relativos tambem funcionam
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Remove um icone personalizado e restaura o original.

```bash
iconchanger remove-icon <caminho-do-app>
```

**Exemplo:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Restaura todos os icones personalizados em cache. Util apos uma atualizacao do sistema ou quando os apps redefinam seus icones.

```bash
iconchanger restore [opcoes]
```

**Opcoes:**
- `--dry-run` — Visualiza o que seria restaurado sem fazer alteracoes
- `--verbose` — Exibe saida detalhada para cada icone
- `--force` — Restaura mesmo que o icone pareca inalterado

**Exemplos:**

```bash
# Restaurar todos os icones em cache
iconchanger restore

# Visualizar o que aconteceria
iconchanger restore --dry-run --verbose

# Forcar a restauracao de tudo
iconchanger restore --force
```

---

### `export`

Exporta aliases e configuracao de icones em cache para um arquivo JSON.

```bash
iconchanger export <caminho-de-saida>
```

**Exemplo:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importa um arquivo de configuracao.

```bash
iconchanger import <caminho-de-entrada>
```

A importacao apenas adiciona novos itens — ela nunca substitui ou remove entradas existentes.

**Exemplo:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valida um arquivo de configuracao antes de importar.

```bash
iconchanger validate <caminho-do-arquivo>
```

Verifica a estrutura JSON, campos obrigatorios e integridade dos dados sem fazer alteracoes.

**Exemplo:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Escapa da prisao squircle do macOS Tahoe reaplicando os icones inclusos nos apps como icones personalizados. Icones personalizados contornam a imposicao de squircle, preservando o formato original do icone.

```bash
iconchanger escape-jail [caminho-do-app] [opcoes]
```

**Argumentos:**
- `caminho-do-app` — (Opcional) Caminho para um bundle `.app` especifico. Se omitido, processa todos os apps em `/Applications`.

**Opcoes:**
- `--dry-run` — Visualiza o que seria feito sem fazer alteracoes
- `--verbose` — Exibe saida detalhada

**Exemplos:**

```bash
# Escapar da prisao para todos os apps em /Applications
iconchanger escape-jail

# Visualizar o que aconteceria
iconchanger escape-jail --dry-run --verbose

# Escapar da prisao para um app especifico
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Icones personalizados nao suportam os modos de icone Clear, Tinted ou Dark do macOS Tahoe. Eles permanecem como bitmaps estaticos.
:::

---

### `completions`

Gera scripts de autocompletar para o shell.

```bash
iconchanger completions <shell>
```

**Argumentos:**
- `shell` — Tipo de shell: `zsh`, `bash` ou `fish`

**Exemplos:**

```bash
# Zsh (adicione ao ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (adicione ao ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```