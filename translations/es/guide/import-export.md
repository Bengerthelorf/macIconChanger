# Importar y exportar

Respalde sus configuraciones de iconos o transfiéralas a otro Mac.

## Que se exporta

Un archivo de exportacion (JSON) incluye:
- **Alias de aplicaciones** — sus asignaciones personalizadas de nombres de busqueda
- **Referencias de iconos en cache** — que aplicaciones tienen iconos personalizados y los archivos de iconos almacenados en cache

## Exportar

### Desde la interfaz grafica

Vaya a **Settings** > **Advanced** > **Configuration** y haga clic en **Export**.

### Desde el CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importar

### Desde la interfaz grafica

Vaya a **Settings** > **Advanced** > **Configuration** y haga clic en **Import**.

### Desde el CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
La importacion solo **agrega** elementos nuevos. Nunca reemplaza ni elimina sus alias o iconos en cache existentes.
:::

## Validacion

Antes de importar, puede validar un archivo de configuracion:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Esto verifica la estructura del archivo sin realizar ningun cambio.

## Automatizacion con dotfiles

Puede automatizar la configuracion de IconChanger como parte de sus dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Instalar la aplicacion
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Instalar CLI (desde el paquete de la aplicacion)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importar su configuracion de iconos
iconchanger import ~/dotfiles/iconchanger/config.json
```
