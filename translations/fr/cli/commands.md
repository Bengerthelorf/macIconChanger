# Reference des commandes

## Vue d'ensemble

```
iconchanger <commande> [options]
```

## Commandes

### `status`

Affiche l'etat de la configuration actuelle.

```bash
iconchanger status
```

Informations affichees :
- Nombre d'alias d'applications configures
- Nombre d'icones en cache
- Etat du script auxiliaire

---

### `list`

Liste tous les alias et les icones en cache.

```bash
iconchanger list
```

Affiche un tableau de tous les alias configures et de toutes les entrees d'icones en cache.

---

### `set-icon`

Definit une icone personnalisee pour une application.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Arguments :**
- `app-path` — Chemin vers l'application (par ex. `/Applications/Safari.app`)
- `image-path` — Chemin vers l'image de l'icone (PNG, JPEG, ICNS, etc.)

**Exemples :**

```bash
# Definir une icone personnalisee pour Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Les chemins relatifs fonctionnent aussi
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Supprime une icone personnalisee et restaure l'icone d'origine.

```bash
iconchanger remove-icon <app-path>
```

**Exemple :**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Restaure toutes les icones personnalisees en cache. Utile apres une mise a jour du systeme ou lorsque des applications reinitialise leurs icones.

```bash
iconchanger restore [options]
```

**Options :**
- `--dry-run` — Apercu de ce qui serait restaure sans effectuer de modifications
- `--verbose` — Affiche une sortie detaillee pour chaque icone
- `--force` — Restaure meme si l'icone semble inchangee

**Exemples :**

```bash
# Restaurer toutes les icones en cache
iconchanger restore

# Apercu de ce qui se passerait
iconchanger restore --dry-run --verbose

# Forcer la restauration de tout
iconchanger restore --force
```

---

### `export`

Exporte les alias et la configuration des icones en cache vers un fichier JSON.

```bash
iconchanger export <output-path>
```

**Exemple :**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importe un fichier de configuration.

```bash
iconchanger import <input-path>
```

L'import ne fait qu'ajouter de nouveaux elements — il ne remplace ni ne supprime les entrees existantes.

**Exemple :**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valide un fichier de configuration avant l'import.

```bash
iconchanger validate <file-path>
```

Verifie la structure JSON, les champs requis et l'integrite des donnees sans effectuer de modifications.

**Exemple :**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Echappe au carcan du squircle de macOS Tahoe en reappliquant les icones integrees des applications en tant qu'icones personnalisees. Les icones personnalisees contournent l'imposition du squircle, preservant ainsi la forme originale de l'icone.

```bash
iconchanger escape-jail [app-path] [options]
```

**Arguments :**
- `app-path` — (Facultatif) Chemin vers un bundle `.app` specifique. Si omis, traite toutes les applications dans `/Applications`.

**Options :**
- `--dry-run` — Apercu de ce qui serait fait sans effectuer de modifications
- `--verbose` — Affiche une sortie detaillee

**Exemples :**

```bash
# Echapper au squircle pour toutes les applications dans /Applications
iconchanger escape-jail

# Apercu de ce qui se passerait
iconchanger escape-jail --dry-run --verbose

# Echapper au squircle pour une application specifique
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Les icones personnalisees ne prennent pas en charge les modes d'icones Clear, Tinted ou Dark de macOS Tahoe. Elles restent sous forme d'images statiques.
:::

---

### `completions`

Genere des scripts d'auto-completion pour le shell.

```bash
iconchanger completions <shell>
```

**Arguments :**
- `shell` — Type de shell : `zsh`, `bash` ou `fish`

**Exemples :**

```bash
# Zsh (ajouter a ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (ajouter a ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
