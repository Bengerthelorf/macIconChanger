# Referencia de comandos

## Descripcion general

```
iconchanger <command> [options]
```

## Comandos

### `status`

Muestra el estado actual de la configuracion.

```bash
iconchanger status
```

Muestra:
- Cantidad de alias de aplicaciones configurados
- Cantidad de iconos en cache
- Estado del script auxiliar

---

### `list`

Lista todos los alias y los iconos en cache.

```bash
iconchanger list
```

Muestra una tabla con todos los alias configurados y todas las entradas de iconos en cache.

---

### `set-icon`

Establece un icono personalizado para una aplicacion.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Argumentos:**
- `app-path` — Ruta a la aplicacion (por ejemplo, `/Applications/Safari.app`)
- `image-path` — Ruta a la imagen del icono (PNG, JPEG, ICNS, etc.)

**Ejemplos:**

```bash
# Establecer un icono personalizado para Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Las rutas relativas tambien funcionan
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Elimina un icono personalizado y restaura el original.

```bash
iconchanger remove-icon <app-path>
```

**Ejemplo:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Restaura todos los iconos personalizados en cache. Util despues de una actualizacion del sistema o cuando las aplicaciones restablecen sus iconos.

```bash
iconchanger restore [options]
```

**Opciones:**
- `--dry-run` — Vista previa de lo que se restauraria sin realizar cambios
- `--verbose` — Muestra salida detallada para cada icono
- `--force` — Restaura incluso si el icono parece no haber cambiado

**Ejemplos:**

```bash
# Restaurar todos los iconos en cache
iconchanger restore

# Vista previa de lo que ocurriria
iconchanger restore --dry-run --verbose

# Forzar la restauracion de todo
iconchanger restore --force
```

---

### `export`

Exporta los alias y la configuracion de iconos en cache a un archivo JSON.

```bash
iconchanger export <output-path>
```

**Ejemplo:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importa un archivo de configuracion.

```bash
iconchanger import <input-path>
```

La importacion solo agrega elementos nuevos — nunca reemplaza ni elimina entradas existentes.

**Ejemplo:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valida un archivo de configuracion antes de importarlo.

```bash
iconchanger validate <file-path>
```

Verifica la estructura JSON, los campos requeridos y la integridad de los datos sin realizar cambios.

**Ejemplo:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Escapa de la jaula squircle de macOS Tahoe reaplicando los iconos incluidos en las aplicaciones como iconos personalizados. Los iconos personalizados eludan la imposicion de squircle, preservando la forma original del icono.

```bash
iconchanger escape-jail [app-path] [options]
```

**Argumentos:**
- `app-path` — (Opcional) Ruta a un paquete `.app` especifico. Si se omite, procesa todas las aplicaciones en `/Applications`.

**Opciones:**
- `--dry-run` — Vista previa de lo que se haria sin realizar cambios
- `--verbose` — Muestra salida detallada

**Ejemplos:**

```bash
# Escapar de la jaula para todas las aplicaciones en /Applications
iconchanger escape-jail

# Vista previa de lo que ocurriria
iconchanger escape-jail --dry-run --verbose

# Escapar de la jaula para una aplicacion especifica
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Los iconos personalizados no admiten los modos Clear, Tinted ni Dark de macOS Tahoe. Permanecen como mapas de bits estaticos.
:::

---

### `completions`

Genera scripts de autocompletado para el shell.

```bash
iconchanger completions <shell>
```

**Argumentos:**
- `shell` — Tipo de shell: `zsh`, `bash` o `fish`

**Ejemplos:**

```bash
# Zsh (agregar a ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (agregar a ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
