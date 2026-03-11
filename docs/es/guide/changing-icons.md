# Cambiar iconos

## Uso de la interfaz grafica

### Busqueda en linea

1. Seleccione una aplicacion de la barra lateral.
2. Explore los iconos de [macOSicons.com](https://macosicons.com/) en el area principal.
3. Utilice el menu desplegable **Style** para filtrar por estilo (por ejemplo, Liquid Glass).
4. Haga clic en un icono para aplicarlo.

![Busqueda de iconos](/images/search-icons.png)

### Elegir un archivo local

Haga clic en **Choose from the Local** (o presione <kbd>Cmd</kbd>+<kbd>O</kbd>) para abrir un selector de archivos. Formatos compatibles: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Arrastrar y soltar

Arrastre un archivo de imagen desde Finder directamente sobre el area de iconos de la aplicacion. Aparecera un resaltado azul para confirmar la zona de destino.

![Arrastrar y soltar](/images/drag-drop.png)

### Restaurar el icono predeterminado

Para restaurar el icono original de una aplicacion:
- Haga clic en el boton **Restore Default** (o presione <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- O haga clic derecho en la aplicacion en la barra lateral y seleccione **Restore Default Icon**

## Escapar de la jaula Squircle (macOS Tahoe)

macOS 26 Tahoe obliga a todos los iconos de aplicaciones a adoptar una forma squircle (cuadrado redondeado). Las aplicaciones con iconos no conformes se reducen y se colocan sobre un fondo gris con forma squircle.

IconChanger puede corregir esto reaplicando el icono incluido en la propia aplicacion como un icono personalizado, lo que elude la imposicion de squircle de macOS.

### Por aplicacion

Haga clic derecho en una aplicacion en la barra lateral y seleccione **Escape Squircle Jail**.

### Todas las aplicaciones a la vez

Haga clic en el menu **...** de la barra de herramientas y seleccione **Escape Squircle Jail (All Apps)**. Esto procesa todas las aplicaciones que aun no tienen iconos personalizados.

::: tip
Los iconos personalizados establecidos de esta manera **no** admiten los modos Clear, Tinted ni Dark de macOS Tahoe — permanecen estaticos. Esta es una limitacion del sistema.
:::

::: info
Su servicio en segundo plano reaplicara automaticamente los iconos despues de las actualizaciones de aplicaciones, manteniendolos fuera de la jaula squircle.
:::

## Cache de iconos

Cuando aplica un icono personalizado, se almacena automaticamente en cache. Esto significa:
- Sus iconos personalizados pueden restaurarse despues de actualizaciones de aplicaciones
- El servicio en segundo plano puede reaplicarlos de forma programada
- Puede exportar e importar sus configuraciones de iconos

Administre los iconos en cache en **Settings** > **Icon Cache**.

## Atajos de teclado

| Atajo | Accion |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Elegir un archivo de icono local |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Restaurar el icono predeterminado |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Actualizar la visualizacion de iconos |

## Consejos

- Si no se encuentran iconos para una aplicacion, intente [establecer un alias](./aliases) con un nombre mas simple.
- El contador (por ejemplo, "12/15") muestra cuantos iconos se cargaron correctamente del total encontrado.
- Los iconos se ordenan por popularidad (cantidad de descargas) de forma predeterminada.
